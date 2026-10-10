---
title: knot.files
description: File storage from scripts — read, write, list, copy and delete files in buckets, and manage the buckets.
type: API Reference
tags: [files, storage, api]
weight: 45
---

The `knot.files` library works with [file storage](/docs/file-storage/): buckets of files replicated across the cluster. Scripts can read and write files, list and copy them, and create, share and delete buckets, as the user the script runs as, with the same permissions, sharing rules and quotas as the web interface and the `knot file` commands.

Buckets are named `<owner>--<name>`. Give your own buckets by their short name; buckets shared with you need the full name. File keys use `/` to organise files into folders, and may contain spaces and any other characters — the library encodes them.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| Health check scripts | Not available. |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

A script holds a file's content in memory, so one read or write is limited to 64 MB; use `knot file copy` for larger files. File storage must be enabled on the server (`server.files.path`), or calls fail with `file storage is not enabled on this server`.

---

## Functions

| Function | Description |
|----------|-------------|
| `list_files(bucket, prefix="", recursive=False)` | List the files in a bucket |
| `list_changes(bucket, prefix="", cursor="")` | List what changed in a bucket since a cursor |
| `read_file(bucket, key)` | Read a file's content as bytes |
| `read_text(bucket, key)` | Read a file's content as UTF-8 text |
| `write_file(bucket, key, data, content_type="")` | Write a file, replacing any file with that key |
| `delete_file(bucket, key)` | Delete a file |
| `copy_file(source_bucket, source_key, dest_bucket, dest_key)` | Copy a file on the server, within or between buckets |
| `file_exists(bucket, key)` | Check whether a file exists |
| `list_buckets(all=False)` | List the buckets you own or that are shared with you |
| `get_bucket(name)` | Get one bucket |
| `create_bucket(name)` | Create a bucket you own |
| `delete_bucket(name, force=False)` | Delete a bucket |
| `share_bucket(name, user=None, group=None, everyone=False, access="read")` | Share a bucket |
| `unshare_bucket(name, user=None, group=None, everyone=False)` | Stop sharing a bucket |
| `transfer_bucket(name, user, force=False)` | Give a bucket to another user |
| `usage()` | Your file storage usage and limits |

---

### list_files(bucket, prefix="", recursive=False)

List the files in a bucket.

**Parameters:**
- `bucket` (string): Bucket name
- `prefix` (string, optional): Only keys starting with this. End it with `/` for a folder.
- `recursive` (bool, optional): If `False`, files below the next `/` after the prefix are rolled up into folders; if `True`, every file below the prefix is listed

**Returns:** `dict` containing:
- `files` (list): Dicts with `key`, `size`, `etag`, `sha256`, `content_type` and `modified_at`
- `folders` (list): Folder prefixes, each ending in `/` (empty when `recursive`)

Every page of a large bucket is fetched.

---

### list_changes(bucket, prefix="", cursor="")

List what changed in a bucket since a cursor, to follow a bucket without listing it again.

**Parameters:**
- `bucket` (string): Bucket name
- `prefix` (string, optional): Only keys starting with this. End it with `/` for a folder.
- `cursor` (string, optional): The cursor from the last call. Without one every file is returned; `"now"` returns no files, only a cursor to follow the bucket from now on.

**Returns:** `dict` containing:
- `changes` (list): Dicts with `key`, `size`, `etag`, `sha256`, `content_type`, `modified_at` and `deleted`. Each file changed since the cursor appears once, as it is now; a deleted file has `deleted` set and only its `key` and `modified_at`.
- `cursor` (string): Pass it next time
- `reset` (bool): `True` when the cursor couldn't be followed — the server renumbered its changes after an unclean stop, or the cursor came from another server. `changes` is then empty: start again without a cursor.

```python
import knot.files as files

state = files.list_changes("configs", cursor="now")
# ... later ...
step = files.list_changes("configs", cursor=state["cursor"])
for f in step["changes"]:
    print(("deleted " if f["deleted"] else "changed ") + f["key"])
state = step
```

---

### read_file(bucket, key)

**Returns:** `bytes` - The file's content. Raises if the file does not exist.

### read_text(bucket, key)

**Returns:** `string` - The file's content decoded as UTF-8. Raises if the file does not exist or is not UTF-8.

---

### write_file(bucket, key, data, content_type="")

Write a file, replacing any file with that key. Folders need no creating.

