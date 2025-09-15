---
title: MCP
weight: 10
---

The Model Context Protocol (MCP) server can be enabled on the **knot** server by adding the following configuration to the `knot.toml` file:

```toml
[server.mcp]
enabled = true
```

This configuration enables the MCP server at the path `/mcp`. Notably, it does not require **knot** to have access to a Large Language Model (LLM).

---

## Connecting a Client

The **knot** MCP server operates over HTTP transport and is accessible at the URL: `https://<your-knot-domain.com>/mcp`

For example, if your **knot** installation is hosted at `knot.getknot.dev`, the MCP server URL would be: `https://knot.getknot.dev/mcp`

### OAuth2-Supported Clients
If your client supports OAuth2, it will connect to the MCP server and allow you to log in using your standard credentials. During this process, an [API token](../../api-tokens/) will be generated for use.

### Non-OAuth2 Clients
For clients that do not support OAuth2, you will need to manually generate a new [API token](../../api-tokens/) via the web interface and provide it to the MCP client. Use the following format:

| Key           | Value                     |
|---------------|---------------------------|
| Authorization | Bearer `your token`       |

In both cases, the MCP client will have the same level of access to tools as the user who generated the API token.

---

## Tools

The following tools are available on the MCP server. The specific tools and operations accessible depend on the user's permissions:

### Space Management
- **list_spaces**: List all spaces for the current user, including status and sharing details.
- **get_space**: Retrieve detailed space information, including configuration and status.
- **create_space**: Create a new development space.
- **update_space**: Update an existing space.
- **delete_space**: Permanently delete a space and all its data.
- **start_space**: Start a space.
- **stop_space**: Stop a space.
- **restart_space**: Restart a space.
- **share_space**: Share a space with another user.
- **stop_sharing_space**: Stop sharing a space.
- **transfer_space**: Transfer ownership of a space to another user.

### Template Management
- **list_templates**: List all space templates.
- **create_template**: Create a new space template.
- **update_template**: Update an existing template.
- **get_template**: Retrieve detailed template information, including configuration and job specifications.
- **delete_template**: Permanently delete a template.

### File Operations
- **read_file**: Read the contents of a file from a running space.
- **write_file**: Write content to a file in a running space.

### Command Execution
- **run_command**: Execute a command in a running space and return the results.

### User and Group Management
- **list_users**: List details of all users (e.g., ID, username, email, active status, groups).
- **list_groups**: List all user groups.

### Icons and Recipes
- **list_icons**: List all available icons with descriptions and URLs.
- **recipes**: Access the knowledge base for guides and best practices. Call without a filename to list all recipes, or with a filename for specific content.
