---
title: Logging
description: Console and structured HTTP logging with VictoriaLogs, Loki, and Elasticsearch support.
type: Overview
tags: [logging, configuration]
weight: 70
---

Knot supports two logging modes: **console** output for local development and **structured HTTP output** for forwarding logs to centralized log aggregation services such as VictoriaLogs, Grafana Loki, and Elasticsearch.

---

## Console Logging

By default, Knot writes logs to stderr in a human-readable format. Configure the log level in your `knot.toml`:

```toml
[log]
  level = "info"
```

### Log Levels

| Level  | Description                       |
| ------ | --------------------------------- |
| trace  | Very verbose internal diagnostics |
| debug  | Detailed debugging information    |
| info   | General operational messages      |
| warn   | Potential issues                  |
| error  | Errors that need attention        |
| fatal  | Unrecoverable errors (exits)      |

---

## Structured HTTP Output

When a log output URL is configured, Knot sends structured JSON log records to an HTTP endpoint instead of writing to stderr. Logs are batched for efficiency — up to 100 records or every 2 seconds, whichever comes first.

### Supported Formats

| Format          | Target Service | Content-Type              |
| --------------- | -------------- | ------------------------- |
| `ndjson`        | VictoriaLogs   | `application/stream+json` |
| `loki`          | Grafana Loki   | `application/json`        |
| `elasticsearch` | Elasticsearch  | `application/x-ndjson`    |
| `gelf`          | Graylog        | `application/json`        |

### Configuration

All options can be set in `knot.toml`, via CLI flags, or through environment variables.

#### `knot.toml`

```toml
[log]
  level = "info"

  [log.output]
    url = "http://localhost:9428/insert/jsonline"
    format = "ndjson"    # ndjson | loki | elasticsearch
    stream = "knot"      # stream name / identifier

    # Optional authentication (see "Authentication" below)
    username = ""        # HTTP basic auth username
    password = ""        # HTTP basic auth password
    token = ""           # bearer token (Authorization: Bearer); takes precedence over basic auth
```

#### CLI Flags

- **`--log-level`** — Log level: trace, debug, info, warn, error, fatal (default: `info`)
- **`--log-output-url`** — HTTP URL to send log output to
- **`--log-output-format`** — Log format: ndjson, loki, elasticsearch, or gelf (default: `ndjson`)
- **`--log-output-stream`** — Stream name / identifier sent with each record (default: `knot`)
- **`--log-output-username`** — Optional username for HTTP basic auth
- **`--log-output-password`** — Optional password for HTTP basic auth
- **`--log-output-token`** — Optional bearer token (`Authorization: Bearer`); takes precedence over basic auth

#### Environment Variables

- **`KNOT_LOGLEVEL`** — Maps to `--log-level`
- **`KNOT_LOG_OUTPUT_URL`** — Maps to `--log-output-url`
- **`KNOT_LOG_OUTPUT_FORMAT`** — Maps to `--log-output-format`
- **`KNOT_LOG_OUTPUT_STREAM`** — Maps to `--log-output-stream`
- **`KNOT_LOG_OUTPUT_USERNAME`** — Maps to `--log-output-username`
- **`KNOT_LOG_OUTPUT_PASSWORD`** — Maps to `--log-output-password`
- **`KNOT_LOG_OUTPUT_TOKEN`** — Maps to `--log-output-token`

---

## Authentication

When forwarding logs to a secured endpoint, Knot supports two optional authentication methods, both compatible with every output format:

| Method     | Configured via                          | Sent on each request            |
| ---------- | --------------------------------------- | ------------------------------- |
| Basic Auth | `username` + `password`                 | `Authorization: Basic <base64>` |
| Bearer     | `token`                                 | `Authorization: Bearer <token>` |

If a `token` is configured it takes precedence over basic auth. Only one `Authorization` header is ever sent.

