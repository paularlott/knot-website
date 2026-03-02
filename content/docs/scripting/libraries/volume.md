---
title: knot.volume
weight: 60
---

The `knot.volume` library provides volume management functions.

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all volumes |
| `get(volume_id)` | Get volume by ID or name |
| `create(name, ...)` | Create a new volume |
| `update(volume_id, ...)` | Update volume properties |
| `delete(volume_id)` | Delete a volume |

---

## Usage

```python
import knot.volume as volume

# List all volumes
volumes = volume.list()
for v in volumes:
    print(f"{v['name']}: {v['size']}")

# Get a volume
v = volume.get("my-volume")
print(v['path'])
```
