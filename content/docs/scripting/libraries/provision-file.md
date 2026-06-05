---
title: scriptling.provision.file
weight: 150
---

File provisioning library for creating and updating files with correct permissions. Idempotent — only writes when content changes.

---

## Functions

| Function | Description |
|----------|-------------|
| `ensure(path, content, mode=0o644)` | Ensure a file exists with the given content |
| `absent(path)` | Remove a file if it exists |
| `ensure_directory(path, mode=0o755)` | Ensure a directory exists |
| `absent_directory(path)` | Remove an empty directory if it exists |

## Constants

| Constant | Value |
|----------|-------|
| `file.CREATED` | `"created"` |
| `file.UPDATED` | `"updated"` |
| `file.UNCHANGED` | `"unchanged"` |
| `file.REMOVED` | `"removed"` |
| `file.ABSENT` | `"absent"` |
| `file.EXISTS` | `"exists"` |

---

## ensure

```python
ensure(path: str, content: str, mode: int = 0o644) -> str
```

Creates parent directories if needed. If the file already exists with the same content, it is left unchanged. Otherwise the file is written with the specified mode.

### Constants

| Constant | Value |
|----------|-------|
| `file.CREATED` | `"created"` |
| `file.UPDATED` | `"updated"` |
| `file.UNCHANGED` | `"unchanged"` |
| `file.REMOVED` | `"removed"` |
| `file.ABSENT` | `"absent"` |
| `file.EXISTS` | `"exists"` |

---

## Usage

```python
import scriptling.provision.file as file

# Provision a git config
status = file.ensure("~/.gitconfig", """[user]
    name = Jane Doe
    email = jane@example.com
""", mode=0o600)

if status == file.CREATED:
    print("Git config created")
elif status == file.UPDATED:
    print("Git config updated")

# Remove a file
status = file.absent("~/.old_config")

# Ensure a directory exists
status = file.ensure_directory("~/.config/myapp", mode=0o700)

# Remove an empty directory
status = file.absent_directory("~/old/empty/dir")
```

---

## Environment Compatibility

| MCP | Remote | External |
|-----|--------|----------|
| ✗   | ✓      | ✓        |
