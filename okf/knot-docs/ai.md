---
description: knot's AI features include an MCP server and a web-based assistant powered by an external LLM.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/ai/
sources:
    - resource: https://getknot.dev/docs/ai/
status: stable
tags:
    - ai
title: AI
type: Overview
---
# AI

Starting with version 0.19.0, Knot introduces AI support through two key features:

1. **Model Context Protocol (MCP)**
   When MCP functionality is enabled, the Knot server provides tools that can be utilized by compatible clients. These clients may include editors like Visual Studio Code or desktop applications such as ChatWise, provided they support tool calling and the OpenAI API.

2. **Web-Based Assistant**
   Enabling the web-based assistant allows users to interact with their spaces and their contents via a chat interface. This assistant requires the Knot server to be connected to a Large Language Model (LLM).

   Additionally, when the web-based assistant is enabled, clients that do not support tool calling can connect directly to the Knot server. In this setup, tool calls are handled internally by the server, leveraging **knot's** internal system prompt.

---

## What's Next

- [Model Context Protocol](ai/mcp.md)
- [MCP Tools](ai/mcp-tools.md)
- [Remote MCP Servers](ai/mcp-remote.md)
- [Web Assistant](ai/ai-assistant.md)
- [Skills](ai/skills.md)
- [Slash Commands](ai/slash-commands.md)
- [System Prompt](ai/system-prompt.md)
