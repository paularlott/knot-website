---
title: knot.script
weight: 42
---

The `knot.script` library provides script management and script execution functions.

---

## Functions

| Function | Description |
|----------|-------------|
| `list(owner=None, all_zones=False)` | List scripts visible to the current user |
| `list_global(all_zones=False)` | List global scripts available for template editing |
| `get(script_id)` | Get script details by UUID |
| `get_by_name(name)` | Get script details by name |
| `get_content(name, script_type='script')` | Get script content by name and type |
| `create(name, content, ...)` | Create a script |
| `update(script_id, ...)` | Update a script |
| `delete(script_id)` | Delete a script |
| `execute(space_name, script_name=None, script_id=None, content=None, args=None)` | Execute a script in a running space |
| `execute_content(space_name, content, args=None)` | Execute inline script content in a running space |

---

## Usage

```python
import knot.script as script

# List visible scripts
for s in script.list():
    print(f"{s['name']}: {s['script_type']}")

# Create an own script
script_id = script.create(
    "hello",
    "print('hello from script')",
    description="Example script",
    owner="current",
)

# Execute a named script in a running space
result = script.execute("my-space", script_name="hello", args=["--verbose"])
print(result["output"])
```

---

## Script Properties

Scripts contain:
- `id` - Script ID
- `user_id` - Owner user ID, or empty for global scripts
- `name` - Script name
- `description` - Description
- `content` - Script content, returned by detail functions
- `groups` - Group IDs that can access a global script
- `zones` - Zone restrictions
- `active` - Whether the script is active
- `script_type` - Script type (`script`, `lib`, or `tool`)
- `mcp_input_schema_toml` - MCP tool input schema TOML for tool scripts
- `mcp_keywords` - Keywords used for MCP tool discovery
- `discoverable` - Whether an MCP tool script is available through discovery rather than native tool listing
- `is_managed` - Whether the script is managed by the system

---

## Creating Scripts

```python
import knot.script as script

# Global script
global_id = script.create(
    "backup",
    "print('backup')",
    description="Run backup",
)

# Own script
own_id = script.create(
    "my-helper",
    "print('helper')",
    owner="current",
)

# MCP tool script
tool_id = script.create(
    "check_status",
    "import scriptling.mcp.tool as tool\ntool.return_string('ok')",
    script_type="tool",
    mcp_keywords=["status", "check"],
    discoverable=True,
)
```

---

## Execution

`execute()` accepts exactly one of `script_name`, `script_id`, or `content`.

```python
import knot.script as script

# By script name
script.execute("my-space", script_name="deploy", args=["prod"])

# By script ID
script.execute("my-space", script_id="script-uuid")

# Inline content
script.execute_content("my-space", "print('hello')")
```

Execution returns:
- `output` - Script output
- `error` - Error text if the script failed
- `exit_code` - Script exit code

