---
title: Single Server
weight: 20
---

Rather than deploying **knot** within a Nomad cluster, it can be deployed on a single server either by running the binary directly as done in the quick start guide or by using Docker or Podman. In this example deployment we're going to use Docker and Docker Compose, we're also going to use Cloudflare to provide valid SSL certificates.

While this guide is using Cloudflare other providers can be used with Caddy to achieve the same results.

The installation will use BadgerDB for storing users, space data, templates etc, however any of the supported storage backend could be used.

## What You’ll Need

To follow this guide, ensure you have the following:

- A **Cloudflare account** (other similar providers might work, but this guide focuses on Cloudflare).
- A **registered domain name** set up with Cloudflare's name servers.
- The **IP** address of the server you are installing to.
- A machine with a clean install of **Ubuntu 22.04** and Docker and Docker Compose installed.

For this guide we're going to assume

- The virtual machine has an IP address of `192.168.0.10`.
- The following domain names will be used:
  - `knot.getknot.dev`
  - `*.knot.getknot.dev`
  - `*.tunnel.getknot.dev`

---

## Configuring Cloudflare

### Creating an API Key

Caddy requires the ability to create DNS records for your domain to handle SSL certificate validation. This requires a Cloudflare API key:

1. Log in to your **Cloudflare dashboard**.
2. Navigate to **Profile** > **API Tokens**.
3. Click **Create Token** and select the preset template for "Edit Zone DNS."
4. Under **Zone Resources**, select the domain you'll use for this project.
   {{< picture src="../example-nomad-deployment/docker/images/zone-records.webp" caption="Cloudflare DNS Records" >}}
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

## Configuring Your Server

You'll need access to the terminal of the machine you’ll use as your development server. Here's how to set up the environment.

### 1. Setting Up a Project Directory

First, create a folder to store everything related to your configuration and data:

```
mkdir knot
cd knot
```

### 2. Required Files

Inside the `knot` directory, create the following files with these exact contents (make adjustments where specified):

#### Environment Variables
This file will hold necessary environment configurations. Replace placeholders like `<your key>`, `<your domain>`, and `<host ip>` with your actual values.

```env {filename="env"}
CLOUDFLARE_KEY=<your key>
DOMAIN=knot.getknot.dev
TUNNELDOMAIN=tunnel.getknot.dev
IP=192.168.0.10

KNOT_ENABLE_TOTP=false

KNOT_LISTEN_AGENT=0.0.0.0:3001
KNOT_AGENT_ENDPOINT=${IP}:3001
KNOT_LISTEN_TUNNEL=0.0.0.0:3010
KNOT_URL=https://${DOMAIN}
KNOT_WILDCARD_DOMAIN=*.${DOMAIN}
KNOT_TUNNEL_DOMAIN=${TUNNELDOMAIN}
KNOT_BADGERDB_ENABLED=true
KNOT_BADGERDB_PATH=/database
```

NOTE: If you are installing this on an internet connected machine with a public IP address then please change `KNOT_ENABLE_TOTP=false` to `KNOT_ENABLE_TOTP=true`. Also ensure that none of the ports are directly accessible from the internet.

#### Docker Compose Configuration

This file defines the services, their environment variables, and the networks they'll use:

```yaml {filename="docker-compose.yml"}
services:
  caddy:
    image: paularlott/knot-caddy
    env_file:
      - env
    ports:
      - "80:80"
      - "443:443"
    networks:
      - caddy_network
    volumes:
      - ./caddy-data:/data
      - ./Caddyfile:/etc/caddy/Caddyfile

  knot:
    image: paularlott/knot
    hostname: knot1
    env_file:
      - env
    ports:
      - "3001:3001"
    networks:
      - caddy_network
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./database:/database
    user: root:root

networks:
  caddy_network:
```

#### Caddy Configuration
This file handles certificates and proxies requests between the front end and your services. Use the following template:

```Caddyfile {filename="Caddyfile"}
{
  admin 127.0.0.1:2019
  storage file_system {
    root /data
  }
}

{$DOMAIN} {$KNOT_WILDCARD_DOMAIN} {
  tls {
    dns cloudflare {$CLOUDFLARE_KEY}
    resolvers 1.1.1.1
  }

  log {
    output stdout
    level INFO
    format transform "{common_log}"
  }

  encode zstd gzip

  reverse_proxy knot:3000 {
    transport http {
      tls
      tls_insecure_skip_verify
    }
  }
}

*.{$TUNNELDOMAIN} {
  tls {
    dns cloudflare {$CLOUDFLARE_KEY}
    resolvers 1.1.1.1
  }

  log {
    output stdout
    level DEBUG
    format transform "{common_log}"
  }

  encode zstd gzip

  reverse_proxy knot:3010 {
    transport http {
      tls
      tls_insecure_skip_verify
    }
  }
}
```

### 3. Starting the Environment
With everything in place, the server can be started, the `-d` option keeps the server running in the backgound.

Run this command from inside the project directory to start the services in the background:

```
docker compose up -d
```

Access the web interface at `https://knot.getknot.dev`. If everything works as expected, you should see the setup screen for **knot**

## Installing Knot

Follow the quick start guide to [Create the Admin User](../../docs/quick-start/standalone/create-admin-user/)
