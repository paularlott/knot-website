---
title: Execution Environments
weight: 10
---

Knot provides three distinct script execution environments, each tailored for specific use cases with different library availability and security constraints.

---

## Overview

| Environment | Used By | System Access | API Client | Best For |
|-------------|---------|---------------|------------|----------|
| **Local** | CLI `knot run-script` | Full (host) | Yes | Local development and testing |
| **MCP** | AI tool scripts | None | No (internal) | Safe AI tool execution |
| **Remote** | Space execution | Full (container) | Yes | Scripts in user spaces/containers |

---

## Choosing an Environment

```
Is it an MCP tool for AI?
├─ YES → MCP Environment
└─ NO → Is it running in a space/container?
    ├─ YES → Remote Environment
    └─ NO → Local Environment
```

---

## Local Environment

**Command:** `knot run-script`

Execute scripts locally with full system access. Scripts can read/write files on the host machine and execute system commands.

### Available Libraries

All standard, extended, and knot.* libraries are available. Libraries are loaded on-demand, trying local `.py` files first, then fetching from the server.

### Security Considerations

- Full system access - use with trusted scripts only
- Can read/write files on the local machine
- Can execute system commands via subprocess
- Can load arbitrary .py files from disk

### Example

```bash
knot run-script myscript.py arg1 arg2
```

---

## MCP Environment

**Used by:** AI assistants executing MCP tools

Execute tool scripts in a controlled environment designed for AI integration. This is the most restricted environment for security.

### Available Libraries

Standard libraries and safe extended libraries are available. System access libraries (`os`, `pathlib`, `subprocess`, `sys`) are **not** available.

### Security Considerations

- No filesystem access
- No command execution
- Cannot load external files
- Only fetches libraries from server
- Limited to safe operations for AI tool usage

### Example

```python
import scriptling.mcp.tool as tool

name = tool.get_string("name", "World")
tool.return_string(f"Hello, {name}!")
```

---

## Remote Environment

**Command:** `knot space run-script`

Execute scripts remotely in user spaces. Scripts run inside the container with full capabilities within that container's isolation.

### Available Libraries

All standard, extended, and knot.* libraries are available, loaded on-demand from the server.

### Security Considerations

- Runs in isolated container (space)
- Full capabilities within container
- No access to host filesystem
- **Requires active agent connection** - script execution fails if space agent is not connected
- `scriptling.console` provides an interactive TUI streamed back to the client terminal
- `scriptling.ai.agent.interact` is available for interactive AI agent sessions

### Example

```bash
knot space run-script myspace myscript arg1 arg2
```

---

## Library Availability Matrix

| Library | Local | MCP | Remote |
|---------|-------|-----|--------|
| **Standard Libraries** | ✓ | ✓ | ✓ |
| requests | ✓ | ✓ | ✓ |
| secrets | ✓ | ✓ | ✓ |
| yaml | ✓ | ✓ | ✓ |
| wait_for | ✓ | ✓ | ✓ |
| logging | ✓ | ✓ | ✓ |
| subprocess | ✓ | ✗ | ✓ |
| os/pathlib | ✓ | ✗ | ✓ |
| sys | ✓ | ✗ | ✓ |
| scriptling.runtime | ✓ | ✗ | ✓ |
| scriptling.runtime.kv | ✓ | ✗ | ✓ |
| scriptling.runtime.sync | ✓ | ✗ | ✓ |
| scriptling.console | ✓ | ✗ | ✓ |
| scriptling.glob | ✓ | ✗ | ✓ |
| scriptling.ai | ✓ | ✓ | ✓ |
| scriptling.ai.agent | ✓ | ✓ | ✓ |
| scriptling.ai.agent.interact | ✓ | ✗ | ✓ |
| scriptling.fuzzy | ✓ | ✓ | ✓ |
| scriptling.mcp | ✓ | ✓ | ✓ |
| scriptling.mcp.tool | ✓ | ✓ | ✓ |
| scriptling.toon | ✓ | ✓ | ✓ |
| scriptling.ai.tools | ✓ | ✓ | ✓ |
| toml | ✓ | ✓ | ✓ |
| knot.space | ✓ API | ✓ Internal | ✓ API |
| knot.ai | ✓ API | ✓ MCP | ✓ API |
| knot.mcp | ✓ Tools | ✓ Special | ✓ Tools |
| **Load from disk** | ✓ First | ✗ | ✗ |
| **Load from server** | ✓ Fallback | ✓ Only | ✓ Only |

For detailed documentation on scriptling standard and extended libraries, see the [Scriptling Documentation](https://scriptling.dev/docs).
