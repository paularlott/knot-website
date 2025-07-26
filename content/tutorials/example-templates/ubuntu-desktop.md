---
title: Ubuntu Desktop
weight: 20
---

The following defines a simple **Ubuntu 24.04 space** running an **XFCE-based desktop environment** using the excellent [KasmVNC](https://github.com/kasmtech/KasmVNC).

---

## Nomad Cluster

The home directory makes use of a volume configured with the **hostpath CSI driver**, which is assumed to have been set up within the Nomad cluster.

This job assumes **Docker** is being used for container management. If **Podman** is being used, change the `driver` to `podman` and update the `image` to `registry-1.docker.io/paularlott/knot-desktop:24.04` to enable spaces to be created using Podman.

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

  group "debian" {
    count = 1

    volume "home_volume" {
      type            = "csi"
      source          = "ubuntu_${{.space.id}}_home"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "debian" {
      driver = "docker"
      config {
        image = "paularlott/knot-desktop:24.04"

        privileged = true
        hostname = "${{ .space.name }}"
      }

      env {
        # Define environment variables for agent
        KNOT_SERVER         = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT = "${{.server.agent_endpoint}}"
        KNOT_SPACEID        = "${{.space.id}}"
        KNOT_VNC_HTTP_PORT  = "5680"
        KNOT_USER           = "${{.user.username}}"
        TZ                  = "${{ .user.timezone }}"
      }

      volume_mount {
        volume      = "home_volume"
        destination = "/home"
      }

      resources {
        cpu = 300
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

---

## Docker / Podman

The following defines the same **Ubuntu 24.04 desktop template** with a volume attached to the home directory. The space deploys to the local server using **Docker** or **Podman** rather than Nomad. The choice of Docker or Podman is made through the selection under `Platform` when creating the template.

---

### Container Specification

> **Note**: If using **Podman**, the `image` must be fully qualified as `registry-1.docker.io/paularlott/knot-desktop:24.04`.

```yaml
container_name: ${{ .user.username }}-${{ .space.name }}
hostname: "${{ .space.name }}"
image: paularlott/knot-desktop:24.04
volumes:
  - desktop_${{.space.id}}_home:/home/

environment:
  - "TZ=${{.user.timezone}}"
  - "KNOT_LOGLEVEL=info"
  - "KNOT_SERVER=${{.server.url}}"
  - "KNOT_AGENT_ENDPOINT=${{.server.agent_endpoint}}"
  - "KNOT_SPACEID=${{.space.id}}"
  - "KNOT_USER=${{.user.username}}"
  - "KNOT_VNC_HTTP_PORT=5680"
  - "KNOT_SERVICE_PASSWORD=${{.user.service_password}}"
```

---

### Volume Definition

```yaml {filename="Volume-Definition"}
volumes:
  desktop_${{.space.id}}_home:
```
