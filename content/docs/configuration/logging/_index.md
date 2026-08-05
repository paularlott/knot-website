---
title: Logging
description: Console and structured HTTP logging with VictoriaLogs, Loki, and Elasticsearch support.
type: Overview
tags: [logging, configuration]
weight: 70
---

**knot** supports two logging modes: **console** output for local development and **structured HTTP output** for forwarding logs to centralized log aggregation services such as VictoriaLogs, Grafana Loki, and Elasticsearch.

---

## Console Logging

By default, **knot** writes logs to stderr in a human-readable format. Configure the log level in your `knot.toml`:

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

When a log output URL is configured, **knot** sends structured JSON log records to an HTTP endpoint instead of writing to stderr. Logs are batched for efficiency — up to 100 records or every 2 seconds, whichever comes first.

### Supported Formats

| Format          | Target Service | Content-Type              |
| --------------- | -------------- | ------------------------- |
| `ndjson`        | VictoriaLogs   | `application/stream+json` |
| `loki`          | Grafana Loki   | `application/json`        |
| `elasticsearch` | Elasticsearch  | `application/x-ndjson`    |

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
- **`--log-output-format`** — Log format: ndjson, loki, or elasticsearch (default: `ndjson`)
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

When forwarding logs to a secured endpoint, **knot** supports two optional authentication methods, both compatible with every output format:

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

**knot** automatically appends VictoriaLogs field-mapping query parameters (`_msg_field`, `_time_field`, `_stream_fields`) if they are not already present on the URL.

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

## Field Mappings

When forwarding logs, **knot** maps standard `slog` field names to the expected names for each backend:

| slog field | Mapped to | Notes                          |
| ---------- | --------- | ------------------------------ |
| `msg`      | `_msg`    | Log message                    |
| `time`     | `_time`   | Timestamp (RFC 3339 Nano)      |
| `stream`   | `stream`  | Stream identifier (if set)     |

For Loki, the `time` field is converted to a Unix nanosecond timestamp in the values array rather than included in the log line body.
