---
title: Volume Specification
linkTitle: Volume Spec
description: The YAML schema for volumes and managed host paths used by local container templates and standalone volumes.
type: Guide
tags: [templates, storage, configuration]
weight: 30
---

Local Container templates and local standalone volumes use the same `volumes` YAML schema for `container`, `docker`, `podman`, and `apple` platforms. Templates can also define managed host paths with `paths`.

The definition is a top-level `volumes` map whose keys are the local volume names:

```yaml
volumes:
  workspace:
  cache:
paths:
  - workspace-dir
  - ~/knot-workspace
  - /storage/${{ .space.id }}/data
```

---

## Volume Specification Details

### **volumes**

A map of local volume names to create. When a space or volume is started, **knot** instructs the selected container runtime to create these volumes automatically.

For template volume definitions you can define multiple entries. For standalone volumes the definition must contain exactly one volume.

### **paths**

A list of host directories to create before a local-container space starts and remove when the space is deleted. Use paths when the container should bind mount a host directory instead of using a runtime-managed named volume.

Path resolution follows the agent process:

- `~/example` is created under the server user's home directory.
- `/example` is treated as an absolute path.
- `example` is relative to the agent working directory.

Declare the path in the template volume definition, then reference the same value as the source in the container specification:

```yaml
paths:
  - workspace-dir
```

```yaml
volumes:
  - workspace-dir:/workspace
```

Standalone volumes do not support `paths`; they must contain exactly one entry in the `volumes` map.
