---
title: AI Assistant
weight: 20
---

The AI assistant operates within the browser interface and also provides a Command Line Interface (CLI) that can be accessed either from the host or within a space. The assistant requires access to an external Large Language Model (LLM) that supports the OpenAI API.

---

## Enabling the Chat Interface

To enable the chat interface, add the following configuration to the `knot.toml` file:

```toml
[server.chat]
ui_style = "avatar"
enabled = true
openai_endpoints = true
openai_base_url = "http://localhost:8085/v1/"
openai_api_key = ""
model = "Qwen3-4B-Thinking-2507-GGUF:Q4_0"
reasoning_effort = "low"
```

### Configuration Options

- **`ui_style`**: Defines the style of the assistant's chat icon. Options are:
  - `avatar` (default)
  - `icon`
- **`enabled`**: Must be set to `true` to activate the web assistant.
- **`openai_endpoints`**: If set to `true`, the **knot** server will expose an OpenAI-compatible endpoint at the `/v1/` path. This allows any client to connect to the **knot** server, chat with the assistant, and use tools.
- **`openai_base_url`**: Specifies the address of the server hosting the LLM.
- **`openai_api_key`**: The API key required to authenticate with the LLM server.
- **`model`**: The model to be used. The assistant's performance depends on the selected model.
- **`reasoning_effort`**: Controls the level of effort applied by the model for reasoning, there's no default. Options are:
  - `none`
  - `low`
  - `medium`
  - `high`

---

## Supported Models

The assistant is confirmed to work with the following models:

- **`gpt-oss 20B`** (via LM Studio)
- **`Gemini 2.5 Flash`**
