---
title: knot.space
weight: 10
---

The `knot.space` library provides space management functions for scripts.

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
| `create(name, template_name, description='', shell='bash', depends_on=None, stack='', selected_node_id='', alt_names=None, icon_url='', custom_fields=None, startup_script_id='', start_on_create=False)` | Create a new space |
| `delete(name)` | Delete a space by name |
| `get(name)` | Get detailed space information |
| `update(name, new_name=None, ...)` | Update space properties |
| `start(name)` | Start a space |
| `stop(name)` | Stop a space |
| `restart(name)` | Restart a space |
| `list(all_zones=False)` | List all spaces for the current user |
| `is_running(name)` | Check if a space is running |
| `usage_current(name)` | Get current resource usage for a space |
| `usage_history(name, range='1h')` | Get historical resource usage for a space |
| `get_description(name)` | Get the description of a space |
| `set_description(name, description)` | Set the description of a space |
| `get_dependencies(name)` | Get the dependency space IDs for a space |
| `set_dependencies(name, depends_on)` | Set the dependency spaces for a space |
| `get_stack(name)` | Get the stack name for a space |
| `set_stack(name, stack)` | Set the stack name for a space |
| `get_field(name, field)` | Get a custom field value |
| `set_field(name, field, value)` | Set a custom field value |
| `transfer(name, user_id)` | Transfer space ownership |
| `share(name, user_ids)` | Share space with one or more users |
| `unshare(name, user_id=None)` | Remove space share, optionally for a specific user |
| `run_script(space_name, script_name, args=None)` | Execute a script in a space |
| `eval(space_name, code, args=None)` | Execute inline Scriptling code in a space |
| `run(space_name, command, args=[], timeout=30, workdir='')` | Execute a command in a space |
| `read_file(space_name, file_path, offset=0, limit=0)` | Read file contents (or a 1-based line range) from a space |
| `write_file(space_name, file_path, content, mode='overwrite')` | Write content to a file (overwrite/append/prepend) |
| `grep(space_name, pattern, path, ...)` | Search file contents (regex or literal) |
| `find(space_name, path='.', ...)` | Find files/directories by name, type, mtime, size |
| `sed_replace(space_name, old, new, path, ...)` | Replace literal string in files (in-place) |
| `sed_replace_pattern(space_name, pattern, new, path, ...)` | Replace regex matches in files (in-place) |
| `sed_extract(space_name, pattern, path, ...)` | Extract regex capture groups from files |
| `edit_file(space_name, file_path, search, replace, ...)` | Targeted search-and-replace edit (unique match required) |
| `port_forward(source_space, local_port, remote_space, remote_port, persistent=False, force=False)` | Forward a port between spaces |
| `port_apply(source_space, forwards)` | Replace all port forwards with the given list |
| `port_list(space)` | List active port forwards |
| `port_stop(space, local_port)` | Stop a port forward |
| `tunnel_start(space, protocol, port, name)` | Start an agent-owned web tunnel in a space |
| `tunnel_list(space)` | List agent-owned web tunnels in a space |
| `tunnel_stop(space, name)` | Stop an agent-owned web tunnel in a space |

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

### create(name, template_name, description='', shell='bash', depends_on=None, stack='', selected_node_id='', alt_names=None, icon_url='', custom_fields=None, startup_script_id='', start_on_create=False)

Create a new space.

**Parameters:**
- `name` (string): Name for the new space
- `template_name` (string): Name of the template to use
- `description` (string, optional): Description for the space
- `shell` (string, optional): Shell to use (default: "bash")
- `depends_on` (list, optional): List of dependency space names or IDs
- `stack` (string, optional): Stack name to group this space under
- `selected_node_id` (string, optional): Node ID to assign for local-container spaces. Leave empty to auto-select.
- `alt_names` (list, optional): Additional HTTP route names, each with `name` and `port`
- `icon_url` (string, optional): Icon URL
- `custom_fields` (list, optional): Custom field values as `{"name": "...", "value": "..."}`
- `startup_script_id` (string, optional): Startup script ID
- `start_on_create` (bool, optional): Start the space immediately after it is created

**Returns:** `string` - The space ID of the newly created space

---

### update(name, new_name=None, ...)

Update a space while preserving fields you do not pass.

**Parameters:**
- `name` (string): Name or ID of the space to update
- `new_name` (string, optional): New space name
- `description` (string, optional): New description
- `shell` (string, optional): New default shell
- `template_name` (string, optional): New template name or ID
- `depends_on` (list, optional): New dependency space names or IDs
- `stack` (string, optional): New stack name, or empty string to unstack
- `selected_node_id` (string, optional): New node ID where allowed
- `alt_names` (list, optional): New additional route names
- `icon_url` (string, optional): New icon URL
- `custom_fields` (list, optional): New custom field values
- `startup_script_id` (string, optional): New startup script ID

