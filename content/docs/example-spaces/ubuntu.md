---
title: Ubuntu
weight: 30
---

The following defines a simple Ubuntu 24.04 space with a volume attached to the home directory, the volume uses hostpath CSI driver which is assumes has been configured within the nomad cluster.

The space provides an instance of code-server which can be accessed in the browser via the knot web interface.

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

        TZ = "${{ .user.timezone }}"
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

```yaml {filename=Volume-Definition}
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

If the namespace is set on the job e.g. to `${{.user.username}}` then all the spaces would be placed into a namespace of the username, with the correct nomad configuration this would allow users to access nomad but only interact with their jobs.

## Startup Scripts

During the startup of the container any scripts found in the `/etc/knot-startup.d/` directory are executed as root, then any scripts in the `.knot-startup.d/` directory within the users home directory are executed as the user.

This allows for both system level and user specific scripts to be started.
