---
title: Example Deployment
weight: 40
---

{{< callout type="warning" >}}
  This example is the minimum required to deploy nomad and consul and not suitable for production environments.
{{< /callout >}}

The following assumes:

- A virtual machine with a clean install of Debian 12
- The VM has an IP address of `192.168.0.10`
- The domain names `knot.getknot.dev` and `*.knot.getknot.dev` are pointed to the VM

## Install Nomad and Consul

As root run:

```shell
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

apt-get update
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y
apt install -y nomad consul docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

mkdir -p /opt/nomad/plugins
cd /opt/nomad/plugins
wget https://releases.hashicorp.com/nomad-driver-podman/0.5.2/nomad-driver-podman_0.5.2_linux_amd64.zip
unzip nomad-driver-podman_0.5.2_linux_amd64.zip
rm nomad-driver-podman_0.5.2_linux_amd64.zip
```

### Configure and Start Consul

`/etc/consul.d/consul.hcl`

```hcl
datacenter = "dc1"

bind_addr = "{{ GetPrivateIP }}"
client_addr = "{{ GetPrivateInterfaces | exclude \"type\" \"ipv6\" | join \"address\" \" \" }} {{ GetAllInterfaces | include \"flags\" \"loopback\" | join \"address\" \" \" }}"
advertise_addr = "{{ GetInterfaceIP \"ens18\"}}"

log_level = "WARN"

data_dir = "/opt/consul"

server = true
bootstrap_expect = 1

ui_config {
  enabled = true
}
```

```shell
systemctl enable consul
systemctl start consul
```

Check consul is running by going to http://knot.getknot.dev:8500

### Configure and Start Nomad

`/etc/nomad.d/nomad.hcl`

```hcl
datacenter = "dc1"

data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

plugin_dir = "/opt/nomad/plugins/"

consul {
  address = "127.0.0.1:8500"
}

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
}

plugin "docker" {
  config {
    allow_privileged = true
    allow_caps = [ "ALL" ]
    volumes {
      enabled = true
    }
  }
}
```

```shell
systemctl enable nomad
systemctl start nomad
```

Check nomad is running by going to http://knot.getknot.dev:4646

## Setting Storage

In this example a redis server is being used to store knots database.

The redis data is stored in `/data/redis-data`.

`redis.hcl`

```hcl
job "redis" {
  group "cache" {
    network {
      port "redis" {
        to = 6379
        static = 6379
      }
    }

    task "redis" {
      driver = "docker"
      config {
        image = "redis:7"
        ports = [ "redis" ]

        mounts {
          type = "bind"
          source = "/data/redis-data"
          target = "/data"
        }
      }
    }

    service {
      name = "redis"
      port = "redis"

      check {
        name     = "redis_check"
        type     = "tcp"
        interval = "10s"
        timeout  = "5s"
      }
    }
  }
}
```

Create the data directory and deploy the job to nomad.

```shell
mkdir -p /data/redis-data
nomad run redis.hcl
```

## Deploy knot

```hcl
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
        static = 3000
      }
    }

    task "knot-server" {
      driver = "docker"
      config {
        image = "paularlott/knot:latest"
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
  url: "https://knot.getknot.dev"
  wildcard_domain: "*.knot.getknot.dev"
  encrypt: "knot genkey"
  location: core

  redis:
    enabled: true
    host: redis.service.consul:6379
    password: ""
    db: 0

  nomad:
      addr: "http://{{ env "NOMAD_IP_knot_port" }}:4646"
      token: ""

resolver:
  consul:
    - {{ env "NOMAD_IP_knot_port" }}:8600

  nameservers:
    - 1.1.1.1
    - 1.0.0.1
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
        address = "${attr.unique.network.ip-address}"

        check {
          name            = "alive"
          type            = "http"
          protocol        = "https"
          tls_skip_verify = true
          path            = "/health"
          interval        = "10s"
          timeout         = "2s"
        }
      }
    }
  }
}
```

Deploy the knot server:

```shell
nomad run knot.hcl
```

## Install knot and Deploy

Follow the [Initial User Setup](../initial-user)

Then create a `debian` template:

```hcl
job "${{.user.username}}-${{.space.name}}" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert = false
  }

  group "debian" {
    count = 1

    network {
      port "knot_port" {
        to = 3000
      }
    }

    task "debian" {
      env {
        # Define environment variables for agent
        KNOT_SERVER = "${{.server.url}}"
        KNOT_SPACEID = "${{.space.id}}"
        KNOT_LOGLEVEL = "warn"
        KNOT_USER = "${{.user.username}}"

        KNOT_DNS_LISTEN = "127.0.0.1:53"
        KNOT_CONSUL_SERVERS = "${attr.unique.network.ip-address}:8600"
        KNOT_NAMESERVERS = "1.1.1.1 1.0.0.1"
      }

      driver = "docker"
      config {
        image = "paularlott/knot-debian:12"

        ports = ["knot_port"]
        hostname = "${{ .space.name }}"

        cap_add = [
          "NET_RAW" # Needed for ping to work
        ]
      }

      resources {
        cpu = 300
        memory = 512
      }

      # Knot Agent Port
      service {
        name = "knot-${{.space.id}}"
        port = "knot_port"
        address = "${attr.unique.network.ip-address}"

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

{{< callout type="info" >}}
  If your domain is accessed via internal name servers rather than public nameservers then the environment variable `KNOT_NAMESERVERS` will need to be updated to list the IPs of the internal nameservers.
{{< /callout >}}

At this point a space can be created from the template and deployed.
