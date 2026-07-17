---
title: knot.slash_command
description: Manage slash commands — reusable prompt templates invoked from the AI chat.
type: API Reference
tags: [ai, scripting, api]
weight: 45
---

The `knot.slash_command` library provides functions to manage slash commands — reusable prompt templates invoked from the AI assistant chat window via `/<command-name>`.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| Health check scripts | Not available. |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

---

## Functions

| Function | Description |
|----------|-------------|
| `create(content, is_global=False, groups=None, zones=None, active=True)` | Create a new slash command |
| `get(name_or_id)` | Get a command by name or UUID |
| `update(name_or_id, content=None, groups=None, zones=None, active=None)` | Update a command |
| `delete(name_or_id)` | Delete a command |
| `list(owner=None, all_zones=False)` | List accessible commands |

---

## Command Content Format

Commands use a single markdown document with YAML frontmatter:

```markdown
---
name: "review-pr"
description: "Review a pull request"
argument-hint: "<pr-url>"
allowed-tools: "read_file, list_files"
---

Review the pull request at $ARGUMENTS. Focus on:
- Code correctness
- Security implications
- Test coverage
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Lowercase letters, numbers, hyphens (max 64 chars) |
| `description` | Yes | Shown in the command picker |
| `argument-hint` | No | Hint text in the picker (e.g. `<filename>`) |
| `allowed-tools` | No | Comma-separated tool names to auto-approve |

The body is free-form markdown. `$ARGUMENTS` is replaced with the user's input. If absent, the command runs immediately without prompting for arguments.

---

## Usage

```python
import knot.slash_command as command

# List all commands
commands = command.list()

# List only the current user's commands
my_commands = command.list(owner="current-user-id")

# Get a specific command
cmd = command.get("review-pr")
print(cmd["body"])

# Create a global command
command_id = command.create(
    content='---\nname: "greet"\ndescription: "Greet by name"\nargument-hint: "<name>"\n---\n\nSay hello to $ARGUMENTS',
    is_global=True,
    groups=["developers"],
)

# Update a command
command.update("greet", active=False)

# Delete a command
command.delete("greet")
```

---

## Command Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Command UUID |
| `name` | string | Command name |
| `description` | string | Picker description |
| `argument_hint` | string | Argument hint text |
| `allowed_tools` | list | Auto-allowed tool names |
| `body` | string | Command body markdown (get() only) |
| `user_id` | string | Owner user ID (empty = global) |
| `groups` | list | Group restrictions (global only) |
| `zones` | list | Zone restrictions |
| `active` | bool | Whether the command appears in the picker |
| `is_managed` | bool | Read-only managed command |
