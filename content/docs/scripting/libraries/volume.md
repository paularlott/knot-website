---
title: knot.volume
weight: 60
---

The `knot.volume` library provides volume management functions. Volumes are CSI volume definitions that can be attached to spaces.

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all volumes |
| `get(volume_id)` | Get volume by ID or name |
| `nodes(platform)` | List available nodes for a platform |
| `create(name, definition, platform='', node_id='')` | Create a new volume |
| `update(volume_id, ...)` | Update volume properties |
| `delete(volume_id)` | Delete a volume |
| `start(volume_id)` | Start a volume |
| `stop(volume_id)` | Stop a volume |
| `is_running(volume_id)` | Check if volume is running |

---

## Usage

```python
import knot.volume as volume

# List all volumes
volumes = volume.list()
for v in volumes:
    status = "active" if v['active'] else "inactive"
    print(f"{v['name']}: {status} ({v['platform']}) node={v['node_hostname']}")

# List available nodes for docker platform
nodes = volume.nodes("docker")
for n in nodes:
    print(f"{n['hostname']} ({n['node_id']})")

# Create a volume on a specific node
volume_id = volume.create(
    "my-volume",
    definition="type: host\npath: /data",
    platform="docker",
    node_id=nodes[0]['node_id']
)

# Create a volume with auto node selection
volume_id = volume.create(
    "my-volume",
    definition="type: host\npath: /data",
    platform="docker"
)

# Start a volume
volume.start("my-volume")

# Check if running
if volume.is_running("my-volume"):
    print("Volume is active")

# Stop a volume
volume.stop("my-volume")
```

---

## Volume Properties

Volumes contain:
- `id` - Volume ID
- `name` - Volume name
- `definition` - Volume definition YAML (from `get()` only)
- `active` - Whether the volume is active/running
- `zone` - Zone where volume is running
- `node_id` - ID of the node the volume is assigned to
- `node_hostname` - Hostname of the node the volume is assigned to
- `platform` - Platform type (docker, podman, nomad, etc.)

---

## Node Properties

Nodes returned by `nodes()` contain:
- `node_id` - Node ID
- `hostname` - Node hostname

---

## Definition Format

The volume definition is a YAML string that defines the CSI volume configuration. Example:

```yaml
type: host
path: /data
```
