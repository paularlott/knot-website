---
title: Valkey
weight: 30
---

The following defines a template for deploying a **Valkey server**. This space has no persistent storage, so restarting it will destroy the current data.

---

## Nomad Cluster

The job assumes **Docker** is being used for container management. If **Podman** is being used, change the `driver` to `podman` and update the `image` to `registry-1.docker.io/paularlott/knot-valkey:latest` to enable spaces to be created using **Podman**.

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

  group "valkey" {
    count = 1

    task "valkey" {
      env {
        # Define environment variables for agent
        KNOT_SERVER         = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT = "${{.server.agent_endpoint}}"
        KNOT_SPACEID        = "${{.space.id}}"
        KNOT_TCP_PORT       = "6379"
        KNOT_USER           = "redis"
      }

      driver = "docker"
      config {
        image = "paularlott/knot-valkey:latest"
        hostname = "${{ .space.name }}"
      }

      resources {
        cpu = 300
        memory = 512
      }
    }
  }
}
```

---

### Connecting to Valkey

The space exports the **Valkey port 6379** via the TCP proxy, allowing it to be connected to using [port forwarding](../../../docs/spaces/port-forwarding) within the desktop client. For example:

```shell
knot forward port 127.0.0.1:6379 <space> 6379
```

Where `<space>` is the name of the space.

Once the above command is running, any desktop **Redis/Valkey client** should be able to connect to port `6379` on `localhost`. **knot** will handle forwarding the data to the Valkey server running within the space.

---

## Docker / Podman

The following defines the same **Valkey server template** for deployment using **Docker** or **Podman**.

---

### Container Specification

> **Note**: If using **Podman**, the `image` must be fully qualified as `registry-1.docker.io/paularlott/knot-valkey:latest`.

```yaml
container_name: ${{ .user.username }}-${{ .space.name }}
hostname: "${{ .space.name }}"
image: paularlott/knot-valkey:latest
volumes:
  - ubuntu_${{.space.id}}_home:/home/

environment:
  - "TZ=${{.user.timezone}}"
  - "KNOT_LOGLEVEL=info"
  - "KNOT_SERVER=${{.server.url}}"
  - "KNOT_AGENT_ENDPOINT=${{.server.agent_endpoint}}"
  - "KNOT_SPACEID=${{.space.id}}"
  - "KNOT_USER=${{.user.username}}"
  - "KNOT_TCP_PORT=6379"
```

---

### Connecting to Valkey

As with the Nomad version, you can connect a local port to the Valkey server running within the space using [port forwarding](../../../docs/spaces/port-forwarding). For example:

```shell
knot forward port 127.0.0.1:6379 <space> 6379
```

This allows any desktop **Redis/Valkey client** to connect to the Valkey server on `localhost:6379`.
