---
title: Volumes
weight: 80
---

Standalone volumes can be created and managed independently of spaces. This flexibility allows volumes to be created and attached to multiple spaces, such as providing shared storage for `/home`. These volumes are persistent and are not affected by the lifespan of the spaces they are attached to. Even if all spaces are deleted, standalone volumes and their data will continue to exist.

For **Nomad** volumes, any Container Storage Interface (CSI) driver supported by Nomad can be used, as **knot** places no additional requirements on this.

Standalone volumes do not count toward a user's **Storage Units** quota.

---

## Creating a Volume

1. From the menu, select **`Volumes`**, then click **`New Volume`**.
2. The following form will be displayed:
   {{< picture src="images/create-volume.webp" caption="Create Volume" >}}

3. Fill in the required fields:
   - **`Name`**: A descriptive name to identify the volume.
   - **`Platform`**: The platform the volume is for (e.g., Nomad, Docker, or Podman).
   - **`Volume Definition`**: The YAML definition of the volume.

---

### Nomad CSI Volume

For Nomad volumes:
- The **`Name`** field is purely descriptive and is not used within the volume definition.
- The **`Volume Definition`** field must contain YAML defining a single volume. If more than one volume is defined, the volume cannot be started.
- Set the **`Platform`** to **`Nomad`**.

Example YAML for a volume named `test_home`:

```yaml
volumes:
  - id: "test_home"
    name: "test_home"
    plugin_id: "hostpath"
    capacity_min: 10G
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

For detailed descriptions of the fields, refer to the Nomad [Volume Specification](https://developer.hashicorp.com/nomad/docs/other-specifications/volume).

Once the name and definition are entered, click **`Create Volume`** to define the volume.

---

### Nomad Host Volume

For Nomad host volumes:
- **`Name`**: A descriptive name to identify the volume.
- The **`Volume Definition`** field must contain YAML defining a single volume. If more than one volume is defined, the volume cannot be started.
- Set the **`Platform`** to **`Nomad`**.

Example YAML for a volume named `test_home`:

```yaml
volumes:
  - name: "test_home"
    type: "host"
    plugin_id: "mkdir"
    parameters:
      mode: "0755"
      uid: 1000
      gid: 1000
```

For detailed descriptions of the fields, refer to the Nomad [Host Volume Specification](https://developer.hashicorp.com/nomad/docs/other-specifications/volume/host).

Once the name and definition are entered, click **`Create Volume`** to define the volume.

---

### Docker / Podman Volume

For Docker or Podman volumes:
1. From the menu, select **`Volumes`**, then click **`New Volume`**.
2. Choose **`Docker`** or **`Podman`** for the **`Platform`** option (this cannot be changed later).
3. Define the volume using the following YAML format:

```yaml
volumes:
  test_home:
```

---

## Starting a Volume

A volume must be started to make it available within the cluster.

1. From the **`Volumes`** page, click the menu next to the volume you want to start.
2. Select **`Start`**.
   {{< picture src="images/start-volume.webp" caption="Start a Volume" >}}

---

## Stopping a Volume

{{< tip "warning" >}}
Stopping a volume will destroy all data on the volume.
{{< /tip >}}

Stopping a volume releases the resources it is using, but it also destroys all data stored on the volume. To stop a volume:
1. Click **`Stop`** in the volume's menu.

---

## Deleting a Volume

Only stopped volumes can be deleted. To delete a volume:
1. From the dropdown menu next to the volume, select **`Delete`**.
2. Confirm the deletion to permanently remove the volume.
