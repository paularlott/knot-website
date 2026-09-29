---
title: knot.pool
description: Manage space pools that keep a desired count of identical spaces running.
type: API Reference
tags: [spaces, api, scripting]
weight: 16
---

The `knot.pool` library manages space pools. A pool keeps a desired count of identical spaces (created from the same template) running and ready, so the server can hand out method, HTTP, and TCP traffic across healthy members. Pools are useful for scaling stateless services and for method backends that need more capacity than a single space. Lease-enabled pools additionally support exclusive member checkout — `acquire()`, `extend()`, `release()`, `leases()` and the `leased()` context manager — for callers that need a member to themselves.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| Health check scripts | Not available. |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List visible pools with current utilization |
| `get(name)` | Get pool details and utilization by name or ID |
| `create(name, template_name, startup_script_id='', desired_count=1, active=True)` | Create a pool and return its ID. Bridged KVM templates are rejected — their spaces need an IP address chosen at creation, which a pool can't provide; NAT KVM templates work |
| `update(name, desired_count=None, active=None)` | Update the pool's desired count or active state |
| `delete(name)` | Delete a stopped pool and all its spaces |
| `set_size(name, desired_count)` | Set the pool's desired space count |
| `start(name)` | Start a stopped pool (starts all members, creates any missing) |
| `stop(name)` | Stop a running pool (stops all members without deleting them) |
| `acquire(name, time=None, wait=None)` | Acquire a member exclusively until the lease ends (lease-enabled pools). `time`: `None` = the pool's maximum, `"none"` = never expire (no-timeout pools only), seconds or a `"5m"`-style string. `wait`: optionally wait this long for a free member before raising |
| `extend(space, time=None)` | Renew the lease held on a member (space name or id) — the new deadline is now + `time` (or never, on no-timeout pools). Bounded by the pool's extension count |
| `release(space, destroy=False)` | Release the lease held on a member (space name or id — what acquire returned); the member returns to the pool after in-flight work drains (~15s). With `destroy=True` the member is deleted and a fresh replacement is created, so the next acquire gets a clean space |
| `leases(name)` | List the pool's held leases — active plus draining |
| `leased(name, time=None, wait=None, destroy=False)` | Context manager: acquire on entry, release (or destroy) on exit |

---

## Usage

```python
import knot.pool as pool

# List pools
for p in pool.list():
    print(f"{p['name']}: {p['alive_members']}/{p['desired_count']} alive")

# Create a pool of 3 spaces from a template
pool_id = pool.create(
    "api-pool",
    "my-service",
    desired_count=3,
    active=True,
)

# Scale the pool up
pool.set_size("api-pool", 5)

# Stop and later start the pool
pool.stop("api-pool")
pool.start("api-pool")

# Delete the pool (must be stopped first)
pool.delete("api-pool")
```

Exclusive member leases (requires a lease-enabled pool — `lease_max_time` set
at creation or via the update API):

```python
import knot.apiclient
import knot.pool as pool

# Check a member out for 5 minutes; the held instance is
# member["space_name"] / member["space_id"]
member = pool.acquire("build-workers", time="5m", wait="30s")

# Pin method calls to it while held
knot.apiclient.post("/api/methods/call", {
    "jsonrpc": "2.0", "id": 1,
    "method": "run_build",
    "params": {},
    "space_id": member["space_id"],
})

pool.extend(member["space_name"], time="5m")
pool.release(member["space_name"])

# Or let the context manager release on exit (including on exception)
with pool.leased("build-workers", "5m") as member:
    ...
```

---

## Pool Properties

`get()` and `list()` return pool dicts containing:

- `id` - Pool ID
- `name` - Pool name
- `template_id` - Template the pool's spaces are created from
- `startup_script_id` - Startup script applied to members
- `desired_count` - Target number of spaces
- `alive_members` - Number of currently healthy members
- `active` - Whether the pool is active (members are started as they are created)
- `lease_max_time` - Lease time budget in seconds: `0` = leases disabled, `-1` = no timeout
- `lease_max_extensions` - Max extensions per lease: `0` = extending forbidden, `-1` = unlimited
- `utilization` - Aggregate utilization across members:
  - `combined_rps` - Total requests per second (method + HTTP + TCP)
  - `method_rps` - Method requests per second
  - `http_rps` - HTTP requests per second
  - `tcp_rps` - TCP requests per second
  - `method_inflight` - In-flight method requests
  - `avg_cpu_percent` - Average CPU usage across members
  - `avg_memory_percent` - Average memory usage across members
- `members` - List of member space dicts (see below)

---

## Member Properties

Each member in `members` contains:

- `id` - Space ID
- `name` - Space name
- `state` - Member state
- `combined_rps`, `method_rps`, `http_rps`, `tcp_rps` - Per-member request rates
- `method_inflight` - In-flight method requests
- `cpu_percent` - CPU usage
- `memory_percent` - Memory usage
- `healthy` - Whether the member is healthy
- `is_pending` - Whether the member is pending creation
- `is_deleting` - Whether the member is being deleted
- `is_deployed` - Whether the member is deployed (running)
- `lease_state` - Lease state: `""` free, `"active"` exclusively leased, `"draining"` lease ended and waiting for in-flight work to finish
- `lease_holder` - Username of the lease holder (when leased)
- `lease_expires_at` - Lease expiry (`None` = never expires)

---

## Lease Properties

`acquire()`, `extend()` and `release()` return lease dicts, and `leases()`
returns a list of them:

- `pool_name` - The pool the lease was granted from
- `space_id`, `space_name` - The held member; extend/release take these, and method calls can be pinned with `space_id`
- `username` - The lease holder
- `expires_at` - When the lease ends (`None` = never expires)
- `extensions_used`, `max_extensions` - Extension counter and cap (`-1` = unlimited)
- `state` - `"active"` or `"draining"` (ended, waiting for in-flight work)

---

## Lifecycle Notes

- `create()` accepts a template **name** (resolved to an ID internally). The template, startup script, and pool name are immutable after creation; only `desired_count` and `active` are mutable via `update()`.
- `delete()` requires the pool to be stopped first.
- `set_size()`, `start()`, and `stop()` are asynchronous: the server's sweep loop creates, drains, or deletes member spaces to reach the desired state.
- Lease functions require the pool to be lease-enabled (`lease_max_time != 0`) and active. The simplest mode is a no-timeout pool (`lease_max_time = -1`): acquire, use, release — `time` can stay `None` everywhere. While a lease is held, shared method routing and pool-name port routing skip the member; on expiry or release the member returns to the pool after in-flight method work drains, normally within one 15-second sweep. `acquire()` raises when no member is free (after `wait`, if given); `extend()` raises once the pool's extension count is exhausted.
