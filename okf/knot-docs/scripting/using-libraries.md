---
description: Use knot.* libraries across built-in, CLI, and external Scriptling execution contexts.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/scripting/using-libraries/
sources:
    - resource: https://getknot.dev/docs/scripting/using-libraries/
status: stable
tags:
    - scripting
    - api
title: Using knot.* Libraries
type: Guide
---
# Using knot.* Libraries

The `knot.*` namespace provides libraries for interacting with Knot from scripts. These libraries work differently depending on where your script is running.

---

## Execution Contexts

| Context | Configuration | Authentication |
|---------|---------------|----------------|
| **Built-in** | None required | Automatic (context token) |
| **Knot CLI** | None required | Uses `~/.knot/config` |
| **Scriptling in a space** | Packages via the agent | Automatic (agent `/connect`) |
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

Serving (JSON-RPC, HTTP, MCP) and the interactive REPL run on the real Scriptling CLI in the space — see below.

```python
import scriptling.secret as secret

db_password = secret.get("vault", "secret/data/prod/database", "password")
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

All environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `KNOT_URL` | Knot server URL | required |
| `KNOT_TOKEN` | Access token | required |
| `KNOT_INSECURE` | Skip TLS verification (`true`/`1`/`yes`) | `false` |
| `KNOT_AI_URL` | AI endpoint URL | `KNOT_URL + /v1` |
| `KNOT_AI_TOKEN` | AI access token | `KNOT_TOKEN` |
| `KNOT_AI_MODEL` | Default AI model name | `""` |
| `KNOT_AI_PROVIDER` | AI provider (`openai`, `claude`, `gemini`, `ollama`, `mistral`) | `openai` |

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


In production environments include the sha256 hash in the package URL to improve security.


See [knot.apiclient](../../knot-reference/libraries/apiclient.md) for the full list of configuration options and environment variables.

---

## Scriptling in a Space

Spaces built from a Scriptling base image run the real Scriptling CLI, and the
in-space agent serves everything it needs as cached zip packages on the local
API port:

| Package | Contents | Refreshed |
|---------|----------|-----------|
| `http://127.0.0.1:$KNOT_API_PORT/packages/knot.zip` | The `knot.*` libraries | When the agent reconnects to the server (e.g. after a server restart) |
| `http://127.0.0.1:$KNOT_API_PORT/packages/libs.zip` | Your `lib` scripts and global libraries | Automatically — the server notifies the agent whenever a library changes |

Pass both packages explicitly — the shell expands `$KNOT_API_PORT`:

```bash
scriptling \
  --package http://127.0.0.1:$KNOT_API_PORT/packages/knot.zip \
  --package http://127.0.0.1:$KNOT_API_PORT/packages/libs.zip \
  script.py
```

or add them to a `scriptling.toml` config file (searched in the current
directory, `$HOME`, and `$HOME/.config/scriptling/`) so plain
`scriptling script.py` works — the port must match the agent's `--api-port`,
default `12201`:

```toml
packages = [
  "http://127.0.0.1:12201/packages/knot.zip",
  "http://127.0.0.1:12201/packages/libs.zip",
]
```

Inside the space, `knot.apiclient` configures itself from the agent's
`/connect` endpoint — scripts act as the space owner with no URLs or tokens.

---

For the full list of available libraries and their documentation, see the [Library Reference](../../knot-reference/libraries.md).
