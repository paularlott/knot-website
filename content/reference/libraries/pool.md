---
title: knot.pool
weight: 16
---

The `knot.pool` library manages space pools. A pool keeps a desired count of identical spaces (created from the same template) running and ready, so the server can hand out method, HTTP, and TCP traffic across healthy members. Pools are useful for scaling stateless services and for method backends that need more capacity than a single space.

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
| `create(name, template_name, startup_script_id='', desired_count=1, active=True)` | Create a pool and return its ID |
| `update(name, desired_count=None, active=None)` | Update the pool's desired count or active state |
| `delete(name)` | Delete a stopped pool and all its spaces |
| `set_size(name, desired_count)` | Set the pool's desired space count |
| `start(name)` | Start a stopped pool (starts all members, creates any missing) |
| `stop(name)` | Stop a running pool (stops all members without deleting them) |

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

---

## Lifecycle Notes

- `create()` accepts a template **name** (resolved to an ID internally). The template, startup script, and pool name are immutable after creation; only `desired_count` and `active` are mutable via `update()`.
- `delete()` requires the pool to be stopped first.
- `set_size()`, `start()`, and `stop()` are asynchronous: the server's sweep loop creates, drains, or deletes member spaces to reach the desired state.
