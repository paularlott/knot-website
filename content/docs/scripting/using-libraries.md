---
title: Using knot.* Libraries
weight: 15
---

The `knot.*` namespace provides libraries for interacting with Knot from scripts. These libraries work differently depending on where your script is running.

---

## Execution Contexts

| Context                 | Configuration                   | Authentication            |
| ----------------------- | ------------------------------- | ------------------------- |
| **Built-in Scriptling** | None required                   | Automatic (context token) |
| **Knot CLI**            | None required                   | Uses `~/.knot/config`     |
| **External Scriptling** | `knot.api.configure()` required | Manual (pass token)       |

---

## Built-in

Scripts running inside Knot (startup scripts, shutdown scripts, MCP tools, space scripts) have automatic access to all libraries:

```python
import knot.space as space

# List all spaces
spaces = space.list()
for s in spaces:
    status = "running" if s['is_running'] else "stopped"
    print(f"{s['name']}: {status}")
```

No configuration is needed - the library uses the execution context for authentication.

---

## Knot CLI

When running scripts locally with the Knot CLI, the knot.\* libraries are fetched from the Knot server and make API calls automatically:

```bash
knot run-script myscript.py
```

The libraries use the API token from `~/.knot/config` for authentication.

```python
import knot.space as space

# List all spaces - automatically uses ~/.knot/config
spaces = space.list()
for s in spaces:
    status = "running" if s['is_running'] else "stopped"
    print(f"{s['name']}: {status}")
```

---

## External Scriptling

For standalone [scriptling](https://scriptling.dev/) scripts using the `knot.zip` package, explicit configuration is required:

```python
import knot.api
import knot.space

# Configure the connection first
knot.api.configure("https://knot.example.com", "your-api-token")

# List all spaces
spaces = knot.space.list()
for s in spaces:
    status = "running" if s['is_running'] else "stopped"
    print(f"{s['name']}: {status}")
```

This is useful for scripts running outside of the Knot environment.

```bash
scriptling --package=https://knot.example.com/packages/knot.zip myscript.py
```

{{< tip "warning" >}}
**Note**: In production environments the sha256 hash should be included in the package URL to improve security.
{{< /tip >}}

---

## Available Libraries

| Library                                     | Description          |
| ------------------------------------------- | -------------------- |
| [knot.space](../libraries/space/)           | Space management     |
| [knot.user](../libraries/user/)             | User management      |
| [knot.group](../libraries/group/)           | Group management     |
| [knot.role](../libraries/role/)             | Role management      |
| [knot.template](../libraries/template/)     | Template management  |
| [knot.volume](../libraries/volume/)         | Volume management    |
| [knot.vars](../libraries/vars/)             | Template variables   |
| [knot.skill](../libraries/skill/)           | Skills management    |
| [knot.permission](../libraries/permission/) | Permission constants |
| [knot.ai](../libraries/ai/)                 | AI completion        |
| [knot.mcp](../libraries/mcp/)               | MCP tool interaction |
