---
title: PHP with Caddy
weight: 50
---

The following example sets up a **PHP development space** where the `~/public_html` folder is served via an instance of **Caddy**.

---

## Nomad Cluster

This job assumes **Docker** is being used for container management. If **Podman** is being used, change the `driver` to `podman` and update the `image` to `registry-1.docker.io/paularlott/knot-php:8.4` to enable spaces to be created using Podman.

---

### Nomad Job

```hcl
job "${{.user.username}}-${{.space.name}}" {
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
      type            = "host"
      source          = "ubuntu_${{.space.id}}_home"
      read_only       = false
    }

    task "debian" {
      driver = "docker"
      config {
        image = "paularlott/knot-php:8.4"

        hostname = "${{ .space.name }}"
      }

      env {
        # Define environment variables for agent
        KNOT_SERVER           = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT   = "${{.server.agent_endpoint}}"
        KNOT_SPACEID          = "${{.space.id}}"
        KNOT_HTTP_PORT        = "Web=80"
        KNOT_USER             = "${{.user.username}}"
        TZ                    = "${{ .user.timezone }}"
      }

      volume_mount {
        volume      = "home_volume"
        destination = "/home"
      }

      resources {
        cpu    = 300
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
  - name: "ubuntu_${{.space.id}}_home"
    type: "host"
    plugin_id: "mkdir"
    parameters:
      mode: "0755"
      uid: 1000
      gid: 1000
```

---

### Accessing the Web Interface

The space exposes **port 80** via the web interface, which can be accessed from the space's [web interface](../../../docs/spaces/web-server).

Once the space is running, any **HTML** or **PHP** files placed within the `~/public_html` folder will be processed and served by **Caddy**.

---

## Docker / Podman

The following defines the same **PHP with Caddy template** for deployment using **Docker** or **Podman**.

---

### Container Specification

> **Note**: If using **Podman**, the `image` must be fully qualified as `registry-1.docker.io/paularlott/knot-php:8.4`.

```yaml
container_name: ${{ .user.username }}-${{ .space.name }}
hostname: "${{ .space.name }}"
image: paularlott/knot-php:8.4
volumes:
  - php_${{.space.id}}_home:/home/

environment:
  - "TZ=${{.user.timezone}}"
  - "KNOT_LOGLEVEL=info"
  - "KNOT_SERVER=${{.server.url}}"
  - "KNOT_AGENT_ENDPOINT=${{.server.agent_endpoint}}"
  - "KNOT_SPACEID=${{.space.id}}"
  - "KNOT_USER=${{.user.username}}"
  - "KNOT_HTTP_PORT=80=Site"
```

---

### Volume Definition

```yaml {filename="Volume-Definition"}
volumes:
  php_${{.space.id}}_home:
```
