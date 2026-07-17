---
title: AI Assistant
description: Configure knot's web-based AI assistant and CLI, which connect to an OpenAI-compatible LLM.
type: Guide
tags: [ai]
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

{{< tip >}}
If you are using a non-thinking model then do not set `reasoning_effort` in the configuration as usually this will stop the model from working.
{{< /tip >}}

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
