---
title: Using knot.* Libraries
weight: 15
---

The `knot.*` namespace provides libraries for interacting with Knot from scripts. These libraries work differently depending on where your script is running.

---

## Execution Contexts

| Context | Configuration | Authentication |
|---------|---------------|----------------|
| **Built-in** | None required | Automatic (context token) |
| **Knot CLI** | None required | Uses `~/.knot/config` |
| **External Scriptling** | `knot.apiclient` required | Manual (env vars or explicit) |

---

## Built-in

Scripts running inside Knot (startup scripts, shutdown scripts, MCP tools, space scripts) have automatic access to all libraries:

```python
import knot.space as space

spaces = space.list()
for s in spaces:
    status = "running" if s['is_running'] else "stopped"
    print(f"{s['name']}: {status}")
```

No configuration is needed — the library uses the execution context for authentication.

---

## Knot CLI

When running scripts locally with the Knot CLI, the `knot.*` libraries make API calls automatically using the token from `~/.knot/config`:

```bash
knot run-script myscript.py
```

```python
import knot.space as space

spaces = space.list()
for s in spaces:
    status = "running" if s['is_running'] else "stopped"
    print(f"{s['name']}: {status}")
```

---

## External Scriptling

For standalone [scriptling](https://scriptling.dev/) scripts using the `knot.zip` package, configure `knot.apiclient` before using any `knot.*` library. The simplest approach is environment variables, which are read automatically on first use:

```bash
export KNOT_URL=https://knot.example.com
export KNOT_TOKEN=your-api-token

# AI options (if using knot.ai):
export KNOT_AI_MODEL=gpt-4o
export KNOT_AI_PROVIDER=openai   # optional, defaults to openai
```

```python
import knot.space as space

# Auto-configured from KNOT_URL / KNOT_TOKEN
spaces = space.list()
for s in spaces:
    status = "running" if s['is_running'] else "stopped"
    print(f"{s['name']}: {status}")
```

Or configure explicitly in the script:

```python
import knot.apiclient
import knot.space as space

knot.apiclient.configure(
    "https://knot.example.com",
    "your-api-token",
    ai_model="gpt-4o",      # optional: for knot.ai
    ai_provider="openai",   # optional: for knot.ai
)

spaces = space.list()
```

Load the package with scriptling:

```bash
scriptling --package=https://knot.example.com/packages/knot.zip myscript.py
```

{{< tip "warning" >}}
In production environments include the sha256 hash in the package URL to improve security.
{{< /tip >}}

See [knot.apiclient](../libraries/apiclient/) for the full list of configuration options and environment variables.

---

## Available Libraries

| Library | Description |
|---------|-------------|
| [knot.apiclient](../libraries/apiclient/) | Transport configuration (external use) |
| [knot.space](../libraries/space/) | Space management |
| [knot.user](../libraries/user/) | User management |
| [knot.group](../libraries/group/) | Group management |
| [knot.role](../libraries/role/) | Role management |
| [knot.template](../libraries/template/) | Template management |
| [knot.volume](../libraries/volume/) | Volume management |
| [knot.vars](../libraries/vars/) | Template variables |
| [knot.skill](../libraries/skill/) | Skills management |
| [knot.permission](../libraries/permission/) | Permission constants |
| [knot.ai](../libraries/ai/) | AI completion |
| [knot.mcp](../libraries/mcp/) | MCP tool interaction |