**Parameters:**
- `bucket` (string): Bucket name
- `key` (string): The file's key, e.g. `app/settings.toml`
- `data` (string or bytes): The content; a string is written as UTF-8
- `content_type` (string, optional): Defaults to `text/plain; charset=utf-8` for a string and `application/octet-stream` for bytes

**Returns:** `dict` - The file's `key`, `size`, `etag`, `sha256`, `content_type` and `modified_at`

Raises if you may not write to the bucket, the owner's quota would be exceeded, or the key is invalid (empty, or with empty, `.` or `..` segments, or not valid UTF-8).

---

### delete_file(bucket, key)

**Returns:** `bool` - `True`. Raises if the file does not exist or you may not delete it.

---

### copy_file(source_bucket, source_key, dest_bucket, dest_key)

Copy a file within a bucket or to another, on the server: its content is not transferred, so the size makes no difference. Its content type, metadata and modification time are kept, and any file at the destination is replaced. You need read access to the source and write access to the destination, and the destination bucket's owner is charged for the new file.

**Returns:** `dict` - The copy's file dict. Raises if the file does not exist, access is lacking, the quota would be exceeded, or source and destination are the same file.

---

### file_exists(bucket, key)

**Returns:** `bool` - `True` if there is a file with exactly this key. A folder name is not a file.

---

### list_buckets(all=False)

List the buckets you own or that are shared with you; `all=True` lists every bucket (file storage managers only).

**Returns:** `list` of dicts, each containing:
- `name` (string): The full name, `<owner>--<name>`
- `display_name` (string): The short name for your own buckets, else the full name
- `owner`, `owner_id` (string): The owner's username and id
- `access` (string): Your access: `owner`, `write` or `read`
- `size` (int), `count` (int): Bytes and number of files
- `shared` (list): Dicts with `type` (`user`, `group` or `all`), `name` and `access` (`read` or `write`); filled in only for the owner and file storage managers
- `created_at` (string): Creation timestamp

### get_bucket(name)

**Returns:** `dict` - The bucket, as in `list_buckets`. Raises if it does not exist or is not visible to you.

### create_bucket(name)

Create a bucket named `<your username>--<name>`.

**Parameters:**
- `name` (string): The short name: 3–30 lowercase letters, digits and hyphens, with no `--`

**Returns:** `dict` - The bucket. Raises if you may not own buckets, are at your bucket limit, or the name is invalid or taken.

### delete_bucket(name, force=False)

Delete a bucket. A bucket that holds files is refused unless `force=True`, which deletes the files with it.

**Returns:** `bool` - `True`

---

### share_bucket(name, user=None, group=None, everyone=False, access="read")

Share a bucket with exactly one of a user (username or email), a group or everyone. `access` is `"read"` or `"write"`. Sharing again with the same user or group changes their access. Needs the Share Buckets permission.

**Returns:** `dict` - The bucket, with its `shared` list updated.

### unshare_bucket(name, user=None, group=None, everyone=False)

Stop sharing a bucket with exactly one of a user, a group or everyone.

**Returns:** `dict` - The bucket.

### transfer_bucket(name, user, force=False)

Give a bucket to another user, who must be allowed to own buckets. It is renamed into their namespace and their quota is charged; the move is refused when it would take them over their limits, unless a file storage manager gives `force=True`. Needs the Transfer Buckets permission.

**Returns:** `dict` - The bucket, with its new name.

### usage()

**Returns:** `dict` containing `used_bytes`, `files` and `buckets` (what you own), and `quota_bytes` and `max_buckets` (your limits, `0` for none).

---

## Examples

```python
import knot.files as files

# Keep a small config in a bucket
files.create_bucket("configs")
files.write_file("configs", "app/settings.toml", "debug = true\n")
print(files.read_text("configs", "app/settings.toml"))

# Binary content is bytes
files.write_file("configs", "icons/logo.png", open_logo_bytes())
data = files.read_file("configs", "icons/logo.png")

# Walk a bucket
listing = files.list_files("configs", recursive=True)
for f in listing["files"]:
    print(f["key"], f["size"])

# Copy between buckets on the server, then share the result
files.copy_file("configs", "app/settings.toml", "backups", "2026-10-05/settings.toml")
files.share_bucket("backups", group="ops", access="read")

# Only write what is missing
if not files.file_exists("configs", "app/defaults.toml"):
    files.write_file("configs", "app/defaults.toml", "retries = 3\n")
```
