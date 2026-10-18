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

A map of local volume names to create. When a space or volume is started, Knot instructs the selected container runtime to create these volumes automatically.

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

### **driver** and **driver_opts**

A volume can be made with a volume driver and its options, as `docker volume create --driver ... --opt ...` and a Compose file's `driver_opts` do. They are supported on the `docker` and `podman` platforms, and on `container` templates when the space runs on Docker or Podman; Apple Containers has no volume drivers, so its templates and volumes are refused with them.

```yaml
volumes:
  <volume name>:
    driver: <driver, default local>
    driver_opts:
      <option>: <value>
```

`driver` defaults to `local` when `driver_opts` is given.

---

## NFS Volumes

The `local` driver's `nfs` type mounts an NFS export as a volume, so each space can have a [file storage bucket](/docs/file-storage/) mounted, served by [`knot nfs-server`](/docs/file-storage/nfs/). Docker or Podman mounts it when the space starts; nothing is needed in the image.

This template mounts the bucket `configs` at `/configs` in every space, over NFSv4, from a `knot nfs-server` running on the same machine as Docker:

**Volumes:**

```yaml
volumes:
  ${{ .space.name }}-configs:
    driver: local
    driver_opts:
      type: nfs
      o: addr=host.docker.internal,port=2049,vers=4.0
      device: ":/configs"
```

**Container specification:**

```yaml
container_name: ${{ .space.name }}
image: alpine
volumes:
  - ${{ .space.name }}-configs:/configs
```

- `type` is `nfs`.
- `o` is the mount options: `addr`, the address of `knot nfs-server` (`host.docker.internal` reaches the host from Docker Desktop and OrbStack; on Linux, use the host's address and allow it with `--nfs-allow`), its `port`, and the NFS version, `vers=4.0`, or for NFSv3, `mountport=<port>,nfsvers=3,tcp,nolock`.
- `device` is the export to mount, `:/` followed by the path: `":/"` for every bucket, `":/configs"` for one bucket, `":/configs/app"` for a folder in it. An `nfs` volume without a `device` is refused when the template is saved.

The volume belongs to the space: it is unmounted and removed when the space is deleted, and the files stay in their bucket. A volume the space already has is not made again when the template changes, so to change an NFS volume's options for an existing space, give the volume a new name.

The files' owner seen in the space is set by `knot nfs-server` (see [ownership](/docs/file-storage/nfs/#ownership-and-permissions)): for spaces that run as root, start it with `--uid 0 --gid 0`.
