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

    network {
      port "knot_port" {
        to = 3000
      }
    }

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
        image = "paularlott/knot-php:8.2-ubuntu"

        ports = ["knot_port"]
        hostname = "${{ .space.name }}"
      }

      env {
        # Define environment variables for agent
        KNOT_WILDCARD_DOMAIN  = "${{.server.wildcard_domain}}"
        KNOT_SERVER           = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT   = "${{.server.agent_endpoint}}"
        KNOT_SPACEID          = "${{.space.id}}"
        KNOT_SSH_PORT         = "22"
        KNOT_HTTP_PORT        = "80"
        KNOT_CODE_SERVER_PORT = "49374"
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

      # Knot Agent Port
      service {
        name = "knot-${{.space.id}}"
        port = "knot_port"

        check {
          name            = "alive"
          type            = "http"
          protocol        = "https"
          tls_skip_verify = true
          path            = "/ping"
          interval        = "10s"
          timeout         = "2s"
        }
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

The space exposes a SSH server to the agent on port 22 which can be connected to via the [SSH proxy](/docs/working-with-spaces/ssh), it also exposes VSCode Server which will be available via the [web interface](/docs/working-with-spaces/code-server).

The space also exposes port 80 via the web interface, assuming a web server such as Caddy or Apache is running on port 80 then it can be accessed from the spaces [web interface](/docs/working-with-spaces/web-server).

Once the space is running any HTML or PHP placed within the `~/public_html` folder will be processed by Caddy.

## Startup Scripts

During the startup of the container any scripts found in the `/etc/knot-startup.d/` directory are executed as root, then any scripts in the `.knot-startup.d/` directory within the users home directory are executed as the user.

This allows for both system level scripts to be started and user specific scripts.

## Using a Custom Registry

It's expected that development images are modified by the system owners and hosted in custom registries, in which case authentication maybe required.

The built in [variables](/docs/administration/variables) system can be used by changing the `config` section slightly:

```hcl
config {
  image = "${{.var.registry_url}}/knot-php:8.2-ubuntu"
  auth {
    username = "${{.var.registry_user}}"
    password = "${{.var.registry_pass}}"
  }

  ports = ["knot_port"]
  hostname = "${{ .space.name }}"
}
```

For the above the variables `registry_url`, `registry_user` and `registry_pass` will need to be created.

{{< callout type="warning" >}}
  The values of variables are exposed within the Nomad templates, if this is a problem then Vault may be a better solution.
{{< /callout >}}