> **Tip:** Basic auth credentials may also be embedded directly in the URL (e.g. `https://user:pass@host/...`); Go's HTTP client sends them automatically. The explicit `username`/`password` fields are clearer in config files and keep secrets out of access logs.

---

## Examples

### VictoriaLogs (NDJSON)

```toml
[log]
  level = "info"

  [log.output]
    url = "http://localhost:9428/insert/jsonline"
    format = "ndjson"
    stream = "knot"
```

Knot automatically appends VictoriaLogs field-mapping query parameters (`_msg_field`, `_time_field`, `_stream_fields`) if they are not already present on the URL.

### Grafana Loki

```toml
[log]
  level = "info"

  [log.output]
    url = "http://localhost:3100/loki/api/v1/push"
    format = "loki"
    stream = "knot"
```

Logs are encoded as a Loki push payload. The `stream` value is used as the `job` label. Timestamps are extracted from the log record when available.

### Elasticsearch

```toml
[log]
  level = "info"

  [log.output]
    url = "http://localhost:9200/_bulk"
    format = "elasticsearch"
    stream = "knot"
```

Logs are encoded as an Elasticsearch bulk payload. The `stream` value is used as the index name. If no stream is configured, the index defaults to `knot`.

---

## Authenticated Providers

The authentication options above work with every format. The most common hosted setups are shown below.

### Grafana Cloud (Loki) — Bearer Token

```toml
[log]
  level = "info"

  [log.output]
    url = "https://logs-prod-XXX.grafana.net/loki/api/v1/push"
    format = "loki"
    stream = "knot"
    token = "<Grafana Cloud API key>"   # sent as Authorization: Bearer
```

Grafana Cloud also accepts basic auth using your instance username as the `username` and the API key as the `password` — either field set works.

### Elasticsearch — Basic Auth

```toml
[log]
  level = "info"

  [log.output]
    url = "https://elastic.example.com:9200/_bulk"
    format = "elasticsearch"
    stream = "knot"
    username = "elastic"
    password = "<password>"
```

### Graylog (GELF)

```toml
[log]
  level = "info"

  [log.output]
    url = "http://graylog.example.com:12201/gelf"
    format = "gelf"
    stream = "knot"
```

