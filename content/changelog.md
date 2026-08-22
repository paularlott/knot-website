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
- `knot run-script` is eval-only — serving and the REPL moved to the real Scriptling CLI (use a Scriptling base image; method servers become `Server("/usr/local/bin/scriptling", args=["--json-rpc", ...])`).
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- Agent package endpoints: in-space Scriptling gets `knot.*` libs and user/global `lib` scripts as cached zip packages (`/packages/knot.zip`, `/packages/libs.zip` on the agent API port), refreshed automatically on change; `knot.apiclient` self-configures in spaces via the agent.
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- **Scheduled space jobs**: spaces can define scheduled or manual jobs in `~/.knot-jobs.toml`, run by the agent while the space is running. List and trigger them from the web UI, `knot space jobs`, or `knot jobs` inside the space; output goes to the space's logs. See [Space Jobs](../docs/spaces/jobs/).

- **Space log forwarding** {{< pro-badge >}}: space logs now flow into the server's log output, external services included, as a single copy per zone. Off by default. See [Logging Configuration](../docs/configuration/logging/).

- **Space log sinks** {{< pro-badge >}}: run a log service (e.g. VictoriaLogs) in one space to query the logs of the owner's other spaces in the zone. Off by default, owner-scoped, requires the new **Use Log Sinks** permission. See [Log Sinks](../docs/spaces/log-sinks/).

- **On-disk log spooling** {{< pro-badge >}}: undeliverable log batches spool to disk and replay when the log service recovers, so outages lose no records (bounded at 256 MB).

- **GELF log output**: `[log.output]` now supports GELF alongside ndjson, Loki, and Elasticsearch, so logs can go straight to Graylog.

- **Native VictoriaLogs endpoint on the agent**: existing VictoriaLogs shippers work unchanged by pointing them at the agent.

- **Log delivery retries + stderr failover**: batches are retried with backoff on transient failures; failed records are mirrored to stderr until delivery recovers.

- **Cluster-wide failed-login blocking**: attempts spread across servers behind a load balancer now trip one shared budget. Thresholds are configurable.

- **Audit anomaly detection** {{< pro-badge >}}: detects failed-login bursts, credential spraying and bulk admin changes, emitting `Anomaly Detected` audit events to your external logging.

- **Richer user audit entries**: `User Create` / `User Update` events now record the target's roles and a `granted_admin` flag.

- **Config wizard**: new logging and cluster steps plus a login-rate-limiting toggle, with a visual refresh.

- **Desktop mode**: running `knot` with no arguments starts the server in the background with a system tray icon. Installable as a macOS app via `brew install --cask paularlott/tap/knot`; Windows builds detach from the console. See [Desktop Client](../docs/quick-start/client/).

- **First-run setup wizard**: desktop mode with no config opens a guided wizard in the browser that writes `~/.knot/knot.toml`; it can also join an existing cluster. Re-runnable at `/setup`, and it preserves hand edits and config sections it doesn't manage.

- **`${{ host_ip }}` in config addresses**: config values like `server.agent_endpoint` can use `${{ host_ip }}`, resolved to the host's IP on every start.
{{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **Agent listener is now TLS-only** (breaking): every server in a zone presents the same certificate, so agents verify one fingerprint for any of them. The `--agent-use-tls` flag is gone; manual agents must pass `--registration-key` (shown in the web UI next to the space ID). See [Manual Space](../docs/spaces/manual-space/).

- **Encryption key required at startup** (breaking): the encryption key (`server.encrypt`) now derives agent registration keys, agent tokens, and the zone's agent TLS certificate, and the server refuses to start without it. All members of a zone must share the same key.

- **Faster space start and stop**: deployments, restarts and stack operations are several times faster, and a failed image pull now falls back to the local image instead of failing the start.
{{< /changelog-item >}}

{{< changelog-item "security" >}}
- **Agent registration now requires a per-space key**: previously any peer reaching the agent listener could register as any space and receive the owner's SSH key and agent token. Registration now proves possession of the space's registration key, and failed attempts no longer disturb a connected agent.

- **Template export and node listing enforce template visibility**: both previously returned full job YAML, registry credentials included, for templates the caller couldn't access; they now apply the template-read visibility check, and deleted templates are no longer returned.
{{< /changelog-item >}}