**Returns:** `bool` - True on success

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

### usage_current(name)

Get the current resource usage point for a space.

**Parameters:**
- `name` (string): Name or ID of the space

**Returns:** `dict` containing the current usage point, including `bucket_start`, `bucket_kind`, `is_live`, and `resource_usage`.

---

### usage_history(name, range='1h')

Get historical resource usage points for a space.

**Parameters:**
- `name` (string): Name or ID of the space
- `range` (string, optional): `"1h"` for minute samples or `"7d"` for daily samples

**Returns:** `dict` containing `space_id`, `range`, `bucket_kind`, and `points`.

---

### run_script(space_name, script_name, args=None)

Execute a named script in a running space.

**Parameters:**
- `space_name` (string): Name or ID of the space
- `script_name` (string): Name of the script to execute
- `args` (list, optional): Script arguments

**Returns:** `dict` with `output` and `exit_code`

---

### eval(space_name, code, args=None)

Execute inline Scriptling code in a running space. Unlike `run_script`, which
looks up a stored script by name, `eval` sends the `code` directly so no script
needs to exist in the database. The code runs in the target space's agent with
the same permissions, libraries, and argument conventions as a named script
(`argv[0]` is `"inline"`).

**Parameters:**
- `space_name` (string): Name or ID of the space
- `code` (string): Scriptling source to evaluate
- `args` (list, optional): Script arguments

**Returns:** `dict` with `output`, `error` (empty string on success), and `exit_code`

```python
import knot.space as space

result = space.eval("my-space", "print('hello from space')")
print(result["output"])
```

---

### read_file(space_name, file_path, offset=0, limit=0)

Read file contents from a running space, optionally a 1-based line range. When
both `offset` and `limit` are 0/omitted the whole file is returned (the default).
The full file is read by the agent, but the response is sliced server-side so
the client only receives the requested lines.

**Parameters:**
- `space_name` (string): Name of the space
- `file_path` (string): Path to the file
- `offset` (int, optional): 1-based line number to start at. `0` = from the beginning
- `limit` (int, optional): Maximum number of lines to return. `0` = no limit (whole file)

**Returns:** `string` - File contents (or the requested line range)

```python
import knot.space as space
# Read lines 100-119 of a large file
chunk = space.read_file("web", "/var/log/app.log", offset=100, limit=20)
```

---

### write_file(space_name, file_path, content, mode='overwrite')

Write content to a file in a running space. By default the file is overwritten;
pass `mode='append'` to add to the end, or `mode='prepend'` to add to the
beginning of an existing file.

**Parameters:**
- `space_name` (string): Name of the space
- `file_path` (string): Path to the file
- `content` (string): Content to write
- `mode` (string, optional): `"overwrite"` (default), `"append"`, or `"prepend"`

**Returns:** `bool` - True on success

---

### grep(space_name, pattern, path, literal=False, recursive=False, ignore_case=False, glob='', follow_links=False, max_size=0, workdir='')

Search file contents in a running space using a regex or literal pattern. Runs
in the space's agent via a parallel worker pool — no file contents leave the
space, only matching lines are returned.

**Parameters:**
- `space_name` (string): Name or ID of the space
- `pattern` (string): Regular expression (or literal string when `literal=True`)
- `path` (string): File or directory to search (relative to `workdir` if given)
- `literal` (bool, optional): Treat `pattern` as a literal string. Default `False`
- `recursive` (bool, optional): Recurse into subdirectories. Default `False`
- `ignore_case` (bool, optional): Case-insensitive matching. Default `False`
- `glob` (string, optional): Only search files matching this glob, e.g. `"*.py"`
- `follow_links` (bool, optional): Follow symlinks. Default `False`
- `max_size` (int, optional): Skip files larger than this many bytes. `0` = default 1 MiB, negative = unlimited
- `workdir` (string, optional): Resolve relative `path` against this directory

**Returns:** `list` of match dicts `{"file": str, "line": int, "text": str}`

```python
import knot.space as space
for m in space.grep("web", "TODO", "src", recursive=True, glob="*.py"):
    print(f"{m['file']}:{m['line']}: {m['text']}")
```

---

### find(space_name, path='.', recursive=True, type='any', name_glob='', mtime_min=None, mtime_max=None, size_min=None, size_max=None, include_hidden=False, follow_links=False, max_depth=0, workdir='')

Find files and directories in a running space by name, type, modification time,
or size. Runs in the space's agent via a concurrent walker; recursive by default.

