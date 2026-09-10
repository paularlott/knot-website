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

## September 2026

{{< version "v0.34.0" >}}

{{< changelog-item "added" >}}
- **Plugins**: extend knot entirely from a script's metadata. Plugins ship their own assets (logos, SVG icons) and can be single-file Go binaries or scriptling scripts. Key capabilities: a **layout-driven page system** where handlers return column grids with independent data fetching and per-panel gates; **forms** branching on request method with success/error envelopes and per-field errors; **tables** with row-action icon buttons, kebab menus, confirm dialogs, and popup forms; **field handlers** turning template custom fields into plugin-backed autocompleters and code editors; **MCP tool** exposure; and **export modules** whose classes appear as `plugin.<name>` in user tools via the gated loopback SDK. Plugins declare their generation (`api = 1`) so future versions can coexist, and load as pure parsing — a broken plugin never affects startup. Plugin config lives in `[plugins.<name>]` in `knot.toml`, reaches every handler as `request["config"]` (always present, never mutable), and fails at load if required keys are missing. The agent can also load Scriptling plugins via `--plugin` / `--plugin-dir` (or env/config equivalents) — this is how spaces access database drivers (`scriptling.sql`, `scriptling.sqlite`, `scriptling.badgerdb`, `scriptling.valkey`) without bundling them. See [Plugins](../docs/plugins/) and [knot agent](../reference/cli/agent/).

- **Become another user**: fast user switching between accounts. Link accounts a user may become from the user manager (new **Link Users** permission) — the link is one way, and the profile menu offers `Switch User` for the linked accounts plus `Back to <your account>` to return. Every switch is recorded in the audit trail {{< pro-badge >}}.

- **Template custom fields**: four improvements — **defaults** (prefilled on space creation, applied when API/CLI omits the field, but a deliberate blank is never overridden); **bool type** (styled toggle showing `true`/`false`); **required fields** (space form and API reject blank values, default can satisfy the requirement); and **select type** (dropdown sourced from a plugin field handler or a manual one-per-line list; autocomplete takes the same two sources). The template editor now badges required fields. The `knot.template` library can declare custom fields (types and defaults) on create and update.

- **Tunnels to any server from a space**: `knot tunnel` inside a space can now target any knot server — pass `--server` and `--token`, or an `-a` alias from the space's `knot.toml`, with or without `--daemon`. Several tunnels against different servers run side by side; each address is built from your username on the target and counts against its quota. `knot space tunnel` from the desktop gets the same via `--tunnel-server` / `--tunnel-token` / `--tunnel-alias`. Without an explicit target the tunnel uses the space's own server exactly as before. See [Agent Tunnels](../docs/tunnels/agent-tunnels/).

- **Tunnels-only API tokens**: token scoping gains a **Tunnels** scope — a key that can create, list and delete web and port tunnels (`/tunnel/*`, `/api/tunnels*`) and nothing else, for machines that should only ever expose a port. Scope prefix matching is now boundary-aware, so `/api/tunnels` no longer covers paths like `/api/tunnels-extra`. Scripts mint and revoke keys via the new `knot.token` library. See [API Tokens](../docs/api-tokens/).
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- **Embedded `knot.apiclient`**: `get(path, params)` passed positionally was being dropped by the Go transport (breaking `knot.space.list()` for non-admins, `skill.search()`, `usage_history()`); it now honours a positional params dict like the standalone client, across pages, MCP and the CLI.

- **Template picker vs quota**: the space-creation template picker now tints templates the owner lacks quota for ("Insufficient quota"), and when no available template fits, the out-of-quota dialog is shown instead of the picker.
{{< /changelog-item >}}

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
