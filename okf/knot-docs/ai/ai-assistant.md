---
description: Configure knot's web-based AI assistant and CLI, which connect to an LLM provider such as OpenAI, Anthropic Claude, Google Gemini, Ollama, Mistral, Z.AI or xAI Grok.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/ai/ai-assistant/
sources:
    - resource: https://getknot.dev/docs/ai/ai-assistant/
status: stable
tags:
    - ai
title: AI Assistant
type: Guide
---
# AI Assistant

The AI assistant operates within the browser interface and also provides a Command Line Interface (CLI) that can be accessed either from the host or within a space.

 The assistant requires access to a Large Language Model (LLM): a hosted provider — OpenAI, Anthropic Claude, Google Gemini, Mistral, Z.AI or xAI Grok — a local Ollama server, or any server that speaks the OpenAI, Anthropic, Google, Ollama or xAI API.

---

## Enabling the Chat Interface

To enable the chat interface, add the following configuration to the `knot.toml` file:

```toml
[server.chat]
enabled = true
provider = "ollama"                            # openai, claude, gemini, ollama, mistral, zai or grok
model = "qwen3:4b"
max_tokens = 4096
temperature = 0.7
reasoning_effort = "low"
ui_style = "avatar"
openai_endpoints = true
```

For any other OpenAI-compatible server, such as a local LM Studio or llama.cpp, set `type` and `base_url` instead of `provider`:

```toml
[server.chat]
enabled = true
type = "openai"
base_url = "http://localhost:8085/v1/"
model = "Qwen3-4B-Thinking-2507-GGUF:Q4_0"
```

### Configuration Options

- **`enabled`**: Must be set to `true` to activate the web assistant.
- **`provider`**: The AI provider — `openai`, `claude`, `gemini`, `ollama`, `mistral`, `zai`, or `grok`. On its own it's all that's needed: `base_url` defaults to the provider's API (e.g. `http://127.0.0.1:11434/v1` for Ollama).
- **`type`**: The API protocol of the server at `base_url` — `openai`, `anthropic`, `google`, `ollama`, or `xai` — for servers that aren't a provider's own API. Takes precedence over `provider`. Without a `base_url`, `openai` and `ollama` assume a server at `http://127.0.0.1:11434/v1` (also the default when neither `provider` nor `type` is set), while `anthropic`, `google` and `xai` use that provider's own API address.
- **`base_url`**: The address of the server hosting the LLM; overrides the provider's default. (`openai_base_url` is a deprecated alias.)
- **`api_key`**: The API key required to authenticate with the LLM server. (`openai_api_key` is a deprecated alias.)
- **`model`**: The model to be used (default `qwen2.5-coder:14b`). The assistant's performance depends on the selected model.
- **`max_tokens`**: The maximum number of tokens the model may generate per response. `0` (the default) sends no limit, so the provider's own applies.
- **`temperature`**: Sampling temperature. Left unset (the default), none is sent and the provider's default applies; leave it unset for reasoning models, which reject a temperature.
- **`system_prompt_file`**: Path to a file whose contents are used as the system prompt (see [System Prompt](system-prompt.md)).
- **`reasoning_effort`**: Controls the level of effort applied by the model for reasoning, there's no default. Options are:
  - `none`
  - `low`
  - `medium`
  - `high`
- **`ui_style`**: Defines the style of the assistant's chat icon. Options are:
  - `icon` (default)
  - `avatar`
- **`openai_endpoints`**: If set to `true`, the Knot server will expose an OpenAI-compatible endpoint at the `/v1/` path. This allows any client to connect to the Knot server, chat with the assistant, and use tools.

Each option can also be set with a `knot server` flag or an environment variable:

| Option | Flag | Environment variable |
|--------|------|----------------------|
| `enabled` | `--chat-enabled` | `KNOT_CHAT_ENABLED` |
| `provider` | `--chat-provider` | `KNOT_CHAT_PROVIDER` |
| `type` | `--chat-type` | `KNOT_CHAT_TYPE` |
| `base_url` | `--chat-base-url` | `KNOT_CHAT_BASE_URL` |
| `api_key` | `--chat-api-key` | `KNOT_CHAT_API_KEY` |
| `model` | `--chat-model` | `KNOT_CHAT_MODEL` |
| `max_tokens` | `--chat-max-tokens` | `KNOT_CHAT_MAX_TOKENS` |
| `temperature` | `--chat-temperature` | `KNOT_CHAT_TEMPERATURE` |
| `system_prompt_file` | `--chat-system-prompt-file` | `KNOT_CHAT_SYSTEM_PROMPT_FILE` |
| `reasoning_effort` | `--chat-reasoning-effort` | `KNOT_CHAT_REASONING_EFFORT` |
| `ui_style` | `--chat-ui-style` | `KNOT_CHAT_UI_STYLE` |
| `openai_endpoints` | `--chat-openai-endpoints` | `KNOT_CHAT_OPENAI_ENDPOINTS` |


If you are using a non-thinking model then do not set `reasoning_effort` in the configuration as usually this will stop the model from working.


---

## Tool Approvals

When the web assistant wants to run a write-capable tool, Knot pauses the tool call and shows a confirmation box at the bottom of the current chat message stream. The user can approve or deny the tool call before it executes.

Approvals are only used by the web chat flow. External MCP clients that connect to `/mcp` continue to use the normal MCP protocol and are not prompted by the browser approval UI.

Pending approvals are stored in memory on the Knot instance that started the tool call. In clustered deployments behind a load balancer, the approval request includes the originating instance ID. If the approval response reaches a different Knot instance, Knot forwards it to the origin over cluster gossip.

---

## Supported Models

The assistant is confirmed to work with the following models:

- **`gpt-oss 20B`** (via LM Studio)
- **`Gemini 2.5 Flash`**
