---
title: Space Pools
description: Fixed-size, self-healing groups of spaces with HTTP/TCP port routing and method draining.
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
external tool.

## Port Routing

Pool member spaces expose their HTTP and TCP ports under the **pool name**
rather than the individual space name. For example, if user `alice` has a pool
named `search-api` with an HTTP port on 8080:

```
https://alice--search-api--8080.knot.example.com
```

The proxy resolves the pool name, picks a healthy member via round-robin, and
routes the request to it. Drained members (being removed) are skipped
automatically. If no healthy member is available, the proxy returns 404.

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

Pool operations require **Use Space Pools** permission.

## CLI

```bash
knot pool list                          # List your pools
knot pool start <name>                  # Start a stopped pool
knot pool stop <name>                   # Stop a running pool
knot pool set-size <name> <count>       # Change the desired space count
knot pool delete <name> [-y]            # Delete a stopped pool (prompts unless -y)
```
