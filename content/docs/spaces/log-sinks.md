---
title: Log Sinks
description: Run a space that receives a mirror of your other spaces' logs.
type: Guide
tags: [spaces, logging]
weight: 115
---

{{< pro-badge >}} A space can register itself as a **log sink**: the knot server mirrors the log records of the space owner's *other* spaces in the zone to a log service running inside the sink space. Run VictoriaLogs in a space and watch your other spaces' logs flow into it, queryable with LogsQL — no server config changes, no admin involvement after the permission is granted.

---

## The Rules

- **Owner-scoped, period.** A sink only ever receives the logs of spaces owned by the **same user** — never other users' logs, no exceptions.
- **Tunnels included.** A user's sinks also receive the logs of requests proxied through that user's [web tunnels](../../configuration/logging/#tunnel-request-logging) — tagged with the tunnel name instead of a space — plus the tunnels opening and closing (`tunnel_open` / `tunnel_close` records), automatically, no extra configuration. Records carry `service: tunnel` so they select exactly like space records.
- **Off by default.** A space becomes a sink only when it explicitly advertises one (below); the base images ship with sink support but don't enable it.
- **Zone-local.** Sinks receive logs from spaces in their own zone only.
- **Permission-gated.** Registration requires the **Use Log Sinks** permission on the user's role; without it the registration is ignored (with a warning in the server log). Works in the free built-in Pro tier (2 users) — the licence only lifts the user cap.
- **Retry, no disk buffering.** Batches and retries on failure, but if the local service is down for long, records are dropped. This is a developer convenience, not a compliance channel — for that, use [`forward_space_logs`](../configuration/logging/) on the server (also Pro).

---

## Starting a Sink

A space advertises a sink with environment variables, set on the template or the space. These are **agent settings**: they are read by the agent inside the space, and setting `KNOT_LOG_SINK_PORT` is what triggers sink registration. The auth credentials are used only for the agent's localhost writes — they are never sent to the knot servers or written to the audit log.

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_LOG_SINK_PORT` | _(unset — not a sink)_ | Local port of the log service to mirror to; **setting this is what makes the space a sink** |
| `KNOT_LOG_SINK_FORMAT` | `vl` | Wire format the agent writes: `vl` (VictoriaLogs jsonline), `loki`, `gelf` or `json` |
| `KNOT_LOG_SINK_TOKEN` | _(unset)_ | Optional bearer token for the local log service (`Authorization: Bearer`) |
| `KNOT_LOG_SINK_USERNAME` | _(unset)_ | Optional basic auth username for the local log service (e.g. a Loki gateway user) |
| `KNOT_LOG_SINK_PASSWORD` | _(unset)_ | Optional basic auth password; ignored when a token is set |

The format must match what your log service accepts on that port — the same dialects the agent itself accepts logs in ([see sending logs](../logging/)).

### Worked example: a VictoriaLogs sink template

The [knot-victoria-logs base image](https://hub.docker.com/r/paularlott/knot-victoria-logs) bundles VictoriaLogs with the knot agent integration. Sink support is built in but **off by default** — enable it by setting `KNOT_LOG_SINK_PORT` in the template. A local-container template spec:

```yaml {filename="Container Spec"}
container_name: my-logs
image: "paularlott/knot-victoria-logs:1.52.0"
environment:
  - KNOT_LOG_SINK_PORT=9428
  - KNOT_LOG_SINK_FORMAT=vl
  - VICTORIA_LOGS_RETENTION_PERIOD=30d
volumes:
  - my-logs:/data
```

For a Nomad template, set the same variables in the task `env` block:

```hcl {filename="Nomad Job"}
task "victoria-logs" {
  driver = "docker"
  config {
    image = "paularlott/knot-victoria-logs:1.52.0"
  }
  env {
    KNOT_LOG_SINK_PORT     = "9428"
    KNOT_LOG_SINK_FORMAT   = "vl"
  }
}
```

{{< tip >}}
If you enable the image's HTTP auth (`VICTORIA_LOGS_USERNAME` / `VICTORIA_LOGS_PASSWORD`), the auth proxy fronts `:9428` — either point `KNOT_LOG_SINK_PORT` at `8428` (VictoriaLogs' loopback port, bypassing the proxy) or set `KNOT_LOG_SINK_USERNAME` / `KNOT_LOG_SINK_PASSWORD` to the same credentials.
{{< /tip >}}

Start a space from the template — once the agent registers, your other spaces' logs start flowing in. Query them by source space or service in the VictoriaLogs web UI on the space's port `9428`:

```sql
service="web"            -- all logs from the "web" service, any space
space_id="3f1b..."       -- everything from one space
```

Any other image works too — point `KNOT_LOG_SINK_PORT` at any log service that accepts one of the four formats (Loki, Graylog, a custom receiver...).

---

## What Happens, Step by Step

1. Every space's agent sends its log records to **all knot servers in its zone**.
2. Each server therefore sees every record, but only the **zone leader** acts on mirroring — it is the one server that forwards each record to the sinks, so every sink receives **exactly one copy** of each record, no matter how many servers there are.
3. The leader checks which sinks belong to the **same user** as the space that produced the record (and skips the sink's own space). Matching records are batched and pushed to each sink space's agent, which writes them to the local log service on `KNOT_LOG_SINK_PORT` in the configured format, retrying transient failures.
4. When a sink space stops or crashes, its agent connection drops — the knot servers detect this immediately, **drop any records still waiting in that sink's buffers**, and remove the sink registration. Nothing is spooled to disk. When the space starts again the agent re-registers and mirroring resumes from that point (records emitted while the sink was down are not replayed). Register and deregister appear in the audit log.

Mirrored records are tagged with the source space (`space_id` and `space_name`), the space owner (`user`), `service` and level, so you can filter by space, owner or service in queries. These tags take precedence: a structured field logged by the application with the same name (`service`, `user`, …) is dropped from the mirrored copy rather than overwriting the origin tags. Multiple sinks per user are allowed — each receives its own copy.

{{< tip "warning" >}}
Log sinks are a **developer helper, not a compliance channel**. Delivery is best-effort: bounded buffers, no disk spool, drops when the local service is down, and no replay of records missed while a sink was absent. For compliance-grade log retention use the server-side [`forward_space_logs`](../configuration/logging/) option (Pro) into an external logging service instead.

Sinks and `forward_space_logs` are **independent features** that happen to trigger from the same log handling: enabling one does not enable the other. A server can forward space logs to its external logging service with no sinks registered, and sinks work with forwarding off — both can also run side by side, each with its own delivery path.
{{< /tip >}}
