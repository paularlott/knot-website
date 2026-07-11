---
title: Slash Commands
weight: 5
---

Slash commands are reusable prompt templates that users can invoke from the AI assistant chat window by typing `/<command-name>`. Each command has a markdown body with an optional `$ARGUMENTS` placeholder that is replaced with the user's input at invocation time.

---

## Creating Commands

Commands are created from the **Slash Commands** page under **More** in the sidebar. Click **Create Command** to open the editor.

The editor uses a single markdown document with YAML frontmatter at the top:

```markdown
---
name: "explain-code"
description: "Explain the provided code snippet"
argument-hint: "<code or filename>"
allowed-tools: "read_file"
---

Explain the following code in detail:

$ARGUMENTS
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Command name (lowercase letters, numbers, hyphens; max 64 chars) |
| `description` | Yes | Shown in the command picker dropdown |
| `argument-hint` | No | Hint text shown next to the command name in the picker (e.g. `<filename>`) |
| `allowed-tools` | No | Comma-separated tool names to auto-approve when this command runs |

### Body

The body is free-form markdown sent to the LLM as a user message. Use `$ARGUMENTS` where the user's input should be inserted. If the body does not contain `$ARGUMENTS`, the command runs immediately on selection (no argument prompt).

---

## Scope

Commands can be either:

- **User commands** — owned by the creating user, only visible to them
- **Global commands** — visible to all users with access (filtered by groups and zones)

Global commands can be restricted to specific groups. Both types can be zone-restricted.

---

## Using Commands

In the AI assistant chat window, type `/` to open the command picker. Select a command or keep typing to filter. If the command accepts arguments, type them after the command name:

```
/explain-code def factorial(n): return 1 if n <= 1 else n * factorial(n-1)
```

Only active commands appear in the picker.

---

## Managed Commands

Commands marked as managed are read-only — they cannot be edited or deleted from the UI. Managed commands are typically provisioned by an administrator or via the API.

---

## Scripting

Slash commands can also be managed programmatically via the `knot.slash_command` library:

```python
import knot.slash_command

# List all commands
commands = knot.command.list()

# Create a global command
knot.command.create(
    content='---\nname: "greet"\ndescription: "Greet by name"\n---\n\nSay hello to $ARGUMENTS',
    is_global=True,
)

# Update a command
knot.command.update("greet", content='---\nname: "greet"\ndescription: "Greet warmly"\n---\n\nWarmly greet $ARGUMENTS')

# Delete a command
knot.command.delete("greet")
```

See the [knot.slash_command library reference](../../../reference/libraries/slash_command/) for full API details.