**Parameters:**
- `space_name` (string): Name or ID of the space
- `path` (string, optional): Directory (or file) to search under. Default `"."`
- `recursive` (bool, optional): Descend into subdirectories. Default `True`
- `type` (string, optional): `"file"`, `"dir"`, or `"any"`. Default `"any"`
- `name_glob` (string, optional): Shell-style glob matched against the base name
- `mtime_min` / `mtime_max` (float, optional): Epoch-time bounds (seconds)
- `size_min` / `size_max` (int, optional): Size bounds in bytes
- `include_hidden` (bool, optional): Match dot-entries. Default `False`
- `follow_links` (bool, optional): Follow symlinks. Default `False`
- `max_depth` (int, optional): Maximum recursion depth. `0` = unlimited
- `workdir` (string, optional): Resolve relative `path` against this directory

**Returns:** `list` of matching path strings (arbitrary order)

---

### sed_replace(space_name, old, new, path, recursive=False, ignore_case=False, glob='', follow_links=False, max_size=0, workdir='')

Replace every literal occurrence of `old` with `new` in a file (or files under a
directory). `old` is matched literally, not as a regular expression. Files are
modified in place using an atomic temp-file + rename.

**Parameters:**
- `space_name` (string): Name or ID of the space
- `old` (string): Literal string to search for
- `new` (string): Replacement string
- `path` (string): File or directory to modify
- `recursive` (bool, optional): Default `False`
- `ignore_case` (bool, optional): Default `False`
- `glob` (string, optional): Only modify files matching this glob
- `follow_links` (bool, optional): Default `False`
- `max_size` (int, optional): Skip files larger than this many bytes
- `workdir` (string, optional): Resolve relative `path` against this directory

**Returns:** `int` - the number of files modified

---

### sed_replace_pattern(space_name, pattern, new, path, recursive=False, ignore_case=False, glob='', follow_links=False, max_size=0, workdir='')

Replace every regex match of `pattern` with `new`. Capture groups may be
referenced in `new` as `${1}`, `${2}`, or `${name}`. Files are modified in place
using an atomic temp-file + rename.

**Parameters:** as `sed_replace`, with `pattern` interpreted as a regular
expression (Go regexp syntax) instead of a literal string.

**Returns:** `int` - the number of files modified

```python
import knot.space as space
# Rename get_* functions to fetch_*
n = space.sed_replace_pattern("web", r"def get_(\w+)\(", "def fetch_${1}(", "src/app.py")
print(f"{n} file(s) modified")
```

---

### sed_extract(space_name, pattern, path, recursive=False, ignore_case=False, glob='', follow_links=False, max_size=0, workdir='')

Extract regex capture groups from a file (or files under a directory). Read-only
— does not modify files.

**Parameters:**
- `space_name` (string): Name or ID of the space
- `pattern` (string): Regular expression with capture groups
- `path` (string): File or directory to search
- `recursive` (bool, optional): Default `False`
- `ignore_case` (bool, optional): Default `False`
- `glob` (string, optional): Only search files matching this glob
- `follow_links` (bool, optional): Default `False`
- `max_size` (int, optional): Skip files larger than this many bytes
- `workdir` (string, optional): Resolve relative `path` against this directory

**Returns:** `list` of match dicts `{"file": str, "line": int, "text": str, "groups": [str, ...]}`

---

### edit_file(space_name, file_path, search, replace, workdir='')

Perform a targeted search-and-replace edit on a single file. The search text
must appear **exactly once** in the file; the operation fails if it matches zero
or multiple times. The modification is written atomically (temp file + rename).

Unlike `sed_replace` (which replaces **all** occurrences), `edit_file` targets
**one** specific occurrence with uniqueness verification — the gold standard for
coding-agent edits where "replace all" is dangerous. Provide enough surrounding
context in `search` to make the match unique.

**Parameters:**
- `space_name` (string): Name or ID of the space
- `file_path` (string): Path to the file to edit
- `search` (string): Exact text to find (may span multiple lines)
- `replace` (string): Replacement text
- `workdir` (string, optional): Resolve relative `file_path` against this directory

**Returns:** `int` - bytes written

**Raises:** Exception if the search text is not found, matches multiple times, or the agent fails.

```python
import knot.space as space
# Replace a specific function definition (unique match)
n = space.edit_file("web", "src/app.py",
    search="def get_user(id):\n    pass",
    replace="def fetch_user(user_id):\n    return User(user_id)")
```

---

### get_dependencies(name)

Get the dependency space IDs for a space.

**Parameters:**
- `name` (string): Name or ID of the space

**Returns:** `list` - List of dependency space IDs

---

### set_dependencies(name, depends_on)

Set the dependency spaces for a space. Dependencies are required to be started before the space starts.

**Parameters:**
- `name` (string): Name or ID of the space
- `depends_on` (list): List of dependency space names or IDs

