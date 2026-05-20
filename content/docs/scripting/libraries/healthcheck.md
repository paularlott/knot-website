---
title: knot.healthcheck
weight: 40
---

The `knot.healthcheck` library provides functions for space health monitoring. It is only available in agent-side health check scripts. The check functions (`http_head`, `tcp_port`, `program`) return `True` or `False` so you can combine them, then call `check_result()` to report the final status and exit.

---

## Functions

| Function | Description |
|----------|-------------|
| `http_head(url, skip_ssl_verify=False, timeout=10)` | HTTP HEAD check — returns `True` if status 200 |
| `tcp_port(port, timeout=10)` | TCP port check — returns `True` if port is open |
| `program(command, timeout=10)` | Run a command — returns `True` if exit code 0 |
| `check_result(healthy)` | Report the health result and exit |

---

## Usage

```python
import knot.healthcheck as hc

# Simple HTTP check
hc.check_result(hc.http_head("http://localhost:8080/health"))

# Simple TCP check
hc.check_result(hc.tcp_port(8080))

# Combine multiple checks
ok = hc.http_head("http://localhost:8080/health") and hc.tcp_port(6379)
hc.check_result(ok)

# Custom logic
ok = hc.tcp_port(5432) and hc.program("pg_isready -q")
hc.check_result(ok)
```

---

## Function Details

### http_head(url, skip_ssl_verify=False, timeout=10)

Perform an HTTP HEAD request. Returns `True` if the response status code is 200, `False` for any other status or connection error.

**Parameters:**
- `url` (string): The URL to check
- `skip_ssl_verify` (bool, optional): Skip TLS certificate verification (default: `False`)
- `timeout` (int, optional): Request timeout in seconds (default: 10)

**Returns:** `bool` — `True` if healthy

---

### tcp_port(port, timeout=10)

Attempt a TCP connection to `127.0.0.1` on the given port. Returns `True` if the connection succeeds.

**Parameters:**
- `port` (int): The port number to check
- `timeout` (int, optional): Connection timeout in seconds (default: 10)

**Returns:** `bool` — `True` if healthy

---

### program(command, timeout=10)

Execute a shell command. Returns `True` if the command exits with code 0, `False` for any non-zero exit code or error.

**Parameters:**
- `command` (string): The command to execute
- `timeout` (int, optional): Execution timeout in seconds (default: 10)

**Returns:** `bool` — `True` if healthy

---

### check_result(healthy)

Report the final health check result and exit the script immediately.

**Parameters:**
- `healthy` (bool): `True` for healthy, `False` for unhealthy

---

## Environment Compatibility

The `knot.healthcheck` library is **only available in agent-side health check scripts**. It is not available in local, MCP, or remote execution environments.

When a template configures a health check type (HTTP, TCP, or Program), the agent automatically generates and runs a script using these functions. For the `custom` health check type, you write a script that imports `knot.healthcheck` directly, combines check functions as needed, and calls `check_result()` with the final result.
