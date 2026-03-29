---
title: knot.apiclient
weight: 15
---

The `knot.apiclient` library is the transport layer used by all `knot.*` libraries. In embedded contexts (MCP, remote, local scripts) it is provided by the Go runtime — `configure()` is a no-op and tokens are never exposed to scripts.

For standalone use outside knot, configure it explicitly or set environment variables.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP, remote, local) | Go runtime provides transport — `configure()` is a no-op |
| External (standalone scripts) | Python implementation — call `configure()` or set env vars |

---

## Functions

| Function | Description |
|----------|-------------|
| `configure(url, token, ...)` | Configure the client (no-op in embedded contexts) |
| `is_configured()` | Returns True if configured |
| `get(path, params=None)` | Make a GET request |
| `post(path, body=None)` | Make a POST request |
| `put(path, body=None)` | Make a PUT request |
| `delete(path)` | Make a DELETE request |

---

## Configuration

### Explicit

```python
import knot.apiclient

knot.apiclient.configure(
    "https://knot.example.com",
    "your-access-token",
    insecure=False,         # optional: skip SSL verification
    ai_model="gpt-4o",      # optional: default AI model for knot.ai
    ai_provider="openai",   # optional: AI provider (default: "openai")
    ai_url="",              # optional: AI endpoint URL (default: url + "/v1")
    ai_token="",            # optional: AI token (default: same as token)
)
```

### Environment Variables

Read on first use if `configure()` has not been called:

| Variable | Description | Default |
|----------|-------------|---------|
| `KNOT_URL` | Knot server URL | required |
| `KNOT_TOKEN` | Access token | required |
| `KNOT_INSECURE` | Skip SSL verification (`true`/`1`/`yes`) | `false` |
| `KNOT_AI_URL` | AI endpoint URL | `KNOT_URL + /v1` |
| `KNOT_AI_TOKEN` | AI access token | `KNOT_TOKEN` |
| `KNOT_AI_MODEL` | Default AI model name | `""` |
| `KNOT_AI_PROVIDER` | AI provider type | `openai` |

```bash
export KNOT_URL=https://knot.example.com
export KNOT_TOKEN=your-access-token
export KNOT_AI_MODEL=gpt-4o
```

```python
import knot.space as space

# Auto-configured from env vars on first use
spaces = space.list()
```

---

## configure() Parameters

### configure(url, token, insecure=False, ai_url="", ai_token="", ai_model="", ai_provider="openai")

| Parameter | Type | Description |
|-----------|------|-------------|
| `url` | str | Knot server base URL |
| `token` | str | Access token |
| `insecure` | bool | Skip SSL certificate verification |
| `ai_url` | str | AI endpoint URL (defaults to `url + "/v1"`) |
| `ai_token` | str | AI access token (defaults to `token`) |
| `ai_model` | str | Default model for `knot.ai.get_default_model()` |
| `ai_provider` | str | Provider: `openai`, `claude`, `gemini`, `ollama`, `mistral` |

---

## Supported AI Providers

| Value | Provider |
|-------|----------|
| `openai` | OpenAI / OpenAI-compatible (default) |
| `claude` | Anthropic Claude |
| `gemini` | Google Gemini |
| `ollama` | Ollama (local) |
| `mistral` | Mistral AI |
