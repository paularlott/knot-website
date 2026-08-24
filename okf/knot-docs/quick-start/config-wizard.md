---
description: Generate a knot.toml with a guided web-based wizard — the fastest way to get started.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/quick-start/config-wizard/
sources:
    - resource: https://getknot.dev/docs/quick-start/config-wizard/
status: stable
tags:
    - installation
    - deployment
title: Config Wizard
type: Guide
---
# Config Wizard

The **config wizard** generates a `knot.toml` through a guided, step-by-step web UI. It explains each choice, applies sensible defaults based on your deployment type, and lets you review the result in an embedded editor before writing to disk.

---

## Running the Wizard

```shell
knot server config-wizard
```

This starts a local web server on `http://127.0.0.1:8080`. Open the URL in your browser.


In [desktop mode](desktop-mode.md) the wizard runs automatically on the first run — no command needed. Afterwards it stays available from the tray menu's **Setup** entry, served at `/setup` while the server runs.



The wizard binds to loopback (`127.0.0.1`) by default. Use `--port` to change the port, `--listen` to change the address, and `--config` to target a specific output path.


If a config file already exists at the target path, the wizard still runs — the editor shows the generated config for review or copy, but the write button is disabled so you don't accidentally clobber an existing setup.

---

## What the Wizard Covers

The wizard walks through ten steps:

### 1. Deployment Type
Choose **Single Server**, **Cluster**, or **Leaf Node**. This sets sensible defaults for the remaining steps (storage backend, platforms, DNS).

### 2. Database
Pick **BadgerDB** (embedded, no external dependencies), **MySQL / MariaDB** (external, proven at scale), or **Redis / Valkey** (in-memory, highest performance). When the primary database is BadgerDB or MySQL, you can optionally enable **Redis for session storage** so sessions survive server restarts. When Redis is the primary database, sessions go to Redis automatically.


Never use the same database (same MySQL database name or Redis DB number) for multiple knot instances — each server must have its own.


### 3. Server Address
Enter the server URL, wildcard domain (auto-derived from the URL), agent endpoint, timezone (searchable), listen addresses, and encryption key. The wizard explains what each field is for. For **Cluster** deployments a cluster section appears: advertise address, shared cluster key (with regen), peer addresses, and the allow-leaf-nodes toggle.

### 4. DNS Resolution
Choose system nameservers or specify custom ones (for Consul SRV lookups, etc.). Optionally enable the built-in DNS server with A/AAAA/CNAME records to serve your wildcard domain locally.

### 5. Container Runtimes
Configure Nomad, Docker, and Podman. Leave a field blank to skip that runtime.

### 6. Tunnel Server
Expose services running inside spaces to the public internet for testing — webhooks, preview URLs, external integrations. Disabled by default.

### 7. Security & UI
Enable TOTP two-factor authentication (works with Google Authenticator, Microsoft Authenticator, etc.), Gravatar avatars, and failed-login blocking. The block parameters are configurable: failures allowed, the counting window, and how long auth stays blocked (defaults: 10 failures per minute, 5-minute block). Tracking and blocking are cluster-wide — failures and blocks are shared between servers, in and out of zone; desktop leaf nodes keep local state.

### 8. Optional Features
Enable AI/Chat (OpenAI, Anthropic, Google, Ollama) and MCP server.

### 9. Logging & Audit
Configure external log output (VictoriaLogs, Loki, Elasticsearch or Graylog endpoint, with optional basic auth or bearer token credentials) and audit log routing/retention. The Pro wizard additionally configures space log forwarding , the on-disk log spool  and audit anomaly detection  (per-rule thresholds and windows — failed logins, successes after failure bursts, blocked attempts, admin grants, bulk deletions, distinct login IPs, and more). The external logging service is the long-term log store — the internal audit store expires entries after the retention period. See [Logging Configuration](../configuration/logging.md).

### 10. Review
The generated `knot.toml` is shown in an embedded TOML editor with syntax highlighting. Edit anything directly, then click **write to disk** or **copy to clipboard**.

---

## After the Wizard

Once the config is written, start the server:

```shell
knot server
```

On first launch the web UI prompts you to create the initial admin user.

For more advanced configuration options, see the [full configuration reference](../configuration.md).

---

## What's Next

- [Local Containers Setup](local-containers/server-setup.md) — manual setup alternative
- [Nomad Setup](nomad/server-setup.md) — deploy to a Nomad cluster
- [Configuration](../configuration.md) — complete configuration reference
