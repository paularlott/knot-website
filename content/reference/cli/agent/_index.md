---
title: knot agent
description: Command-line reference for the knot agent that runs inside a space.
type: Overview
tags: [api, cli]
weight: 20
---

The **knot agent** is a separate binary (`knot-agent`, built from `agent/`) that runs inside a space's container and connects it to the knot server. Inside the space it is invoked as `knot`.

These commands act on the space the agent is running in. They are started automatically by the container entrypoint, but are documented here for scripting, debugging, and manual use.

## `knot agent start`

Start the agent daemon and connect to the knot server.

```shell
knot agent start --endpoint https://knot.example.com:3000 --space-id <space-id>
```

Usually started automatically by the container entrypoint. Key options:

| Flag | Default | Description |
| ---- | ------- | ----------- |
| `--endpoint` | | Server address to connect to |
| `--space-id` | | ID of the space this agent provides |
| `--config`, `-c` | `knot.toml` | Configuration file (global flag) |
| `--ssh-port` | `22` | Port sshd runs on; `0` disables SSH |
| `--code-server-port` | `49374` | Port for code-server; `0` disables |
| `--disable-terminal` | `false` | Disable terminal access |
| `--disable-space-io` | `false` | Disable command execution and file copy |
| `--tcp-port` | | TCP ports to expose (repeatable) |
| `--http-port` | | HTTP ports to expose via the web UI (repeatable) |
| `--https-port` | | HTTPS ports to expose via the web UI (repeatable) |
| `--vnc-http-port` | `0` | Port for VNC over HTTP |
| `--methods-file` | | `.toml` or `.py` file registering JSON-RPC methods at startup |
| `--syslog-port` | `1514` | Syslog listen port; `0` disables |
| `--api-port` | `12201` | API/log listen port; `0` disables |
| `--update-authorized-keys` | `true` | Keep the user's SSH authorized_keys up to date |
| `--vscode-tunnel` | `vscodetunnel` | Screen running the VS Code tunnel; blank disables |
| `--use-tls` | `true` | Enable TLS |
| `--cert-file` / `--key-file` | | PEM certificate and key |
| `--tls-skip-verify` | `true` | Skip TLS verification when talking to the server |

---

## Space lifecycle (from inside the space)

### `knot agent shutdown`

Request shutdown of this space.

```shell
knot agent shutdown
```

### `knot agent restart`

Request a restart of this space.

```shell
knot agent restart
```

### `knot agent set-note`

Set the note shown for this space.

```shell
knot agent set-note "Deployment completed"
```

### `knot agent get-field`

Read a custom field value from this space's template.

```shell
knot agent get-field <field-name>
```

### `knot agent set-field`

Set a custom field value on this space.

```shell
knot agent set-field <field-name> <value>
```

---

## `knot event`

Emit a custom event from this space. The event type is prefixed with `custom.` automatically. The payload is a JSON string, or read from stdin if omitted.

```shell
knot event <type> [payload]
```

Examples:

```shell
knot event myapp.deployed '{"version": "1.2.3"}'

echo '{"version": "1.2.3"}' | knot event myapp.deployed
```

---

## `knot methods`

Register and unregister JSON-RPC methods for this space.

### `knot methods register`

Register methods from a `.toml` registration file or a `.py` Scriptling script that calls `server.register()`.

```shell
knot methods register <file>
```

### `knot methods unregister`

Remove all registered methods and stop the method server.

```shell
knot methods unregister
```

---

## `knot jobs`

Manage the scheduled jobs defined in this space's `~/.knot-jobs.toml` (see [Space Jobs](/docs/spaces/jobs/)).

```shell
knot jobs list
knot jobs run <job>
knot jobs enable
knot jobs disable
```

`run` triggers a job immediately — it works for disabled and manual-only jobs too. `enable`/`disable` start and stop the job runner (scheduled firing); the state is in memory only and resets on the next agent start.

---

## `knot port`

Forward ports from this space to ports in other spaces. Both spaces must be running, in the same zone, and owned by the same user.

### Forward a port

```shell
knot port forward <local-port> <space> <remote-port>
```

Options:
- `--persistent`: persist the forward across agent restarts
- `--force`: create the forward even if the target space is not running

```shell
knot port forward 8080 backend-api 3000
```

### List active forwards

```shell
knot port list
```

### Stop a forward

```shell
knot port stop <local-port>
```

---

## `knot tunnel`

Expose a local port in this space publicly via the knot server.

```shell
knot tunnel <protocol> <port> <name>
```

- **Protocols**: `http`, `https`

```shell
knot tunnel http 8080 myapp
```

Creates a tunnel at `<user>-myapp.<tunnel-domain>`.

---

## `knot run-script`

Execute a named script or a local `.py` file in this space (eval only).

```shell
knot run-script <script-or-file> [args...]
```

Options:
- `--no-fail`: exit successfully if the named script does not exist

Serving (JSON-RPC / HTTP / MCP) and the interactive REPL belong to the real Scriptling CLI in the space — use a template built from a Scriptling base image (for example `paularlott/knot-scriptling:0.21-alpine`). Scriptling picks up the `knot.*` libraries and your `lib` scripts automatically via the agent's package endpoints (`http://127.0.0.1:$KNOT_API_PORT/packages/knot.zip` and `.../libs.zip`, prewired by the base image), and `knot.apiclient` configures itself from the agent's `/connect` endpoint.

---

## See also

- [knot CLI](/reference/cli/knot/) — the main `knot` command run from your machine
- [Events](/reference/events/) — event sinks and the events system
- [Scripting](/docs/scripting/) — authoring scripts and MCP tools
