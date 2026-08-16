---
title: Anomaly Detection
description: Audit stream anomaly detection for failed logins, credential spraying, and event sink failures.
type: Overview
tags: [security, configuration, audit]
weight: 71
---

{{< pro-badge >}} Anomaly detection watches **knot**'s audit event stream and raises an **`Anomaly Detected`** audit event when a rule fires — failed-login bursts per user, credential spraying per source IP, and event sink delivery failures.

Detection is a layer on top of [audit logging](../logging/), not a replacement: the raw audit stream (login successes and failures, config changes, space lifecycle) is always the evidence trail, and long-term retention belongs in your external logging service. Detection adds an in-product signal for teams that don't run a full SIEM.

---

## Does it require the internal audit store?

**No.** Detection taps audit events in-process as they are emitted — before they are routed — so it works with any `server.audit_routing` setting. The internal audit store can be off (`external`) without affecting detection.

What *does* change with routing is where the **alerts** land, because an anomaly alert is itself an audit event:

| `server.audit_routing` | Alerts appear in the audit log UI | Alerts sent to `[log.output]` |
| ---------------------- | --------------------------------- | ------------------------------ |
| `internal` (default)  | Yes — until `audit_retention` expires them | No |
| `external`            | No                                | Yes |
| `both`                | Yes — until `audit_retention` expires them | Yes |

{{< tip >}}
For compliance deployments, use `both` (or `external`): the internal store is a convenience window that expires entries after `server.audit_retention` days, while your external logging service holds the durable copy of both the audit stream and the anomaly alerts.
{{< /tip >}}

---

## Rules

| Rule                | Watches                                             | Keyed by                | Defaults          |
| ------------------- | --------------------------------------------------- | ----------------------- | ----------------- |
| `failed_login_user` | `Login Failed` audit events                         | Actor (the submitted email) | 10 within 10 min  |
| `failed_login_ip`   | `Login Failed` audit events                         | `source_ip`             | 10 within 10 min  |
| `event_sink_failures` | Event sink delivery/script failures and drops     | — (global)              | 10 within 10 min  |

The per-IP rule catches credential spraying — many failed logins for *different* accounts from one source — which the per-user rule alone would miss.

Repeated alerts for the same rule and subject are suppressed by the alert cooldown (default 15 minutes).

---

## Alert Format

An anomaly is a normal audit event, so it flows through audit routing, cluster gossip and the audit API like any other:

- **Event:** `Anomaly Detected`
- **Actor / actor type:** `detection` / `System`
- **Details:** human-readable summary, e.g. `failed_login_user: 10 events within 10m0s`
- **Properties:** `rule`, `subject` (user or IP), `count`, `window`, and `source_ip` when known

Query alerts in VictoriaLogs with e.g. `{stream="audit"} | event="Anomaly Detected"`.

---

## Configuration

```toml
[server.detection]
  enabled = true
  failed_login_threshold = 10   # failed logins per user / per IP before an alert
  failed_login_window = 10      # minutes
  event_sink_threshold = 10     # event sink failures before an alert
  event_sink_window = 10        # minutes
  alert_cooldown = 15           # minutes between repeated alerts (same rule + subject)
```

Or via flags / environment variables:

- **`--detection-enabled`** / **`KNOT_DETECTION_ENABLED`**
- **`--detection-failed-login-threshold`** / **`KNOT_DETECTION_FAILED_LOGIN_THRESHOLD`**
- **`--detection-failed-login-window`** / **`KNOT_DETECTION_FAILED_LOGIN_WINDOW`**
- **`--detection-event-sink-threshold`** / **`KNOT_DETECTION_EVENT_SINK_THRESHOLD`**
- **`--detection-event-sink-window`** / **`KNOT_DETECTION_EVENT_SINK_WINDOW`**
- **`--detection-alert-cooldown`** / **`KNOT_DETECTION_ALERT_COOLDOWN`**

{{< tip >}}
Detection is part of Knot Pro and works in all Pro installs, including the free built-in tier (limited to 2 users) — no licence key needed. The licence only lifts the user cap.
{{< /tip >}}

---

## Cluster Behaviour

Detection works correctly across all deployment topologies:

- **Single server** — the server sees every event it emits, which is all of them.
- **Multiple servers per zone / cluster** — audit events are gossiped between servers, and detection taps both local emission and gossip delivery, so counters see the **cluster-wide stream**, not just local traffic. A failed-login burst spread across servers by a load balancer still trips the threshold — counts are not split per server.
- **Exactly one alert per burst** — only the elected leader of each zone runs detection, and an alert fires on the leader in the zone where the threshold was crossed. A burst spanning zones or servers still yields a single `Anomaly Detected` event cluster-wide, not one per server.

Leadership follows knot's normal zone leader election: if the leader fails, another server takes over automatically. Rule state is in-memory, so counters reset when leadership moves or a server restarts — thresholds are small windows, so this is rarely noticeable in practice, but a burst straddling a failover may need to rebuild its count before alerting. Nothing is persisted to the internal database.
