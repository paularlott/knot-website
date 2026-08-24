---
description: Collect, forward, and view service logs from a space using rsyslog and the HTTP log API.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/spaces/logging/
sources:
    - resource: https://getknot.dev/docs/spaces/logging/
status: stable
tags:
    - spaces
    - logging
title: Logging
type: Guide
---
# Logging

Spaces built using the Knot base images utilize `rsyslog` to collect logs from services running within the space. These logs are forwarded by the Knot agent to the Knot server for storage and viewing.

---

## Viewing Logs

Once a space is running, logs can be accessed directly from the **Spaces** page:

1. Click the **`Logs`** button next to the space whose logs you want to view.
2. A window will open, tailing the logs in real-time.

---

## Sending Logs

The Knot agent supports two interfaces for sending logs:
- **Syslog Interface**
- **HTTP API** (supports native JSON, msgpack, Graylog GELF, and Loki formats)

### Default Ports:
- **HTTP API**: `12201`
- **Syslog Interface**: `1514`

---

### Sending Logs via `logger`

You can send messages to the syslog interface using the `logger` command:

```shell
logger test message
```

---

## HTTP API Formats

### Native JSON or Msgpack

The native JSON or msgpack format uses a simple JSON object with the following fields:

```json
{
  "service": "my-app",
  "level": "info",
  "message": "Logging a test message"
}
```

- **`service`**: The name of the service sending the log message.
- **`level`**: The log level (`debug`, `info`, or `error`).
- **`message`**: The log message content.

Any additional keys are carried through to log sinks and space log forwarding as structured fields, so this endpoint supports structured data too — e.g. `{"service":"api","level":"info","message":"done","request_id":"req-5","status":201}`.

Send the message using `curl`:

```bash
curl -X POST http://localhost:12201/logs \
  -H "Content-Type: application/json" \
  -d '{"service":"my-app", "level":"info", "message":"Logging a test message"}'
```

---

### Graylog GELF

The Graylog GELF format uses the following JSON structure:

```json
{
  "version": "1.1",
  "host": "example.org",
  "short_message": "A short message",
  "full_message": "Backtrace here\n\nmore stuff",
  "timestamp": 1291899928.412,
  "level": 3
}
```

Send the message using `curl`:

```bash
curl -X POST http://localhost:12201/gelf \
  -H "Content-Type: application/json" \
  -d '{"version":"1.1", "host":"example.org", "short_message":"A short message", "full_message":"Backtrace here\n\nmore stuff", "timestamp":1291899928.412, "level":3}'
```


The interface accepts GELF messages but does not validate them, so non-conforming messages may still be sent. Additional fields (the `_`-prefixed kind) are carried through to log sinks and space log forwarding as structured data — e.g. `"_request_id":"req-9"`.


---

### Loki

The Loki-compatible endpoint accepts logs in the following JSON format:

```json
{
  "streams": [
    {
      "stream": {
        "label": "my-app"
      },
      "values": [
        [ "1620000000", "Logging a test message" ]
      ]
    }
  ]
}
```

Send the message using `curl`:

```bash
curl -X POST http://localhost:12201/loki/api/v1/push \
  -H "Content-Type: application/json" \
  -d '{"streams": [{"stream": {"label": "my-app"}, "values": [[ "1620000000", "Logging a test message" ]]}]}'
```


- The interface accepts Loki messages but does not validate them, so non-conforming messages may still be sent.
- Only JSON-formatted log messages are supported.
- When a log line is a JSON object with a `msg` or `message` field, the remaining keys are carried through to log sinks and space log forwarding as structured data; plain lines pass through verbatim.


---

### VictoriaLogs

The agent natively accepts VictoriaLogs jsonline inserts, so shippers configured for VictoriaLogs can point at the agent unchanged. Each body line is a self-contained JSON object:

```json
{"_msg": "Logging a test message", "_time": "2026-08-15T10:00:00Z"}
```

Send the message using `curl`:

```bash
curl -X POST "http://localhost:12201/insert/jsonline" \
  -H "Content-Type: application/stream+json" \
  -d '{"_msg": "Logging a test message", "service": "my-app"}'
```

The endpoint honours the standard VictoriaLogs field-mapping query parameters — `_msg_field`, `_time_field` and `_stream_fields` — with the same defaults, e.g.:

```bash
curl -X POST "http://localhost:12201/insert/jsonline?_msg_field=message&_stream_fields=service" \
  -H "Content-Type: application/stream+json" \
  -d '{"message": "Logging a test message", "service": "my-app"}'
```

#### Structured data

Any extra fields on the line ride along through the agent to the server — they reach a log sink's VictoriaLogs as flat fields and space log forwarding as top-level record keys — so there is no schema to declare, and multiple lines can be sent in one request:

```json
{"_time":"2026-08-17T10:00:00Z","_msg":"request completed","service":"api","level":"info","method":"POST","path":"/v1/orders","status":201,"duration_ms":42,"request_id":"req-7f3a"}
{"_time":"2026-08-17T10:00:01Z","_msg":"request completed","service":"api","level":"error","method":"GET","path":"/v1/users","status":500,"duration_ms":873,"request_id":"req-8b1c"}
```

```bash
curl -X POST "http://localhost:12201/insert/jsonline" \
  -H "Content-Type: application/stream+json" \
  --data-binary @requests.jsonl
```

To make a field a stream field, name it in `_stream_fields` when inserting — the same batch with `service` and `level` as streams:

```bash
curl -X POST "http://localhost:12201/insert/jsonline?_stream_fields=service,level" \
  -H "Content-Type: application/stream+json" \
  --data-binary @requests.jsonl
```

Fields are then queryable in LogsQL, e.g. slow requests and errors:

```sql
service:="api" AND duration_ms > 100          -- slow requests
status:>=500 | stats by (path) count() _time  -- error counts per path
```

With `service` declared as a stream field the first query can also use the cheaper stream filter — `{service="api"} AND duration_ms > 100` — which VictoriaLogs can resolve without scanning field indexes.


When mirrored to a log sink, `service` and `level` are automatically declared as stream fields in the sink's VictoriaLogs, so stream-filter queries work out of the box. Other fields arrive as regular (indexed) fields.



- The service name shown in the log window is taken from a `service` field if present, else from the first `_stream_fields` field, else defaults to `victorialogs`.
- A `level` field (`debug`, `info`, `error`, or a numeric syslog level) sets the log level; the default is `info`.
- Invalid JSON lines are rejected with a 400; successful inserts return 204, matching VictoriaLogs.



To carry space logs into a central store, enable `forward_space_logs` on the server so received logs are forwarded on to the server's configured log output — see [Logging Configuration](../configuration/logging.md).



A space can also **receive** logs: with a Pro licence and the *Use Log Sinks* permission, a space advertising `KNOT_LOG_SINK_PORT` gets a mirror of the owner's other space logs — see [Log Sinks](log-sinks.md).
