---
title: PHP with Caddy
weight: 70
---

The following example is for a PHP development space where the `~/public_html` folder is served via an instance of Caddy.

```hcl {filename=Nomad-Job}
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
      type            = "csi"
      source          = "ubuntu_${{.space.id}}_home"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "debian" {
      driver = "docker"
      config {
        image = "paularlott/knot-php:8.4-ubuntu"

        hostname = "${{ .space.name }}"
      }

      env {
        # Define environment variables for agent
        KNOT_WILDCARD_DOMAIN  = "${{.server.wildcard_domain}}"
        KNOT_SERVER           = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT   = "${{.server.agent_endpoint}}"
        KNOT_SPACEID          = "${{.space.id}}"
        KNOT_HTTP_PORT        = "Web=80"
        KNOT_USER             = "${{.user.username}}"
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

The space also exposes port 80 via the web interface, assuming a web server such as Caddy or Apache is running on port 80 then it can be accessed from the spaces [web interface](/docs/spaces/web-server).

Once the space is running any HTML or PHP placed within the `~/public_html` folder will be processed by Caddy.

## Startup Scripts

During the startup of the container any scripts found in the `/etc/knot-startup.d/` directory are executed as root, then any scripts in the `.knot-startup.d/` directory within the users home directory are executed as the user.

This allows for both system level scripts and user specific scripts to be executed when the container starts.

## Using a Custom Registry

It's expected that development images are modified by the system owners and hosted in custom registries, in which case authentication maybe required.

The built in [variables](/docs/templates/variables) system can be used by changing the `config` section slightly:

```hcl
config {
  image = "${{.var.registry_url}}/knot-php:8.4-ubuntu"
  auth {
    username = "${{.var.registry_user}}"
    password = "${{.var.registry_pass}}"
  }

  hostname = "${{ .space.name }}"
}
```

For the above the variables `registry_url`, `registry_user` and `registry_pass` will need to be created.

{{< tip "warning" >}}
  The values of variables are exposed within the Nomad templates, if this is a problem then Vault may be a better solution.
{{< /tip >}}

