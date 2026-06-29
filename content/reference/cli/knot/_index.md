---
title: knot
weight: 10
description: Command-line reference for the main knot binary run from your machine or as the server.
---

The **`knot`** command-line interface runs on your machine to manage remote spaces, templates, stacks, and scripts, and on a host to run the knot server. It connects to a server using credentials stored by [`knot connect`](#knot-connect).

For commands that run *inside* a space, see the [knot agent](/reference/cli/agent/) reference.

---

## Server commands

### `knot server`

Start the knot server.

```shell
knot server --config knot.toml
```

Key options (all can be set in the config file):

| Flag | Description |
| ---- | ----------- |
| `--listen` | Address to listen on for client/web traffic |
| `--listen-agent` | Address to listen on for agent connections |
| `--listen-tunnel` | Address to listen on for tunnel connections |
| `--url` | The public URL of the server |
| `--tunnel-server` | URL for tunnel clients to connect to |
| `--wildcard-domain` | Wildcard domain used for proxying to spaces |
| `--download-path` | Path to serve download files from |
| `--encrypt` | Encryption key for stored variables |
| `--terminal-webgl` | Enable the WebGL terminal renderer |

### `knot scaffold`

Generate configuration and job templates to stdout.

```shell
knot scaffold --server > knot.toml
knot scaffold --client > knot.toml
knot scaffold --agent > agent.toml
knot scaffold --nomad > knot.nomad
```

Options: `--server`, `--client`, `--agent`, `--nomad`, `--system-prompt`.

### `knot genkey`

Generate a 32-byte encryption key for the `server.encrypt` / `server.cluster.key` config fields.

```shell
knot genkey
```

### `knot legal`

Print third-party license and legal notices.

```shell
knot legal
```

---

## Connection

### `knot connect`

Connect to a knot server and authenticate. Credentials are saved under `[client.connection.<alias>]` in `~/.config/knot/knot.toml`.

```shell
knot connect https://knot.example.com:3000
```

Options:
- `--alias`: name for this connection (default `default`; alphanumeric and `-`, starting with a letter, max 20 chars)
- `--use-web-auth`: authenticate via the web interface
- `--username`: username for authentication
- `--tls-skip-verify`: skip TLS verification (default `true`)

### `knot ping`

Verify connectivity to a server.

```shell
knot ping
```

---

## Working with spaces

All `knot space` subcommands accept `--server`, `--token`, `--tls-skip-verify`, and `--alias` to target a specific connection, falling back to the stored connection for the alias.

### Lifecycle

```shell
knot space list [--all-zones]
knot space create <space> <template> [--shell SHELL] [--custom-field name=value]
knot space start <space>
knot space stop <space>
knot space restart <space>
knot space delete <space>
knot space logs <space> [--follow]
```

Options for `create`:
- `--shell`: shell for the terminal (`sh`, `bash`, `zsh`, `fish`)
- `--custom-field name=value`: set a custom field at creation (repeatable)

### Running commands and scripts

```shell
knot space run <space> <command> [args...]
knot space run-script <space> <script> [args...]
```

### Copying files

```shell
# Local file into a space
knot space copy ./config.json <space>:/etc/app/

# From a space to the local machine
knot space copy <space>:/var/log/app.log ./logs/

# Between two spaces
knot space copy <source-space>:/app/build <dest-space>:/var/www/html
```

`--workdir`, `-w`: working directory for relative paths in a space.

### Reading and writing files

```shell
# Read a file (write to stdout)
knot space read-file <space> <path>

# Write content (use --content - to read from stdin)
knot space write-file <space> <path> --content "Hello"
echo "data" | knot space write-file <space> <path> --content -
```

### Custom fields and tunnels

```shell
knot space get-field <space> <field>
knot space set-field <space> <field> <value>

# Tunnel a port from a space to the local machine
knot space tunnel <space> <listen> <port> [--tls]
```

---

## Stack templates and instances

### `knot stack`

Manage stack definitions (reusable templates) and stack instances.

```shell
# Definitions
knot stack validate <file>
knot stack create-def <file>
knot stack apply <file>
knot stack list-defs [--details]
knot stack enable-def <name>
knot stack disable-def <name>
knot stack delete-def <name>

# Instances
knot stack create <definition> <prefix> [name]
knot stack list
knot stack start <stack>
knot stack stop <stack>
knot stack restart <stack>
knot stack delete <stack> [-y]
```

`knot stack create` creates one stopped space per component, names each with the given prefix, applies dependencies/port-forwards/custom fields, and groups them under the stack name. See the [knot.stack library reference](/reference/libraries/stack/) for the scripting API.

---

## Templates, scripts, skills, pools

### `knot template`

```shell
knot template list
```

### `knot script`

```shell
knot script list [--global]
knot script show <name>
knot script read <name>
knot script write <name> <file> [--create] [--description TEXT] [--active]
knot script resolve <name>
knot script delete <name>
```

### `knot skill`

```shell
knot skill list
knot skill show <name>
knot skill create <file> [--global] [--group ID] [--zone NAME] [--active]
knot skill update <file> [--group ID] [--zone NAME] [--active | --inactive]
knot skill delete <name>
```

### `knot pool`

Manage space pools (pre-warmed sets of spaces).

```shell
knot pool list
knot pool start <pool>
knot pool stop <pool>
knot pool set-size <pool> <count>
knot pool delete <pool>
```

---

## Methods

### `knot method`

Discover and call JSON-RPC methods registered by spaces.

```shell
# List visible methods, or show details for one
knot method list [method]

# Call a method
knot method call <method> [params]
knot method call <method> '[...]' --batch
```

---

## Access and forwarding (client side)

### `knot forward`

Forward connections between your machine and a space.

```shell
# SSH forwarding (use with ssh ProxyCommand)
knot forward ssh <space>
ssh -o ProxyCommand='knot forward ssh %h' user@spacename

# Port forwarding
knot forward port <local-addr> <space> <remote-port>
knot forward port 127.0.0.1:8080 myspace 80
```

### `knot port`

Forward a port from one space to another (orchestrated from the client).

```shell
knot port forward <from-space> <from-port> <to-space> <to-port> [--persistent] [--force]
knot port list <space>
knot port stop <space> <local-port>
```

### `knot tunnel`

Expose a local port on your machine publicly via the knot server.

```shell
knot tunnel <protocol> <port> <name>
knot tunnel http 8080 myapp
```

Protocols: `http`, `https`. Options: `--server`, `--token`, `--tls-skip-verify`.

### `knot ssh-config`

Manage `~/.ssh/config` entries for spaces (uses `knot forward ssh` as ProxyCommand).

```shell
knot ssh-config update
knot ssh-config remove
```

---

## Administration

### `knot admin`

Server administration commands.

```shell
knot admin backup [--encrypt-key KEY]
knot admin restore <backup-file>
knot admin rename-zone <old> <new>
knot admin reset-totp <username>
knot admin set-password <username> <password>
```

---

## Global flags and configuration

Global flags available on most commands:

- `--config`, `-c`: configuration file to use (default `knot.toml` in `.`, `$HOME`, or `$HOME/.config/knot/`)
- `--log-level`: `trace`, `debug`, `info`, `warn`, `error`, `fatal`, `panic`
- `--nameservers`: DNS nameservers (repeatable)
- `--help` / `--version`

### Configuration file

Client connections are stored in `~/.config/knot/knot.toml`:

```toml
[client.connection.default]
server = "https://knot.example.com:3000"
token = "<api-token>"

[client.connection.production]
server = "https://knot-prod.example.com:3000"
token = "<api-token>"
```

Target a non-default connection with `--alias`:

```shell
knot space list --alias production
```

Or override entirely with `--server` and `--token`.

### Environment variables

- `KNOT_CONFIG`: override the config file path
- `KNOT_LOGLEVEL`: override the log level
- `KNOT_TLS_SKIP_VERIFY`: skip TLS verification
- `KNOT_NAMESERVERS`: DNS nameservers

### Exit codes

- `0`: success
- `1`: error
