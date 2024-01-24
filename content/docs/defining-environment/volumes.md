---
title: Volumes
weight: 10
---

Each environment template can optionally define volumes, if volumes are defined then they are created before the environment is deployed.

Any Container Storage Interface (CSI) driver supported by Nomad can be used.

{{< callout type="warning" >}}
  Starting and stopping the space will not destroy the volumes however deleting the space will destroy the volumes and all data on them.
{{< /callout >}}

An example volume definition to allocate block storage using the hostpath driver would look like:

```yaml
volumes:
  - id: "debian_${{.space.id}}_home"
    name: "debian_${{.space.id}}_home"
    plugin_id: "hostpath"
    capacity_min: 1G
    capacity_max: 10G
    mount_options:
      fs_type: "ext4"
      mount_flags:
        - rw
        - noatime
    capabilities:
      - access_mode: "single-node-writer"
        attachment_mode: "file-system"
```

The ID of the volume is named `debian_${{.space.id}}_home` where `space.id` is replaced with the unique ID of the space using the volume.

If volume definitions are added or removed from the space template then those volumes are created or destroyed the next time the space is started. Any data in a volume being deleted will be lost.
