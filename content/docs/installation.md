---
title: Installation
weight: 10
---

## Installing the Client

{{< tabs items="Linux,macOS,Windows" >}}

  {{< tab >}}
  The Linux client can be installed via Homebrew or by downloading the latest binary from [GitHub releases](https://github.com/paularlott/knot/releases).

  ```bash
  brew install paularlott/homebrew/knot
  ```
  {{< /tab >}}
  {{< tab >}}
  The preferred install method for macOS is via Homebrew

  ```bash
  brew install paularlott/homebrew/knot
  ```

  Alternatively the latest binary can be downloaded from [GitHub releases](https://github.com/paularlott/knot/releases).
  {{< /tab >}}
  {{< tab >}}
  The latest binary can be downloaded from [GitHub releases](https://github.com/paularlott/knot/releases)
  {{< /tab >}}

{{< /tabs >}}

## Deploying the Server

The server is deployed as a nomad job an example file can be generated from the command line:

```bash
knot scaffold --nomad
```

```hcl {filename=knot-server.nomad}
job "knot-server" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert = true
  }

  group "knot-server" {
    count = 1

    network {
      port "knot_port" {
        to = 3000
      }
    }

    task "knot-server" {
      driver = "docker"
      config {
        image = "ghcr.io/paularlott/knot:latest"
        ports = ["knot_port"]
      }

      env {
        KNOT_CONFIG = "/local/knot.yml"
      }

      template {
        data = <<EOF
log:
  level: info
server:
  listen: 0.0.0.0:3000
  download_path: /srv
  url: "https://knot.example.com"
  wildcard_domain: "*.knot.example.com"
  encrypt: "knot genkey"

  mysql:
      database: knot
      enabled: true
      host: ""
      password: ""
      user: ""

  nomad:
      addr: "http://nomad.service.consul:4646"
      token: ""
EOF
        destination = "local/knot.yml"
      }

      resources {
        cpu = 256
        memory = 512
      }

      # Knot Agent Port
      service {
        name = "${NOMAD_JOB_NAME}"
        port = "knot_port"

        # Expose the port on a domain name
        # tags = [
        #  "urlprefix-knot.example.com"
        # ]

        check {
          name     = "alive"
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
```

`datacenters` will need updating for the cluster that the job is being deployed to as will the `tags` so that the ingress controller can route traffic to the server.

The knot server is configured via the `local/knot.yml` file:

```yaml {filename=knot.yml}
log:
  level: info
server:
  listen: 0.0.0.0:3000
  download_path: /srv
  url: "https://knot.example.com"
  wildcard_domain: "*.knot.example.com"
  encrypt: "knot genkey"

  mysql:
      database: knot
      enabled: true
      host: ""
      password: ""
      user: ""

  nomad:
      addr: "http://nomad.service.consul:4646"
      token: ""
```

The configuration should be updated:

- `url` The host the server will be accessed as
- `wildcard_domain` The wildcard domain used to provide web access to the containers web server
- `encrypt` The encryption key for encrypting variables, this is generated with `knot genkey`
- `mysql.*` The configuration information for the MySQL server to use
- `nomad.*` The configuration for communicating with Nomad, the token must have permission to access any namespaces used in environment jobs

The MySQL database should be empty, on first run knot will create the required tables and initialize the data.

## Creating the Initial User

Once the server has been deployed point the browser at the URL defined in the configuration file, this will allow the first user to be created, this user is granted full admin rights.

Once the user has been created the login screen is presented.
