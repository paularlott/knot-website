---
title: Configuration
description: Server configuration options for customizing your knot deployment.
type: Overview
tags: [configuration]
weight: 15
---

This section covers server configuration options for customizing your Knot deployment.

---

## Choosing Your Setup

### Single Server (Standalone)

Best for:
- Individual developers
- Small teams (< 10 users)
- Development and testing
- Simple deployments

Use:
- BadgerDB for storage
- Docker or Podman for containers
- No cluster configuration needed

### Cluster Mode

Best for:
- Production deployments
- Distributed teams
- High availability requirements
- Multiple geographic locations

Use:
- BadgerDB, MySQL/MariaDB, PostgreSQL, or Redis for storage
- Nomad for container orchestration (optional - can use Local Containers)
- Multiple servers with cluster configuration

### Leaf Mode

Best for:
- Remote developers
- Local development with central management
- Bandwidth-constrained locations
- Hybrid deployments

Use:
- Local containers (Docker/Podman)
- Connection to central cluster
- Personal access token

---

## Storage Backend Selection

**BadgerDB**
- Embedded database
- No external dependencies
- Production-ready
- Simple setup
- Works in multi-server clusters (data synced via gossip)

**MySQL/MariaDB**
- External database
- Proven reliability
- Supports large-scale deployments
- Good for existing database infrastructure

**PostgreSQL**
- External database
- Stores sessions too, so they survive a restart without Redis
- Good for existing PostgreSQL infrastructure

**Redis/Valkey**
- In-memory database
- Highest performance
- Requires more memory
- Good for high-traffic deployments

---

## Configuration Topics

### [Storage Systems](storage-systems)
Configure BadgerDB, MySQL/MariaDB, PostgreSQL, or Redis/Valkey for data storage.

### [Cluster Mode](cluster-mode)
Set up multiple servers for high availability and geographic distribution.

### [Leaf Mode](leaf-mode)
Connect local instances to a central cluster for hybrid deployments.

### [Tunnel Server](tunnel-server)
Expose services to the internet securely through tunnels.

### [Local Containers](local-containers)
Configure Docker, Podman, or Apple Container for local execution.

### [Template Spec Wizard](spec-wizard)
Configure the base image registry and catalog that power the template spec wizard.

### [Two Factor Authentication](2fa)
Enable TOTP-based 2FA for enhanced security.

### [DNS Server](dns-server)
Serve the wildcard domain locally so space addresses resolve.

### [Node Selection](node-selection)
Control which server in a cluster runs each space.

### [Licensing](licensing)
Activate a Knot Pro license on the server. {{< pro-badge >}}

### [OAuth Authentication](oauth)
Allow users to sign in with GitHub or Google accounts. {{< pro-badge >}}

### [User Interface](ui)
Customize the web interface with logos and Gravatar support.

### [Logging](logging)
Forward structured logs to VictoriaLogs, Grafana Loki, or Elasticsearch.

### [File Storage](/docs/file-storage/)
Replicated buckets for the Files page and the `knot file` commands (and S3 on Knot Pro), enabled by setting `server.files.path`.

### [Anomaly Detection](anomaly-detection)
Detect failed-login bursts, credential spraying and event sink failures over the audit stream. {{< pro-badge >}}

---

## Quick Configuration Examples

### Minimal Standalone

```toml
[server]
listen = "0.0.0.0:3000"
listen_agent = "0.0.0.0:3010"
agent_endpoint = "192.168.1.100:3010"
url = "http://knot.local:3000"
wildcard_domain = "*.knot.local:3000"
encrypt = "<generate with: knot genkey>"

# Required. All members of a zone must use the same encryption key: it
# derives agent registration keys, agent tokens and the zone's agent TLS
# certificate.

[server.badgerdb]
enabled = true
path = "./badgerdb/"
```

### Production Cluster

```toml
[server]
listen = "0.0.0.0:3000"
listen_agent = "0.0.0.0:3010"
agent_endpoint = "knot1.example.com:3010"
url = "https://knot1.example.com"
wildcard_domain = "*.knot1.example.com"
encrypt = "<generate with: knot genkey>"

[server.mysql]
enabled = true
host = "mysql.example.com"
port = 3306
user = "knot"
password = "<strong-password>"
database = "knot"

[server.cluster]
advertise_addr = "https://knot1.example.com"
key = "<generate with: knot genkey>"
peers = [
  "https://knot1.example.com",
  "https://knot2.example.com",
  "https://knot3.example.com"
]
```

---

## Server TLS

By default the server serves HTTPS. With no certificate configured it generates a self-signed certificate at startup covering the host in `server.url` and `localhost`; point it at your own certificate for production:

```toml
[server.tls]
cert_file = "/etc/knot/tls/knot.crt"
key_file = "/etc/knot/tls/knot.key"
use_tls = true
```

| Config | Flag | Environment | Default | Description |
|---|---|---|---|---|
| `server.tls.cert_file` | `--cert-file` | `KNOT_CERT_FILE` | | PEM encoded certificate. Used only when `key_file` is also set |
| `server.tls.key_file` | `--key-file` | `KNOT_KEY_FILE` | | PEM encoded private key |
| `server.tls.use_tls` | `--use-tls` | `KNOT_USE_TLS` | `true` | Serve HTTPS. Set to `false` to serve plain HTTP, for example behind a TLS-terminating reverse proxy |

When the server runs in desktop mode with the default `http://127.0.0.1:3000` URL, it serves plain HTTP on loopback instead.

---

## Other Server Options

| Config | Flag | Environment | Default | Description |
|---|---|---|---|---|
| `server.hostname` | `--hostname` | `KNOT_HOSTNAME` | System hostname | The name this server advertises to the other servers in a cluster |
| `server.timezone` | `--timezone` | `KNOT_TIMEZONE` | Server's local timezone | Timezone used to evaluate template schedules; exposed to templates as `${{ .server.timezone }}` |
| `server.auth_ip_rate_limiting` | `--auth-ip-rate-limiting` | `KNOT_AUTH_IP_RATE_LIMITING` | `true` | Rate limit failed logins per IP address and account (tuned with `server.auth_rate_limit_*`) |
| `server.disable_space_create` | `--disable-space-create` | `KNOT_DISABLE_SPACE_CREATE` | `false` | Stop all users creating new spaces; existing spaces keep working |
| `server.disable_user_activity` {{< pro-badge >}} | `--disable-user-activity` | `KNOT_DISABLE_USER_ACTIVITY` | `false` | Turn off filesystem write tracking in every space, so file changes no longer count as user activity (for example towards a template's idle timeout) |
| `server.mcp_tool_timeout` | `--mcp-tool-timeout` | `KNOT_MCP_TOOL_TIMEOUT` | `180` | Maximum time in seconds an MCP tool call may run |
| `server.mcp_tools_path` | `--mcp-tools-path` | `KNOT_MCP_TOOLS_PATH` | | Directory of MCP tools to use instead of the tools built into the server |
| `server.mcp.disable_builtin_tools` | `--mcp-disable-builtin-tools` | `KNOT_MCP_DISABLE_BUILTIN_TOOLS` | | List of built-in MCP tool names to disable |

---

## Security Considerations

- Always use HTTPS in production
- Generate strong encryption keys
- Enable 2FA for all users
- Run on private networks or behind VPN
- Regular backups of database
- Keep knot updated

See [Security](../best-practices/security/) for detailed guidance.
