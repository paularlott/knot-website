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
| `--plugin` | | Scriptling plugin executable to load into space scripts (repeatable) |
| `--plugin-dir` | | Directory of Scriptling plugin executables to load into space scripts (repeatable) |
| `--syslog-port` | `1514` | Syslog listen port; `0` disables |
| `--api-port` | `12201` | API/log listen port; `0` disables |
| `--update-authorized-keys` | `true` | Keep the user's SSH authorized_keys up to date |
| `--vscode-tunnel` | `vscodetunnel` | Screen running the VS Code tunnel; blank disables |
| `--use-tls` | `true` | Enable TLS |
| `--cert-file` / `--key-file` | | PEM certificate and key |
| `--tls-skip-verify` | `true` | Skip TLS verification when talking to the server |
| `--registration-key` | | The space's registration key, required to register with the server (shown in the web UI next to the space ID) |
| `--server-cert-fingerprint` | | SHA-256 fingerprint of the server's agent certificate public key, used to verify the TLS connection |
| `--service-password` | | Password for the agent service |
| `--peer-port` | `12202` | Port for direct peer-to-peer connections; `0` disables |
| `--peer-external-port` | | External port peers should dial for direct connections |
| `--dns-resolver` | | Run a resident DNS resolver on `127.0.0.1:53` forwarding queries to the server's DNS |

### `knot agent wait-for-start`

Block until the agent daemon is running and accepting commands, then exit. Used by the container entrypoint before running setup commands.

```shell
knot agent wait-for-start [--timeout SECONDS]
```

### Configuration file

Every `knot agent start` option can be set in a TOML configuration file instead of on the command line. The agent looks for `knot.toml` in the current directory, then `$HOME/`, then `$HOME/.config/knot/`; point it at a specific file with `--config <path>` (or `KNOT_CONFIG`). Precedence is command-line flag → environment variable → config file → default, so a flag always wins over the file.

Options live under an `[agent]` table, keyed as shown in the tables above (for example `--space-id` → `agent.space_id`, `--ssh-port` → `agent.port.ssh`). Because the container entrypoint usually invokes `knot agent start` with a fixed command, baking a config file into the image (or mounting one) is the cleanest way to configure an agent per template — including which Scriptling plugins it loads.

```toml
[agent]
endpoint = "https://knot.example.com:3000"
space_id = "..."

# Scriptling plugins loaded into space scripts (see below)
plugins = ["/opt/knot/plugins/sql", "/opt/knot/plugins/valkey"]
plugin_dirs = ["/opt/knot/plugins"]

[agent.port]
ssh = 22
```

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

Inspect this space's jobs (see [Space Jobs](/docs/spaces/jobs/)). Jobs are managed from the web UI, `knot space jobs` on your machine, or the scriptling `knot.jobs` library.

```shell
knot jobs list
knot jobs run <job>
```

`run` triggers a job immediately — it works for disabled and manual-only jobs too.

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

### Throttle a forward

Apply network simulation to an existing forward; `--reset` clears all limits.

```shell
knot port throttle <local-port> [--latency ms] [--jitter ms] [--bandwidth kb/s] [--timeout ms] [--down] [--reset]
```

---

## `knot tunnel`

Expose a local port in this space publicly via the knot server.

```shell
knot tunnel http <port> <name> [--daemon]
knot tunnel https <port> <name> [--daemon]
knot tunnel list
knot tunnel stop <name>
```

- **Protocols**: `http`, `https`
- `--daemon`: hand the tunnel to the knot agent and exit; the tunnel then lives for the life of the agent

```shell
knot tunnel http 8080 myapp
```

Creates a tunnel at `<user>--myapp.<tunnel-domain>`.

---

## `knot run-script`

Execute a named script or a local `.py` file in this space (eval only).

```shell
knot run-script <script-or-file> [args...]
```

Options:
- `--no-fail`: exit successfully if the named script does not exist
- `--plugin` / `--plugin-dir`: Scriptling plugins to load for this run (repeatable). By default `run-script` inherits the agent's configured plugins (`agent.plugins` / `agent.plugin_dirs`), so a space set up with a database driver has it here too; passing either flag overrides the configured value for that run. See [Loading Scriptling plugins](#loading-scriptling-plugins).

Serving (JSON-RPC / HTTP / MCP) and the interactive REPL belong to the real Scriptling CLI in the space — use a template built from a Scriptling base image (for example `paularlott/knot-scriptling:0.21-alpine`). Load the `knot.*` libraries and your `lib` scripts via the agent's package endpoints (`--package http://127.0.0.1:$KNOT_API_PORT/packages/knot.zip --package http://127.0.0.1:$KNOT_API_PORT/packages/libs.zip`, or a scriptling config file), and `knot.apiclient` configures itself from the agent's `/connect` endpoint.

### Loading Scriptling plugins

The agent can load Scriptling plugins into the environment its scripts run in, the same way the standalone Scriptling CLI does. This is how a space reaches heavyweight libraries — most notably the Scriptling database drivers (`scriptling.sql`, `scriptling.sqlite`, `scriptling.badgerdb`, `scriptling.valkey`) — without those drivers being compiled into the agent binary. Both `knot agent start` (the daemon, for remotely-executed and system scripts) and `knot run-script` (ad-hoc scripts) accept the same flags and read the same config keys.

```shell
# one or more explicit plugin executables
knot agent start ... --plugin /opt/knot/plugins/sql --plugin /opt/knot/plugins/valkey

# or a directory of plugin executables (repeatable)
knot agent start ... --plugin-dir /opt/knot/plugins

# ad-hoc, for a single run-script invocation
knot run-script report.py --plugin-dir /opt/knot/plugins
```

Both flags can also be set from the environment or `knot.toml`:

| Flag | Environment variable | Config key |
| ---- | -------------------- | ---------- |
| `--plugin` | `KNOT_PLUGIN` | `agent.plugins` |
| `--plugin-dir` | `KNOT_PLUGIN_DIR` | `agent.plugin_dirs` |

Explicit `--plugin` executables load first, in order; each `--plugin-dir` is then scanned. A plugin's identity is its resolved path, so the same binary named explicitly and found again in a directory loads once. Once loaded, a script imports it by the name the plugin declares in its handshake, for example `import scriptling.sql as sql`. If a configured plugin fails to start the process exits, rather than run as though the plugin were present.

Standard CLI precedence applies to both commands: a `--plugin` / `--plugin-dir` flag overrides the config file for that invocation (it does not add to it), so `knot run-script` with no flag inherits the space's configured plugins, and with a flag uses exactly what you pass.

---

## See also

- [knot CLI](/reference/cli/knot/) — the main `knot` command run from your machine
- [Events](/reference/events/) — event sinks and the events system
- [Scripting](/docs/scripting/) — authoring scripts and MCP tools
