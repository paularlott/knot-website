---
title: Volume Specification
weight: 30
---

The volume specification for Docker/Podman is straightforward: it consists of a list of volume names, which can include template variables.

```yaml
volumes:
  <volume name>:
```

---

## Volume Specification Details

### **volumes**

A list of volume names to be created. When a space is started, **knot** instructs Docker or Podman to create these volumes automatically.
