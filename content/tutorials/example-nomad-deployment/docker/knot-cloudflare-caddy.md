---
title: SSL
weight: 40
---

At this point, we have a running system; however, the SSL certificates are self-signed. While you can purchase and install certificates, you can also use **Caddy** with **Cloudflare** to allocate valid certificates for free. This method works for both public-facing servers and LAN-based servers with internet access, and it’s the approach we’ll use here.

---

## What You’ll Need

To follow this guide, ensure you have the following:

- A **Cloudflare account** (other similar providers might work, but this guide focuses on Cloudflare).
- A **registered domain name** set up with Cloudflare's name servers.

---

## Configuring Cloudflare

### Creating an API Key

Caddy requires the ability to create DNS records for your domain to handle SSL certificate validation. This requires a Cloudflare API key:

1. Log in to your **Cloudflare dashboard**.
2. Navigate to **Profile** > **API Tokens**.
3. Click **Create Token** and select the preset template for "Edit Zone DNS."
4. Under **Zone Resources**, select the domain you'll use for this project.
   {{< picture src="../images/zone-records.webp" caption="Cloudflare DNS Records" >}}
5. Click **Continue to Summary** > **Create Token**.
6. Copy the API token and save it—don’t lose this, as you’ll need it later.

---

### Adding DNS Records

To configure the required DNS records, go to your Cloudflare dashboard, select your domain, and add the following **A records** to point the domain names to your machine's IP. Ensure these records are **not proxied** if using private IPs.

| **Name**             | **Type** | **Value**     | **Description**        |
|----------------------|----------|---------------|------------------------|
| knot.getknot.dev     | A        | 192.168.0.10  | Main web interface     |
| *.knot.getknot.dev   | A        | 192.168.0.10  | Spaces web interface   |
| *.tunnel.getknot.dev | A        | 192.168.0.10  | Tunnel web interface   |

---

## Deploying Caddy

We’ll deploy a Nomad job to handle traffic on ports 80 and 443. This job will manage SSL certificates and forward traffic to the **knot** server.

### Caddy Job Configuration

Below is the Nomad job specification for deploying Caddy:

```hcl {filename="caddy.hcl"}
job "caddy" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert = true
  }

  group "caddy-server" {
    count = 1

    network {
      port "http" {
        to = 80
        static = 80
      }
      port "https" {
        to = 443
        static = 443
      }
      port "health_port" {
        to = 8080
      }
    }

    task "caddy-server" {
      driver = "docker"
      config {
        image = "paularlott/knot-caddy:latest"
        ports = ["http", "https", "health_port"]

        mount {
          type = "bind"
          source = "/data/caddy-data"
          target = "/data"
        }

        mount {
          type = "bind"
          source = "local/Caddyfile"
          target = "/etc/caddy/Caddyfile"
        }
      }

      template {
        data = <<EOF
{
  admin 127.0.0.1:2019
  storage file_system {
    root /data
  }
}

# Health Check
:8080 {
  respond /health-check 200
}

knot.getknot.dev *.knot.getknot.dev {
  tls {
    dns cloudflare <your cloudflare API key>
    resolvers 1.1.1.1
  }

  log {
    output stdout
    level INFO
    format transform "{common_log}"
  }

  encode zstd gzip

  reverse_proxy 192.168.0.10:3000 {
    transport http {
      tls
      tls_insecure_skip_verify
    }
  }
}

*.tunnel.getknot.dev {
  tls {
    dns cloudflare <your cloudflare API key>
    resolvers 1.1.1.1
  }

  log {
    output stdout
    level INFO
    format transform "{common_log}"
  }

  encode zstd gzip

  reverse_proxy 192.168.0.10:3010 {
    transport http {
      tls
      tls_insecure_skip_verify
    }
  }
}
EOF
        destination = "local/Caddyfile"
      }

      resources {
        cpu = 256
        memory = 256
      }

      service {
        name = "${NOMAD_JOB_NAME}"
        port = "http"
        address = "${attr.unique.network.ip-address}"

        check {
          name     = "alive"
          type     = "http"
          port     = "health_port"
          path     = "/health-check"
          interval = "30s"
          timeout  = "5s"
        }
      }

      service {
        name = "${NOMAD_JOB_NAME}-https"
        port = "http"
        address = "${attr.unique.network.ip-address}"

        check {
          name     = "alive"
          type     = "http"
          port     = "health_port"
          path     = "/health-check"
          interval = "30s"
          timeout  = "5s"
        }
      }
    }
  }
}
```

---

### Deploying the Job

1. **Create the Data Directory**
   Ensure the directory for storing Caddy data exists by running:

   ```shell
   mkdir -p /data/caddy-data
   ```

2. **Deploy the Job to Nomad**
   Use the following command to deploy the Caddy job:

   ```shell
   nomad run caddy.hcl
   ```

---

### Verifying the Setup

If everything is working correctly, accessing **https://knot.getknot.dev** will display the setup screen for **knot**.
