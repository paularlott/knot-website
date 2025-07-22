---
title: Nomad Templates
weight: 20
---

Nomad templates in **knot** define environments using a Nomad job specification and optional volume definitions. When a developer creates and starts a space from a template, **knot** automatically provisions the required volumes and launches the job within the Nomad cluster.

For enhanced isolation, namespaces can be set within the job specification. For example:
`namespace="${{ .user.username }}"`
This ensures that jobs for each developer are placed in their own namespaces.

---

### Nomad Job

To create a Nomad template:

1. Navigate to `Templates` and select `New Template`.
2. Complete the form, ensuring the `Name` and `Nomad Job` fields are filled.
   {{< picture src="../images/template-platform.webp" caption="Template Platform" >}}
   - `Nomad` must be selected under `Platform`.
   - The `Nomad Job` field requires an HCL job specification. See [example environments](/docs/examples-environments/) for reference.

{{< tip >}}
When a template is updated, all running spaces are marked as having an update available. However, spaces are not automatically restarted. Restarting a space applies the updated template.
{{< /tip >}}

#### Using Template Variables

Template variables can store sensitive information, such as registry login credentials. For example:

```hcl
image = "paularlott/knot-ubuntu:24.04"
auth {
  username = "${{ .var.registry_user }}"
  password = "${{ .var.registry_pass }}"
}
```

{{< tip "warning" >}}
Variables are stored as plain text within the Nomad template and can be viewed via the Nomad web interface. For sensitive environments, consider using a solution like Vault for compliance and security.
{{< /tip >}}

---

### Example Nomad Job

Below is an example of a Nomad job specification:

```hcl {filename=Nomad-Job}
job "${{.space.name}}-${{.user.username}}" {
  datacenters = ["dc1"]

  update {
    max_parallel     = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert      = true
  }

  group "ubuntu" {
    count = 1

    volume "home_volume" {
      type            = "csi"
      source          = "ubuntu_${{.space.id}}_home"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "data_volume" {
      type            = "csi"
      source          = "ubuntu_${{.space.id}}_data"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "ubuntu" {
      driver = "docker"
      config {
        image = "paularlott/knot-ubuntu:24.04"
        hostname = "${{ .space.name }}"
      }

      env {
        KNOT_SERVER           = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT   = "${{.server.agent_endpoint}}"
        KNOT_SPACEID          = "${{.space.id}}"
        KNOT_SSH_PORT         = "22"
        KNOT_CODE_SERVER_PORT = "49374"
        KNOT_USER             = "${{.user.username}}"
        TZ                    = "${{ .user.timezone }}"
      }

      volume_mount {
        volume      = "home_volume"
        destination = "/home"
      }

      volume_mount {
        volume      = "data_volume"
        destination = "/data"
      }

      resources {
        cores  = 4
        memory = 4096
      }
    }
  }
}
```

---

### Volumes

Templates can define one or more volumes. These volumes are:

- **Created**: When the space is deployed.
- **Destroyed**: When the space is deleted.
- **Persistent**: Starting and stopping the space does not affect the contents of the volumes unless the template is modified to remove a volume.

{{< tip "warning" >}}
Deleting a space will destroy its volumes and all data stored on them.
{{< /tip >}}

#### Example Volume Definition

Below is an example YAML configuration for defining block storage volumes:

```yaml
volumes:
  - id: "ubuntu_${{.space.id}}_home"
    name: "ubuntu_${{.space.id}}_home"
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

  - id: "ubuntu_${{.space.id}}_data"
    name: "ubuntu_${{.space.id}}_data"
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

In this example, the volume ID `ubuntu_${{.space.id}}_home` dynamically incorporates the unique space ID.

{{< tip "warning" >}}
If volume definitions are added or removed from a template, the changes will take effect the next time the space is started. Any data in a deleted volume will be permanently lost.
{{< /tip >}}
