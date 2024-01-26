---
title: Volumes
weight: 10
---

## Standalone Volumes

Volumes can be created and managed independently to spaces. This flexibility allows for a volume to be created and then attached to multiple spaces, such as providing storage for `/home`.

These standalone volumes are not impacted by the lifespan of the spaces they're attached to. Even if all spaces are deleted, these standalone volumes, along with their data, will continue to persist.

Any Container Storage Interface (CSI) driver supported by Nomad can be used, knot places no additional requirements on this.

### Creating a Volume

From the menu select `Volumes` then click `Create Volume` the following form will be presented:

![](/docs/administration/create-volume.webp)

The name field is a descriptive name for the volume, it's not used within the volume definition. The Volume Definition field takes YAML and expects a single volume to be defined. If more than one volume is defined then the volume will not be able to be started.

The following defines a volume named `test_home`:

```yaml
volumes:
  - id: "test_home"
    name: "test_home"
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

The description of the values can be found in the Nomad [Volume Specification](https://developer.hashicorp.com/nomad/docs/other-specifications/volume).

Once the name and definition have been entered click `Create Volume` to define the volume.

### Starting a Volume

Only once a volume has been started will it be available within the cluster.

From the `Volumes` page click the menu next to the volume to start and select `Start`.

![](/docs/administration/start-volume.webp)

### Stopping a Volume

{{< callout type="warning" >}}
  Stopping a volume will destroy all data on the volume.
{{< /callout >}}

Stopping a volume will free the resources that it is using within the Nomad cluster, this will destroy all data on the volume.

![](/docs/administration/stop-volume.webp)

### Deleting a Volume

Only stopped volumes can be destroyed, from the dropdown menu next to the volume select `Delete` and confirm the choice.

## Space Volumes

Each development environment template can define one or more volumes, if volumes are defined then they are created when the environment is deployed and destroyed when the environment is destroyed.

{{< callout type="info" >}}
  Starting and stopping the environment does not affect the lifespan of the volumes.
{{< /callout >}}

{{< callout type="warning" >}}
  Deleting the space will destroy the volumes and all data on them.
{{< /callout >}}

An example volume definition that allocates block storage for two volumes `home` and `data` would look like:

```yaml
volumes:
  - id: "${{.space.id}}_home"
    name: "${{.space.id}}_home"
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

  - id: "${{.space.id}}_data"
    name: "${{.space.id}}_data"
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

In the example the ID of the volume is given as `${{.space.id}}_home`, `.space.id` is replaced with the unique ID of the space using the volume.

If volume definitions are added or removed from the space template then those volumes are created or destroyed the next time the space is started. Any data in a volume being deleted will be lost.