Each record is posted as its own GELF JSON message — one HTTP request per message, which works with a stock Graylog GELF HTTP input (newline batching would require enabling the input's non-default bulk-receiving option). The `stream` value becomes the GELF `host`, slog levels map to syslog severities, and all other fields (`space_id`, `service`, …) are sent as underscore-prefixed additional fields.

### VictoriaLogs — Basic Auth

```toml
[log]
  level = "info"

  [log.output]
    url = "https://logs.example.com/insert/jsonline"
    format = "ndjson"
    stream = "knot"
    username = "<tenant>"
    password = "<token>"
```

---

## Log Level and Delivered Data

`log.level` filters the server's own diagnostics — at `warn`, info-level server chatter never reaches stderr or the external service. It deliberately does **not** filter data the external service was promised: audit events, forwarded space logs and tunnel request records flow through a separate always-on pipeline that shares the same delivery path (batching, retries, spool, stderr failover). Turning the level down to reduce noise can never silence the audit trail.

---

## Delivery Retries and Stderr Failover

Batches are delivered with retries: transport errors and server-side failures (HTTP 5xx / 429) are retried with increasing backoff before a batch is given up on. A client error (HTTP 4xx) means the endpoint rejected the payload itself, so those batches are not retried.

When external logging is configured, **stderr stays silent while the endpoint is healthy** (one startup line notes where logs are being sent). If a batch fails after all retries, the server writes an `ERROR` marker to stderr followed by the records of the failed batch, and from then on mirrors every new record to stderr as well — the failure window is always fully visible locally. The first successful flush writes a recovery line and the mirroring stops. State markers only appear on transitions, so a flapping endpoint doesn't spam. In Pro, the on-disk spool still takes a copy of failed batches for replay, with stderr as the live view of the same window.

{{< tip "info" >}}
For compliance-sensitive deployments (e.g. SOC 2), treat the external logging service as the long-term log store: configure retention, immutability and alerting there. Knot's internal audit-log store is a convenience window that expires entries after `server.audit.retention` days — set `server.audit.routing = "both"` or `"external"` so audit events reach the external service regardless.
{{< /tip >}}

---

## Data-Access Auditing

Developer and QA environments often hold copies of production data. Two audit options record who touched that data — **both are off by default** because they are noisy on a local dev machine:

```toml
[server.audit]
# Audit space file read, write and copy operations: who moved which data in
# or out of a space. Path and byte count only — file contents never enter
# the audit trail.
file_operations = true

# Audit interactive session opens — web terminal, SSH and VS Code tunnel —
# per space and user.
space_sessions = true
```

All audit settings live under `[server.audit]` (`routing`, `retention`, `stream`, `file_operations`, `space_sessions`). The older flat keys (`server.audit_routing` etc.) are still accepted; the section wins when both are present.

Or via flags / environment variables: `--audit-file-operations` / `KNOT_AUDIT_FILE_OPERATIONS` and `--audit-space-sessions` / `KNOT_AUDIT_SPACE_SESSIONS`. Both are fields in the config wizard's audit section.

With file operations enabled, every file `read`, `write`, `grep`, `find`, `sed`, `edit`, `delete` against a space — and every `copy` in either direction via `knot copy` or the web file manager — emits a `Space File Op` audit event carrying the space (and its template), the operation, the path, a byte count where known, and the source IP. With sessions enabled, opening the web terminal or a VS Code tunnel emits a `Space Session Open` event with the method. SSH is recorded at authentication time by the agent-managed SSH server: every public-key attempt emits an event carrying the outcome (success or failed), the key fingerprint, the client address and the space's template — a client trying several keys produces one failure per key plus a success.

Also recorded regardless of these switches:

- **API token lifecycle** — `Token Create` / `Token Update` / `Token Delete` carry the token name, id and scopes. These are long-lived credentials, so their lifecycle is always audited (OAuth flow-internal tokens and session extensions are not).
- **Runtime configuration changes** — saving configuration through the in-server setup wizard emits `Config Update`; changing `audit_routing` itself is therefore always visible.
- **Auth provider** — every `Login Success` carries the provider (`password`, or the OAuth provider id such as `github`).

Two SSH-adjacent cases are not covered: spaces whose template runs its own external SSH server (only the agent-managed SSH server can see authentication), and VNC sessions, which are served as a static app over the agent proxy with no distinct server-side open event.

---

## On-Disk Spool {{< pro-badge >}}

Knot Pro can spool undeliverable batches on disk while the external logging service is unreachable, then replay them (oldest first) once delivery succeeds — no lost records during outages. The spool is bounded: when it reaches its maximum size (256 MB) **or** its maximum file count (`max_files`, default 1024 batches) the oldest batches are evicted first. When delivery recovers, up to 32 spooled batches are replayed per flush cycle, so a backlog clears in seconds rather than one batch at a time.

```toml
[log]
  level = "info"

  [log.output]
    url = "http://localhost:9428/insert/jsonline"
    format = "ndjson"

    [log.spool]
      enabled = true
      path = "./log-spool/"   # directory for spooled batches
      max_mb = 256            # evict oldest batches beyond this size
      max_files = 1024        # ... or beyond this many batch files
```

- **`--log-spool-enabled`** / **`KNOT_LOG_SPOOL_ENABLED`** — enable the spool
- **`--log-spool-path`** / **`KNOT_LOG_SPOOL_PATH`** — spool directory (default: `./log-spool/`)
- **`--log-spool-max-mb`** / **`KNOT_LOG_SPOOL_MAX_MB`** — maximum spool size in MB (default: `256`)
- **`--log-spool-max-files`** / **`KNOT_LOG_SPOOL_MAX_FILES`** — maximum number of spooled batch files (default: `1024`)

---

## Forwarding Space Logs {{< pro-badge >}}

{{< pro-badge >}} Services running inside spaces ship their logs to the in-space agent (syslog, GELF, Loki, or VictoriaLogs format — see [Logging from Spaces](../../spaces/logging/)). By default the server keeps those logs in memory for the web log window only. Enable forwarding (Pro) to write them into the server's log output, so they reach the same destination as the server's own logs — including the external logging service configured above:

```toml
[log]
  level = "info"
  forward_space_logs = true
```

Forwarded records are tagged with `stream = "space"`, `type = "space_log"`, plus `space_id`, `service` and `log_level` fields, so they can be filtered downstream. Off by default — development spaces can produce a lot of log volume. Space logs are never written to knot's internal database; long-term retention is the job of the external logging service.

---

## Tunnel Request Logging {{< pro-badge >}}

{{< pro-badge >}} Each request proxied through a web tunnel can be logged to the server's log output — the access-log equivalent for tunnels. Records carry the method, path, host, response status and duration, tagged with `stream = "tunnel"`, `type = "tunnel_request"`, plus `tunnel` (the tunnel name) and `actor` (the owning user) fields. Tunnels have no space identity by design — a tunnel can be run from the user's desktop — so records are always tagged with the tunnel name and user:

```toml
[log]
  level = "info"
  tunnel_requests = true
```

- **`--log-tunnel-requests`** / **`KNOT_LOG_TUNNEL_REQUESTS`** — enable tunnel request logging (Pro)

Off by default, matching space log forwarding. A VictoriaLogs query such as `tunnel:my-tunnel`, `service:tunnel` or `type:tunnel_request` filters the records downstream.

Tunnel lifecycle is audited rather than logged: tunnels opening and closing (web and port, including CLI/desktop tunnels) emit `Tunnel Create` / `Tunnel Close` audit events carrying the tunnel name, owning user, and — for port tunnels — the space and port, so they land in the audit trail like other user actions.

[Log sinks](../../spaces/log-sinks/) are separate: a user's sinks **always** receive tunnel request logs for their tunnels — and the tunnels opening and closing — regardless of this setting; running a sink is itself the opt-in.

---

## Audit Anomaly Detection {{< pro-badge >}}

{{< pro-badge >}} Knot Pro can run anomaly detection over the audit event stream — failed-login bursts per user, credential spraying per source IP, and event sink delivery failures — emitting its own `Anomaly Detected` audit events when a rule fires. Detection works with any `server.audit.routing` (the internal audit store is not required). See [Anomaly Detection](../anomaly-detection/) for rules, configuration and the interaction with audit routing.

---

## Field Mappings

When forwarding logs, Knot maps standard `slog` field names to the expected names for each backend:

| slog field | Mapped to | Notes                          |
| ---------- | --------- | ------------------------------ |
| `msg`      | `_msg`    | Log message                    |
| `time`     | `_time`   | Timestamp (RFC 3339 Nano)      |
| `service`  | `service` | Origin service (see below)     |

Every record knot delivers carries `source: knot`, so on a shared logging service one selector — `source:knot` — sifts everything this knot shipped from everything else the service holds (WAF logs, docker logs, and so on).

`service` names the origin of a record: `knot` for the server itself, `knot_audit` for audit events, `knot_tunnel` for tunnel traffic, `knot_syslog` when an ingested record carries no service of its own, the in-space service name for forwarded space logs (application-chosen names are never prefixed), and `knot_<name>` for knot's in-space subsystems — `knot_jobs`, `knot_script`, `knot_method_server`. For VictoriaLogs destinations, `source`, `service` and `level` are indexed as stream fields, so all are trivially selectable (`source:knot`, `service:knot_audit`, `level:ERROR`) — the same field names and selectors as the agent's in-space ingest and [log sinks](../../spaces/log-sinks/).

For Loki, the `time` field is converted to a Unix nanosecond timestamp in the values array rather than included in the log line body.
