---
title: Volume Specification
weight: 30
---

Local Container templates and local standalone volumes share the same YAML schema for `container`, `docker`, `podman`, and `apple` platforms.

The definition is a top-level `volumes` map whose keys are the local volume names:

```yaml
volumes:
  workspace:
  cache:
```

---

## Volume Specification Details

### **volumes**

A map of local volume names to create. When a space or volume is started, **knot** instructs the selected container runtime to create these volumes automatically.

For template volume definitions you can define multiple entries. For standalone volumes the definition must contain exactly one volume.
