---
title: Logging
weight: 100
---

The spaces using or built from the knot base images use rsyslog to collect logs from the services running within the space. The logs are then sent to the knot agent which forwards them to the origin server for storage and viewing.

## Viewing Logs

Once a space is running, the logs can be viewed by clicking the `Logs` button on the `Spaces` page next to the space whose logs are to be viewed.

## Sending Logs

The `knot` agent supports a syslog interface along with a HTTP API. The HTTP API interface supports a native JSON or msgpack format, a Greylog GELF format endpoint and a Loki compatible endpoint.

The default port for the HTTP API is `12201` and the syslog interface is `514`.

### Native JSON or Msgpack

The native JSON or msgpack format is a simple JSON object with the following fields:

```json
{
  "service": "my-app",
  "level": "info",
  "message": "Logging a test message"
}
```

- `service` - The name of the service sending the log message.
- `level` - The log level of the message, one of `debug`, `info`, `error`.
- `message` - The log message to be sent.

The message can be sent to the agent using the following curl command:

```bash
curl -X POST http://localhost:12201/logs \
  -H "Content-Type: application/json" \
  -d '{"service":"my-app", "level":"info", "message":"Logging a test message"}'
```

### Graylog GELF

The Graylog GELF format is a JSON object with the following fields:

```json
{
  "version": "1.1",
  "host": "example.org",
  "short_message": "A short message",
  "full_message": "Backtrace here\n\nmore stuff",
  "timestamp": 1291899928.412,
  "level": 3,
}
```

The message can be sent to the agent using the following curl command:

```bash
curl -X POST http://localhost:12201/gelf \
  -H "Content-Type: application/json" \
  -d '{"version":"1.1", "host":"example.org", "short_message":"A short message", "full_message":"Backtrace here\n\nmore stuff", "timestamp":1291899928.412, "level":3}'
```

{{< callout type="note" >}}
  The interface is designed to accept a GELF message but doesn't do validation on the message, so it's possible to send a message that doesn't conform to the GELF specification.
{{< /callout >}}

### Loki

The Loki compatible endpoint can accept logs in the Loki format, the message is a JSON object with the following fields:

```json
{
  "streams": [
    {
      "stream": {
        "label": "my-app",
      },
      "values": [
        {
          "timestamp": 1620000000,
          "line": "Logging a test message"
        }
      ]
    }
  ]
}
```

The message can be sent to the agent using the following curl command:

```bash
curl -X POST http://localhost:12201/loki/api/v1/push \
  -H "Content-Type: application/json" \
  -d '{"streams":[{"stream":{"label":"my-app"},"values":[{"timestamp":1620000000,"line":"Logging a test message"}]}'
```

{{< callout type="note" >}}
  The interface is designed to accept a Loki message but doesn't do validation on the message, so it's possible to send a message that doesn't conform to the Loki specification.

  Only JSON formatted log messages are supported.
{{< /callout >}}
