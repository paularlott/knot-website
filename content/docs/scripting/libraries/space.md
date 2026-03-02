---
title: knot.space
weight: 10
---

The `knot.space` library provides space management functions for scripts.

---

## Functions

| Function | Description |
|----------|-------------|
| `create(name, template_name, description='', shell='bash')` | Create a new space |
| `delete(name)` | Delete a space by name |
| `get(name)` | Get detailed space information |
| `update(name, description='', shell='')` | Update space properties |
| `start(name)` | Start a space |
| `stop(name)` | Stop a space |
| `restart(name)` | Restart a space |
| `list()` | List all spaces for the current user |
| `is_running(name)` | Check if a space is running |
| `get_description(name)` | Get the description of a space |
| `set_description(name, description)` | Set the description of a space |
| `get_field(name, field)` | Get a custom field value |
| `set_field(name, field, value)` | Set a custom field value |
| `transfer(name, user_id)` | Transfer space ownership |
| `share(name, user_id)` | Share space with another user |
| `unshare(name)` | Remove space share |
| `run_script(space_name, script_name, *args)` | Execute a script in a space |
| `run(space_name, command, args=[], timeout=30, workdir='')` | Execute a command in a space |
| `read_file(space_name, file_path)` | Read file contents from a space |
| `write_file(space_name, file_path, content)` | Write content to a file in a space |
| `port_forward(source_space, local_port, remote_space, remote_port)` | Forward a port between spaces |
| `port_list(space)` | List active port forwards |
| `port_stop(space, local_port)` | Stop a port forward |

---

## Usage

```python
import knot.space as space

# List all spaces
spaces = space.list()
for s in spaces:
    print(f"{s['name']}: {'running' if s['is_running'] else 'stopped'}")

# Create a new space
space_id = space.create("my-space", "ubuntu", description="My dev environment")

# Start a space
space.start("my-space")

# Execute a command
output = space.run("my-space", "ls", args=["-la", "/tmp"])
print(output)

# Read a file
content = space.read_file("my-space", "/etc/hostname")
print(content)
```

---

## Function Details

### create(name, template_name, description='', shell='bash')

Create a new space.

**Parameters:**
- `name` (string): Name for the new space
- `template_name` (string): Name of the template to use
- `description` (string, optional): Description for the space
- `shell` (string, optional): Shell to use (default: "bash")

**Returns:** `string` - The space ID of the newly created space

---

### run(space_name, command, args=[], timeout=30, workdir='')

Execute a command in a running space.

**Parameters:**
- `space_name` (string): Name of the space
- `command` (string): Command to execute
- `args` (list, optional): Arguments for the command
- `timeout` (int, optional): Timeout in seconds (default: 30)
- `workdir` (string, optional): Working directory

**Returns:** `string` - Command output

---

### read_file(space_name, file_path)

Read file contents from a running space.

**Parameters:**
- `space_name` (string): Name of the space
- `file_path` (string): Path to the file

**Returns:** `string` - File contents

---

### write_file(space_name, file_path, content)

Write content to a file in a running space.

**Parameters:**
- `space_name` (string): Name of the space
- `file_path` (string): Path to the file
- `content` (string): Content to write

**Returns:** `bool` - True on success
