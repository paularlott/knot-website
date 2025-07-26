---
title: Ubuntu
weight: 10
---

The following template defines an **Ubuntu 24.04 space**. Below are configurations for both **Nomad** and **local Docker/Podman** deployments.

---

## Nomad Cluster

The following defines a simple **Ubuntu 24.04 space** with a volume attached to the home directory. The volume uses the **hostpath CSI driver**, which is assumed to have been configured within the Nomad cluster.

This job assumes **Docker** is being used for container management. If **Podman** is being used, change the `driver` to `podman` and update the `image` to `registry-1.docker.io/paularlott/knot-ubuntu:24.04` to enable spaces to be created using Podman.

---

### Nomad Job

```hcl
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

    task "ubuntu" {
      driver = "docker"
      config {
        image = "paularlott/knot-ubuntu:24.04"
        hostname = "${{ .space.name }}"
      }

      env {
        # Define environment variables for agent
        KNOT_SERVER           = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT   = "${{.server.agent_endpoint}}"
        KNOT_SPACEID          = "${{.space.id}}"
        KNOT_USER             = "${{.user.username}}"
        TZ                    = "${{ .user.timezone }}"
      }

      volume_mount {
        volume      = "home_volume"
        destination = "/home"
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

### Volume Definition

```yaml
volumes:
  - id: "ubuntu_${{.space.id}}_home"
    name: "ubuntu_${{.space.id}}_home"
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

> **Note**: If the namespace is set on the job (e.g., `${{.user.username}}`), spaces created from this template will be placed into a namespace of the username. With the correct Nomad configuration, this allows users to access Nomad but only interact with their jobs.

---

## Docker / Podman

The following defines the same **Ubuntu 24.04 template** with a volume attached to the home directory. The space deploys to the local server using **Docker** or **Podman** rather than Nomad. The choice of Docker or Podman is made through the selection under `Platform` when creating the template.

---

### Container Specification

> **Note**: If using **Podman**, the `image` must be fully qualified as `registry-1.docker.io/paularlott/knot-ubuntu:24.04`.

```yaml
container_name: ${{ .user.username }}-${{ .space.name }}
hostname: "${{ .space.name }}"
image: paularlott/knot-ubuntu:24.04
volumes:
  - ubuntu_${{.space.id}}_home:/home/

environment:
  - "TZ=${{.user.timezone}}"
  - "KNOT_LOGLEVEL=info"
  - "KNOT_SERVER=${{.server.url}}"
  - "KNOT_AGENT_ENDPOINT=${{.server.agent_endpoint}}"
  - "KNOT_SPACEID=${{.space.id}}"
  - "KNOT_USER=${{.user.username}}"
  - "KNOT_HTTP_PORT=80=Site"
  - "KNOT_SERVICE_PASSWORD=${{.user.service_password}}"
```

---

### Volume Definition

```yaml {filename="Volume-Definition"}
volumes:
  ubuntu_${{.space.id}}_home:
```
