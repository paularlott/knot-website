---
title: Logging
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
```

#### CLI Flags

- **`--log-level`** — Log level: trace, debug, info, warn, error, fatal (default: `info`)
- **`--log-output-url`** — HTTP URL to send log output to
- **`--log-output-format`** — Log format: ndjson, loki, or elasticsearch (default: `ndjson`)
- **`--log-output-stream`** — Stream name / identifier sent with each record (default: `knot`)

#### Environment Variables

- **`KNOT_LOGLEVEL`** — Maps to `--log-level`
- **`KNOT_LOG_OUTPUT_URL`** — Maps to `--log-output-url`
- **`KNOT_LOG_OUTPUT_FORMAT`** — Maps to `--log-output-format`
- **`KNOT_LOG_OUTPUT_STREAM`** — Maps to `--log-output-stream`

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

## Field Mappings

When forwarding logs, **knot** maps standard `slog` field names to the expected names for each backend:

| slog field | Mapped to | Notes                          |
| ---------- | --------- | ------------------------------ |
| `msg`      | `_msg`    | Log message                    |
| `time`     | `_time`   | Timestamp (RFC 3339 Nano)      |
| `stream`   | `stream`  | Stream identifier (if set)     |

For Loki, the `time` field is converted to a Unix nanosecond timestamp in the values array rather than included in the log line body.
