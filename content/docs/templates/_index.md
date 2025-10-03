---
title: Templates
weight: 50
---

Templates in **knot** are used to define environments based on either Nomad or Local Containers (Docker, Podman, or Apple Container). These templates can include one or more volumes as part of their definition, providing flexibility and persistence for your spaces.

---

### Volumes and Space Lifecycle

- When a space is first started, all volumes defined in the template are created.
- **Starting and stopping a space**:
  Volumes are not destroyed when a space is stopped and restarted.
- **Deleting a space**:
  Volumes are removed only when the space is deleted.
- **Template changes**:
  If volumes are removed from the template, they will be deleted the next time the space is started.

---

### Storage Systems

- **Nomad-based templates**:
  Volumes are allocated using storage systems provided by Container Storage Interface (CSI) plugins.

- **Local Container-based templates**:
  Volumes are allocated using the storage system provided by the selected container runtime (Docker, Podman, or Apple Container).
