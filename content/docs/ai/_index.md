---
title: AI
weight: 120
---

Starting with version 0.19.0, **knot** introduces AI support through two key features:

1. **Model Context Protocol (MCP)**
   When MCP functionality is enabled, the **knot** server provides tools that can be utilized by compatible clients. These clients may include editors like Visual Studio Code or desktop applications such as ChatWise, provided they support tool calling and the OpenAI API.

2. **Web-Based Assistant**
   Enabling the web-based assistant allows users to interact with their spaces and their contents via a chat interface. This assistant requires the **knot** server to be connected to a Large Language Model (LLM).

   Additionally, when the web-based assistant is enabled, clients that do not support tool calling can connect directly to the **knot** server. In this setup, tool calls are handled internally by the server, leveraging **knot's** internal system prompt.

---

## What's Next

- [Model Context Protocol](mcp/)
- [Web Assistant](ai-assistant/)
- [Recipes](recipes/)
- [System Prompt](system-prompt/)
