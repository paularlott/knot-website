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

Execute scripts locally with full system access. Libraries are resolved in priority order, mirroring scriptling-cli behaviour:

1. **Script directory** — the directory containing the script file (or cwd for stdin/interactive)
2. **Extra lib paths** — `--libpath` / `-L` flags or `SCRIPTLING_LIBPATH` env var
3. **Configured libdir** — `server.lib_dir` in `knot.toml`
4. **Server API** — fetched on demand from the server

### Security Considerations

- Full system access - use with trusted scripts only
- Can read/write files on the local machine
- Can execute system commands via subprocess
- Can load arbitrary .py files from disk

### Example

```bash
# Run local script - libs resolved from script's directory first
knot run-script myscript.py arg1 arg2

# Add extra lib search paths
knot run-script -L /path/to/libs myscript.py arg1 arg2

# SCRIPTLING_LIBPATH env var also works
SCRIPTLING_LIBPATH=/path/to/libs knot run-script myscript.py
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

### Standard & Extended Libraries

| Library | Local | MCP | Remote |
|---------|-------|-----|--------|
| **Standard Libraries** | ✓ | ✓ | ✓ |
| requests | ✓ | ✓ | ✓ |
| secrets | ✓ | ✓ | ✓ |
| yaml | ✓ | ✓ | ✓ |
| toml | ✓ | ✓ | ✓ |
| wait_for | ✓ | ✓ | ✓ |
| logging | ✓ | ✓ | ✓ |
| html.parser | ✓ | ✓ | ✓ |
| subprocess | ✓ | ✗ | ✓ |
| os/pathlib | ✓ | ✗ | ✓ |
| sys | ✓ | ✗ | ✓ |

### scriptling.* Libraries

| Library | Local | MCP | Remote |
|---------|-------|-----|--------|
| scriptling.ai | ✓ | ✓ | ✓ |
| scriptling.ai.agent | ✓ | ✓ | ✓ |
| scriptling.ai.agent.interact | ✓ | ✗ | ✓ |
| scriptling.ai.tools | ✓ | ✓ | ✓ |
| scriptling.fuzzy | ✓ | ✓ | ✓ |
| scriptling.mcp | ✓ | ✓ | ✓ |
| scriptling.mcp.tool | ✓ | ✓ | ✓ |
| scriptling.toon | ✓ | ✓ | ✓ |
| scriptling.console | ✓ | ✗ | ✓ |
| scriptling.glob | ✓ | ✗ | ✓ |
| scriptling.runtime | ✓ | ✗ | ✓ |
| scriptling.runtime.kv | ✓ | ✗ | ✓ |
| scriptling.runtime.sync | ✓ | ✗ | ✓ |
| scriptling.runtime.sandbox | ✓ | ✗ | ✓ |

### knot.* Libraries

| Library | Local | MCP | Remote |
|---------|-------|-----|--------|
| knot.space | ✓ API | ✓ Internal | ✓ API |
| knot.ai | ✓ API | ✓ MCP | ✓ API |
| knot.mcp | ✓ Tools | ✓ Special | ✓ Tools |
| knot.user | ✓ API | ✓ API | ✓ API |
| knot.group | ✓ API | ✓ API | ✓ API |
| knot.role | ✓ API | ✓ API | ✓ API |
| knot.template | ✓ API | ✓ API | ✓ API |
| knot.vars | ✓ API | ✓ API | ✓ API |
| knot.volume | ✓ API | ✓ API | ✓ API |
| knot.skill | ✓ API | ✓ API | ✓ API |
| knot.permission | ✓ API | ✓ API | ✓ API |

### Library Loading

| Source | Local | MCP | Remote |
|--------|-------|-----|--------|
| Load from disk | ✓ First | ✗ | ✗ |
| Load from server | ✓ Fallback | ✓ Only | ✓ Only |

For detailed documentation on scriptling standard and extended libraries, see the [Scriptling Documentation](https://scriptling.dev/docs).
