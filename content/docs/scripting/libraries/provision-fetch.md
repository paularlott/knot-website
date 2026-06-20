---
title: scriptling.provision.fetch
weight: 155
---

Fetch provisioning utilities for downloading files and unpacking zip archives. Available in all environments except MCP.

---

## Functions

| Function | Description |
|----------|-------------|
| `file(url, dest, *, insecure=False, unpack_zip=False, timeout=30, max_bytes=0, mode=0o644, dir_mode=0o755)` | Fetch a file over HTTP/HTTPS and write it to `dest`. Parent directories are created automatically. When `unpack_zip=True`, `dest` is treated as a directory and the response body is unpacked as a zip archive. |

---

## Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `CREATED` | `"created"` | File was newly created |
| `UPDATED` | `"updated"` | File existed but content differed |
| `UNCHANGED` | `"unchanged"` | File existed with identical content |

---

## Return Value

`file()` returns a dict:

```python
{
    "status": "created",  # CREATED, UPDATED, or UNCHANGED
    "url": "https://example.com/app.conf",
    "path": "~/.config/app/app.conf",
    "bytes": 1024,
    "unpacked": False,
    "files": ["~/.config/app/app.conf"],
}
```

---

## Example

```python
import scriptling.provision.fetch as fetch

# Fetch a single file
result = fetch.file("https://example.com/app.conf", "~/.config/app/app.conf")
if result["status"] != fetch.UNCHANGED:
    print("Fetched " + result["path"])

# Fetch and unpack a zip archive
archive = fetch.file("https://example.com/site.zip", "/srv/site", unpack_zip=True)
print("Extracted " + str(len(archive["files"])) + " files")
```

---

## Security

- Only `http://` and `https://` URLs are supported.
- Zip extraction is constrained to `dest`; entries that would escape the target directory are rejected.
- `max_bytes` caps the response size to prevent unbounded downloads.
