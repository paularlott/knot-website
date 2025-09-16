---
title: System Prompt
weight: 40
---

When using the built-in assistant—either through the web interface or the OpenAI endpoints—a system prompt is inserted into the conversation. This prompt helps the LLM understand how it should operate within the **knot** environment.

---

## Fetching and Customizing the System Prompt

The default system prompt can be retrieved using the following command:

```shell
knot scaffold --system-prompt
```

This command provides the current system prompt, which can then be refined to suit your specific environment.

To use a customized system prompt, update the `knot.toml` configuration file with the following setting:

```toml {filename="knot.toml"}
server.chat.system_prompt_file = "<path-to-your-custom-prompt-file>"
```

After making this change, restart the **knot** server for the new prompt to take effect.

---

## Important Notes

- The system prompt is only used by the assistant. It is not utilized when the **knot** server is running solely as an MCP server.
- Customizing the system prompt allows you to tailor the assistant's behavior to better align with your environment and requirements.