**Returns:** `bool` - True on success

---

### list(all_zones=False)

List all spaces for the current user.

**Parameters:**
- `all_zones` (bool, optional): If True, include spaces from all zones. Default is False (only spaces in the current server's zone).

**Returns:** `list` of dicts, each containing:
- `id` (string): Space ID
- `name` (string): Space name
- `is_running` (bool): Whether the space is running
- `description` (string): Space description

---

### get(name)

Get detailed information about a space.

**Parameters:**
- `name` (string): Name or ID of the space

**Returns:** `dict` containing:
- `id` (string): Space ID
- `name` (string): Space name
- `description` (string): Space description
- `template_id` (string): Template ID
- `template_name` (string): Template name
- `user_id` (string): Owner user ID
- `username` (string): Owner username
- `shares` (list): List of shared user IDs
- `depends_on` (list): List of dependency space IDs
- `shell` (string): Default shell
- `platform` (string): Platform (e.g., "linux/amd64")
- `zone` (string): Zone name
- `is_running` (bool): Whether the space is running
- `is_pending` (bool): Whether the space is pending
- `is_deleting` (bool): Whether the space is being deleted
- `node_id` (string): ID of the node assigned to host the space
- `node_hostname` (string): Hostname of the node assigned to host the space
- `created_at` (string): Creation timestamp
- `alt_names` (list of objects): Additional space names, each with `name` (string) and `port` (string, the HTTP port number to route to)
- `icon_url` (string): Icon URL
- `custom_fields` (list): Custom field values
- `startup_script_id` (string): Startup script ID
- `stack` (string): Stack name (empty if unstacked)

---

### get_stack(name)

Get the stack name for a space.

**Parameters:**
- `name` (string): Name or ID of the space

**Returns:** `string` - The stack name (empty string if unstacked)

---

### set_stack(name, stack)

Set the stack name for a space. Spaces with the same stack name are grouped together.

**Parameters:**
- `name` (string): Name or ID of the space
- `stack` (string): Stack name (empty string to unstack)

**Returns:** `bool` - True on success

---

### share(name, user_ids)

Share a space with one or more users.

**Parameters:**
- `name` (string): Name or ID of the space
- `user_ids` (string or list): User ID, username, or email to share with, or a list of those values

**Returns:** `bool` - True on success

---

### unshare(name, user_id=None)

Remove a space share.

**Parameters:**
- `name` (string): Name or ID of the space
- `user_id` (string, optional): User ID, username, or email to remove sharing for. If omitted, owners stop all sharing and recipients leave their own share.

**Returns:** `bool` - True on success

---

### transfer(name, user_id)

Transfer space ownership to another user.

**Parameters:**
- `name` (string): Name or ID of the space
- `user_id` (string): User ID, username, or email of the new owner

**Returns:** `bool` - True on success

---

### port_apply(source_space, forwards)

Replace all port forwards for a space with the given list. Any existing forwards not in the list are stopped, and any new forwards in the list are started. Forwards that already exist with the same local port, space, and remote port are left unchanged.

**Parameters:**
- `source_space` (string): Source space name or ID
- `forwards` (list): List of dicts, each containing:
  - `local_port` (int): Local port number
  - `space` (string): Remote space name or ID
  - `remote_port` (int): Remote port number
  - `persistent` (bool, optional): Persist the forward across restarts (default: False)
  - `force` (bool, optional): Skip validation checks (default: False)

**Returns:** `dict` containing:
- `applied` (list): List of forwards that were started
- `stopped` (list): List of forwards that were stopped
- `errors` (list): List of error messages (if any)

---

### tunnel_start(space, protocol, port, name)

Start an agent-owned web tunnel in a space, exposing a port inside the space on the internet as `<user>--<name>.<domain>`. The tunnel is owned by the space's agent and runs until the agent exits or the tunnel is stopped; it is not persisted. The space must be running.

**Parameters:**
- `space` (string): Space name or ID
- `protocol` (string): `"http"` or `"https"`
- `port` (int): The port within the space to tunnel
- `name` (string): The tunnel name (forms `<user>--<name>.<domain>`)

**Returns:** `string` - The public tunnel URL

---

### tunnel_list(space)

List the agent-owned web tunnels active in a space.

**Parameters:**
- `space` (string): Space name or ID

**Returns:** `list` of dicts, each containing:
- `port` (int): Port within the space
- `protocol` (string): `"http"` or `"https"`
- `name` (string): Tunnel name
- `url` (string): Public tunnel URL

---

### tunnel_stop(space, name)

Stop an agent-owned web tunnel in a space by name.

**Parameters:**
- `space` (string): Space name or ID
- `name` (string): The tunnel name

**Returns:** `bool` - True on success
