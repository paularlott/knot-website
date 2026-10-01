---
title: Space Pools
description: Fixed-size, self-healing groups of spaces with HTTP/TCP port routing, method draining, and exclusive member leases.
type: Guide
tags: [spaces, configuration]
weight: 82
---

Space pools keep a fixed number of identical spaces running from a template. A
pool stores a target `desired_count` and an `active` flag. The cluster leader
reconciles pools every 15 seconds: it replaces dead members, creates new members
when the pool is below target, drains method traffic before stopping excess
members, and applies a grace period before deleting stopped spaces.

Pools do not include built-in autoscaling. Knot exposes utilization stats and a
runtime size API so you can write your own scaler in Scriptling or another
external tool. Pools can also be configured for **exclusive member leases** —
checking one member out for a caller's private use for a bounded time (see
[Member Leases](#member-leases)).

## Port Routing

Pool member spaces expose their HTTP and TCP ports under the **pool name**
rather than the individual space name. For example, if user `alice` has a pool
named `search-api` with an HTTP port on 8080:

```
https://alice--search-api--8080.knot.example.com
```

The proxy resolves the pool name, picks a healthy member via round-robin, and
routes the request to it. Drained members (being removed) are skipped
automatically. Exclusively leased members are skipped too — while held, a
member serves only its lease holder. If no healthy member is available, the
proxy returns 404.

TCP ports work the same way via the WebSocket proxy endpoint
`/proxy/spaces/{pool_name}/port/{port}`.

## Lifecycle

When `desired_count` is reduced on a running pool, excess spaces go through a
multi-sweep transition:

1. **Drain** — new JSON-RPC method calls stop routing to the space (15s buffer
   for in-flight requests to complete).
2. **Stop** — the container is stopped.
3. **Grace period** — the stopped space survives one extra sweep cycle, allowing
   it to be restarted if `desired_count` goes back up.
4. **Delete** — the space is permanently removed.

If the pool's `desired_count` increases before step 3 completes, the space is
undrained and continues running without interruption.

Stopping a pool sets `active = false` and stops all member spaces without
deleting them. Starting a stopped pool starts all members and creates new ones
if needed.

Deleting a pool requires it to be stopped first. Member space deletion is
initiated (marked as deleting), then the pool definition is tombstoned. The
container service completes volume cleanup and finalises space deletion
asynchronously.

## Member Leases

By default every request into a pool is load-balanced across the healthy
members — nothing is reserved. A lease-enabled pool adds a checkout flow on
top: a caller **acquires** one warm, healthy member for exclusive use, works
with it, and **releases** it back to the pool. Acquire is instant — it only
ever picks members that are already running and healthy, so there is never a
wait for a space to be ready. Typical uses are scripts, agents, and CI jobs
that each need their own instance of a browser, build environment, or service
without colliding.

The simplest configuration is **no limit**: leases run until released, with
no expiry to think about. This is the natural fit for personal development —
the only failure mode is a script that crashes between acquire and release,
which leaves the member leased until you release it by hand
(`knot pool leases` shows what's held).

Leases are configured per pool at creation (or later via the update API):

- **`lease_max_time`** — `-1` (no limit) makes leases run until released;
  a positive value sets an optional **safety net** — a lease that hits its
  deadline returns its member to the pool automatically, which self-heals a
  forgotten release. `0` (the default) disables leases entirely.
- **`lease_max_extensions`** — how many times a lease may be extended, for
  time-limited pools: `0` forbids extending, `-1` allows unlimited.

Acquire takes an optional duration: omitted, it uses the pool's maximum
(`-1` pools grant never-expiring leases); explicitly, it must not exceed the
pool maximum, and `-1` (never expire) is only valid on no-timeout pools.

Lease settings are read live at each operation — changing them takes effect
immediately for new acquires, with nothing to roll out to members. Held
leases are not rewritten: their deadlines were fixed when they were granted,
though the extension cap applies to the next renewal attempt. Turning leases
off lets held leases end naturally (expiry or release) but refuses renewals.

### What exclusivity means

While a lease is held:

- Shared **method routing** (JSON-RPC and MCP) skips the member. If every
  remaining provider of a method is leased, callers get a `409` response —
  "method exclusively leased" — rather than a load-balanced call.
- **Pool-name port routing** (`user--poolname--port`) skips the member.
- The holder reaches their member two ways: by its **own member name**
  (`user--poolname-3--port` — unchanged, direct), or by pinning method calls
  to it with the `space_id` field on `/api/methods/call` requests.

Leases are granted per member, not per user account — any token of the pool's
owner sees the same pool, and the lease serialises concurrent consumers.

### Expiry and in-flight work

When a lease reaches its deadline (or is released early) the member does not
re-enter rotation immediately: it stays excluded until in-flight **method
calls** have finished — each bounded by its per-method timeout — and then the
sweep returns it to the pool, normally within one 15-second cycle. A lease in
this state shows as `draining`. Open HTTP/TCP connections do not hold a
member. A lease can be extended while draining (until reclaimed), which
rescues a lease that ran out by accident.

The pool reconciler never shrinks, stops, or auto-stops (template max uptime)
a leased member; stopping a pool is rejected while leases are active.

### Acquire, extend, release

```shell
# The simple flow: allocate, use, release (on a no-timeout pool)
knot pool acquire build-workers
knot pool release build-workers-0          # the member's name — no pool needed

# Done with it and want a clean slate next time? Destroy the member —
# a fresh replacement is created, and the next acquire gets a clean space
knot pool release build-workers-0 --destroy

# See who holds what
knot pool leases build-workers

# Structured output for scripts
knot pool acquire build-workers --json | jq -r .space_name

# Time-boxed variant (pool with a limit): check out for 5 minutes,
# optionally waiting up to 2m for a free member, and renew if needed
knot pool acquire build-workers --time 5m --wait 2m
knot pool extend build-workers-0 --time 5m
```

`acquire` waits up to 10 seconds by default — long enough to pick up a
member that is mid-start or just being replaced — and `--wait 0s` fails
immediately. `release --destroy` (or `destroy=true` on the API's
`DELETE /api/spaces/{space_id_or_name}/lease`) deletes the member through the
normal drain-and-delete flow and starts a fresh replacement right away, so
the pool stays at its desired count.

On a no-timeout pool a plain `acquire` (no `--time`) grants a
never-expiring lease; `--time none` says so explicitly.

In Scriptling:

```python
import knot.pool as pool

with pool.leased("browsers") as member:
    # member["space_id"] / member["space_name"] identify the held instance;
    # pin method calls to it while held
    ...
# released automatically on exit — even on exception
```

See [knot.pool](../../reference/libraries/pool/) for the full lease API.

## What Pools Track

Pool utilization is calculated from the latest agent state reports and the
method registry:

- Combined request rate across JSON-RPC methods, HTTP requests, and TCP
  connections
- JSON-RPC in-flight method calls
- Average CPU and memory usage across live members
- Per-member state and utilization for debugging

## Scriptling

Use `knot.pool` to inspect pools and update their target size:

```python
import knot.pool as pool

info = pool.get("search-pool")
util = info["utilization"]

if util["combined_rps"] > 100:
    pool.set_size("search-pool", info["desired_count"] + 1)
```

`set_size()` updates the target count immediately. The sweep loop handles
draining, stopping, and deleting excess spaces within 1-2 cycles.

{{< zoom-picture src="images/pools.webp" caption="Creating a Pool from the Spaces Page" >}}

## Creating a Pool

Pools are created through the API (or a stack definition). A pool needs a name and a template; it starts stopped unless `active` is set:

```shell
curl -X POST -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "build-workers",
    "template_id": "<template-uuid>",
    "desired_count": 3,
    "active": true
  }' \
  https://knot.internal:3000/api/pools
```

- **`name`**: Pool name, also used as the routing endpoint.
- **`template_id`**: The template pool members are created from (required).
- **`startup_script_id`**: Optional startup script for members.
- **`desired_count`**: Runtime target member count (default 1).
- **`active`**: Start the pool immediately when `true` (default `false`).
- **`lease_max_time`**: Enable exclusive member leases — `-1` for allocate/use/release with no timeout (the web form's default when leases are enabled), a positive number of seconds for an optional expiry safety net, `0` (default) to disable leases.
- **`lease_max_extensions`**: Max extensions per lease — `-1` for unlimited (the default pairing with no-limit), `0` to forbid extending.

---

## API

The pool API is available to authenticated callers:

- `GET /api/pools`
- `POST /api/pools`
- `GET /api/pools/{id_or_name}`
- `PUT /api/pools/{id_or_name}`
- `DELETE /api/pools/{id_or_name}`
- `POST /api/pools/{id_or_name}/size`
- `POST /api/pools/{id_or_name}/start`
- `POST /api/pools/{id_or_name}/stop`
- `POST /api/pools/{id_or_name}/acquire` — grant an exclusive member lease (optionally long-poll with `wait_seconds`, max 300)
- `GET /api/pools/{id_or_name}/leases` — list held leases
- `POST /api/spaces/{space_id_or_name}/lease/extend` — renew a lease
- `DELETE /api/spaces/{space_id_or_name}/lease` — release a lease early (`?destroy=true` destroys the member and starts a fresh replacement)

Pool operations require **Use Space Pools** permission.

## CLI

```bash
knot pool list                          # List your pools
knot pool start <name>                  # Start a stopped pool
knot pool stop <name>                   # Stop a running pool
knot pool set-size <name> <count>       # Change the desired space count
knot pool delete <name> [-y]            # Delete a stopped pool (prompts unless -y)
knot pool acquire <name> [--time 5m|none] [--wait 2m]   # Check a member out exclusively
knot pool extend <member> [--time 5m|none]              # Renew the lease on a held member
knot pool release <member> [--destroy]  # Return a member early (or destroy it for a clean replacement)
knot pool leases <name>                 # List held leases
```
