---
title: Changelog
description: Keep track of all changes, updates, and improvements to knot.
type: Changelog
tags: [changelog]
layout: "changelog"
draft: false
weight: 100
navSection: docs
---

## August 2026

{{< version "v0.33.0" >}}

{{< changelog-item "breaking" >}}
- **The agent listener is now TLS-only**: every server in a zone presents the same certificate, so agents verify one fingerprint for any of them. The `--agent-use-tls` flag has been removed, and manual agents must now pass `--registration-key` (shown in the web UI next to the space ID). See [Manual Space](../docs/spaces/manual-space/).

- **An encryption key is required at startup**: the server now refuses to start without one (`server.encrypt`). The key derives agent registration keys, agent tokens, and the zone's agent TLS certificate, so every member of a zone must share the same one.

- **`knot run-script` is now evaluation-only**: it runs a script to completion and nothing more. Interactive scriptling sessions and long-running method servers now run on the real Scriptling CLI in the space — use a Scriptling base image and start servers with `Server("/usr/local/bin/scriptling", args=["--json-rpc", ...])`.
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- **Desktop mode**: run `knot` with no arguments and the server starts in the background with a system tray icon — installable as a macOS app via `brew install --cask paularlott/tap/knot`; Windows builds detach from the console. The first run (with no config) opens a browser wizard that writes `~/.knot/knot.toml`, and it can also join an existing cluster. See [Client](../docs/quick-start/client/).

- **Scriptlings get the knot library everywhere**: inside a space, scriptlings can now import `knot.*` and your user and global `lib` scripts — served as cached packages and refreshed automatically. Outside a space, the Scriptling CLI loads the knot binary as a plugin (`scriptling --plugin knot`), so the same scripts run from your desktop with API access routed through the plugin and the token kept out of your code.

- **Space jobs**: a space can run its own shell commands on a cron schedule or on demand, executed by its agent while it runs. Definitions live on the space, so they survive restarts and can be edited while it's stopped — from the web UI, the CLI (`knot space jobs`), or a scriptling via `knot.jobs`. Templates can ship jobs that are copied into every space created from them; editing needs the new **Edit Space Jobs** permission. Output goes to the space's logs. See [Space Jobs](../docs/spaces/jobs/).

- **Space log forwarding** {{< pro-badge >}}: space logs can now flow into the server's external logging — external services included — as a single copy per zone. Off by default. See [Logging Configuration](../docs/configuration/logging/).

- **Space log sinks** {{< pro-badge >}}: run a log service (e.g. VictoriaLogs) in one space and query the logs of the owner's other spaces in the zone. Off by default, owner-scoped, requires the new **Use Log Sinks** permission. See [Log Sinks](../docs/spaces/log-sinks/).

- **On-disk log spooling** {{< pro-badge >}}: undeliverable log batches spool to disk (bounded at 256 MB) and replay when the log service recovers, so an outage loses no records.

- **More ways to ship logs**: `[log.output]` now supports GELF alongside ndjson, Loki, and Elasticsearch (straight to Graylog), the agent speaks VictoriaLogs natively so existing shippers work unchanged when pointed at it, and delivery retries with backoff — failed records mirror to stderr until the service recovers.

- **Cluster-wide failed-login blocking**: login attempts spread across servers behind a load balancer now trip one shared block, not one per server. Thresholds are configurable.

- **Audit anomaly detection** {{< pro-badge >}}: failed-login bursts, credential spraying, and bulk admin changes are detected automatically and emitted as `Anomaly Detected` audit events to your external logging.

- **Data-access auditing**: see who read, wrote, or copied which file in a space, and who opened a terminal session — paths and sizes only, never file contents. Built for environments holding copies of production data; SSH logins are recorded per key attempt, success or failure. Off by default. See [Logging Configuration](../docs/configuration/logging/).

- **A broader audit trail**: API token creation, update, and deletion; config changes made through the setup wizard; and the provider behind every login (password or OAuth) now land in the audit trail. `User Create` / `User Update` events also record the target's roles and a `granted_admin` flag.

- **Config wizard**: new logging and cluster steps, a login-rate-limiting toggle, and a visual refresh.

- **`knot.space.wait_for_start`**: pause a script until a space is running — returns True immediately if it already is, polls until timeout, and returns False instead of raising. For scripts that provision a space and then work against it.

- **`${{ host_ip }}` in config addresses**: values like `server.agent_endpoint` can use `${{ host_ip }}`, resolved to the host's current IP on every start — no more hardcoding IPs on machines whose address changes.
{{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **Sifting knot records on a shared logging service**: every record knot delivers now carries `source: knot`, and knot's own services are prefixed — `knot_audit`, `knot_tunnel`, `knot_syslog` for ingested records with no service of their own — while application-chosen service names are left alone. One selector (`source:knot`) finds everything a knot shipped.

- **The audit trail ignores the log level**: raising `log.level` to cut diagnostic noise no longer stops audit events (or forwarded space logs / tunnel requests) from reaching the external logging service — they travel their own always-on pipeline.

- **Audit settings moved to `[server.audit]`**: routing, retention, and the new data-access options now live in one section; configs using the older flat `server.audit_*` keys keep working.

- **Faster space start and stop**: spaces now start and stop several times faster — deployments, restarts, and stack operations included. A failed image pull falls back to the local image instead of failing the start.
{{< /changelog-item >}}

{{< changelog-item "security" >}}
- **Agent registration now requires a per-space key**: previously any peer reaching the agent listener could register as any space and receive the owner's SSH key and agent token. Registration now proves possession of the space's registration key, and failed attempts no longer disturb a connected agent.

- **Template export and node listing enforce template visibility**: both previously returned full job YAML — registry credentials included — for templates the caller couldn't access. They now apply the template-read visibility check, and deleted templates are no longer returned.
{{< /changelog-item >}}
