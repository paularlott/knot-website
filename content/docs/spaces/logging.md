---
title: Logging
weight: 90
---

Spaces built using the **knot** base images utilize `rsyslog` to collect logs from services running within the space. These logs are forwarded by the **knot** agent to the **knot** server for storage and viewing.

---

## Viewing Logs

Once a space is running, logs can be accessed directly from the **Spaces** page:

1. Click the **`Logs`** button next to the space whose logs you want to view.
   {{< picture src="../images/logs-option.webp" caption="Logs Icon" >}}

2. A window will open, tailing the logs in real-time.

---

## Sending Logs

The **knot** agent supports two interfaces for sending logs:
- **Syslog Interface**
- **HTTP API** (supports native JSON, msgpack, Graylog GELF, and Loki formats)

### Default Ports:
- **HTTP API**: `12201`
- **Syslog Interface**: `514`

---

### Sending Logs via `logger`

You can send messages to the syslog interface using the `logger` command:

```shell
logger test message
```

{{< picture src="../images/log-message.webp" caption="Output from Logger Command" >}}

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

{{< tip >}}
The interface accepts GELF messages but does not validate them, so non-conforming messages may still be sent.
{{< /tip >}}

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

{{< tip >}}
- The interface accepts Loki messages but does not validate them, so non-conforming messages may still be sent.
- Only JSON-formatted log messages are supported.
{{< /tip >}}
