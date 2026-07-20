---
title: knot
description: Command-line reference for the main knot binary run from your machine or as the server.
type: Overview
tags: [api, cli]
weight: 10
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
knot space eval <space> <code|-> [args...]
```

`eval` runs inline Scriptling source directly — no stored script needed. Pass the
code as a quoted argument, or use `-` to read it from stdin. Trailing positionals
become the script's `sys.argv` (`argv[0]` is `"eval"`). Output streams live, so it
pipes cleanly:

```shell
knot space eval web "print(knot.space.run('web','uname',args=['-a']))"
echo 'print(json.dumps(stats))' | knot space eval web - | jq .
```

### Searching and editing files

```shell
knot space grep <space> <pattern> [path]   # one match per line: file:line: text
knot space find <space> [path]              # one path per line
knot space sed   <space> <old> <new> [path] # literal in-place replace
```

`grep` and `find` are read-only and run in the space's agent via a parallel
worker pool — no file contents leave the space. `sed` modifies files in place
(atomic temp-file + rename). All three take `--json` for structured output, and
share filter flags (`-i` ignore case, `-r` recursive, `--glob`, ...).

```shell
knot space grep web "TODO" src -r --glob "*.py"
knot space find web ~ --name "*.md"
knot space sed web "old_name" "new_name" src/ -r --glob "*.py"
knot space sed web --regex 'def get_(\w+)\(' 'def fetch_${1}(' src/app.py
knot space sed web --extract '(\w+)=(\S+)' .env | jq .
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

### Uploading a directory tree

```shell
# Mirror a local directory to a space: upload the tree AND delete remote files not present locally
knot space mirror ./src <space>:/var/www/html

# Preview what would be uploaded/deleted without doing it
knot space mirror --dry-run ./src <space>:/var/www/html

# Skip patterns (repeatable); basename, full relative path, or ancestor match
knot space mirror --exclude node_modules --exclude '*.log' ./src <space>:/var/www/html

# Content-based comparison (crc64) — upload only when bytes differ
knot space mirror --hash ./src <space>:/var/www/html

# Read-only integrity check — report mismatches without uploading
knot space mirror --verify ./src <space>:/var/www/html

# Verbose output — show every action per file
knot space mirror --verbose ./src <space>:/var/www/html
```

`knot space mirror` uploads a local directory tree to a space in parallel (default 8 workers, configurable via `--parallel N`). Each file's mtime and permission bits are preserved on the destination. After the uploads complete, any file on the space that doesn't exist locally is removed (subject to `--exclude`) — the destination ends up as a one-way mirror of the source.

`--dry-run` lists every intended upload and delete without performing any I/O against the space.

By default mirror decides whether a file needs uploading by comparing mtime and size (fast, uses stat only). To force content-based comparison, pass `--hash`: each file is crc64-hashed locally before upload and remotely during the walk — only truly different bytes are transferred. Pass `--verify` for a read-only check: every file is hashed on both sides and mismatches are reported without uploading.

`--verbose` prints every file action (upload, skip, delete, hash, verify) to stderr as the mirror progresses.

Mirror is one-directional (local → space) and always performs deletes — that's what "mirror" means. For continuous two-way sync, mutagen against the space's SSH endpoint is the recommendation.

### Deleting files

```shell
# Remove a single file
knot space delete-file <space> /var/www/old.html

# Remove a directory and its contents
knot space delete-file --recursive <space> /var/www/old_dir

# Non-recursive delete on a non-empty directory fails (matches os.Remove semantics)
```

Missing paths are treated as success — safe to call from scripts and CI that computed their delete list against a slightly stale snapshot. `--recursive` uses os.RemoveAll semantics; without it, a non-empty directory delete fails rather than silently descending.

### Reading and writing files

```shell
# Read a file (write to stdout)
knot space read-file <space> <path>

# Read a 1-based line range (e.g. lines 100-119)
knot space read-file <space> <path> --offset 100 --limit 20

# Write content (use --content - to read from stdin)
knot space write-file <space> <path> --content "Hello"
echo "data" | knot space write-file <space> <path> --content -

# Append or prepend instead of overwriting
knot space write-file <space> /app/log.txt --content "new entry" --mode append
knot space write-file <space> /app/header.py --content "# License" --mode prepend
```

`knot.space.write_file` (scriptling) and the underlying HTTP endpoint also accept optional `mtime_ns` (Unix nanoseconds) and `file_perm` (int bits like `0o644`) for callers that need the destination file to match a known source's metadata — used internally by `copy --recursive`.

### Finding files

```shell
# Names only — fast (no per-entry stat on the space when filters are inactive)
knot space find web --name '*.php'

# ls-style output with size, mtime, and type — incurs a per-entry stat
knot space find web --long

# Structured JSON (entries when --long, otherwise paths)
knot space find web --long --json | jq .
```

### Custom fields and port forwards

```shell
knot space get-field <space> <field>
knot space set-field <space> <field> <value>

# Manage a space's inter-space port forwards
knot space port forward <from-space> <from-port> <to-space> <to-port> [--persistent] [--force]
knot space port list <space>
knot space port stop <space> <local-port>
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

Link a service running on your local machine into a space so the space can reach it. Active only while the command runs (Ctrl-C to stop).

```shell
knot port <space> <space-port> <local-port> [--tls]
```

### `knot space port`

Manage a space's inter-space port forwards (orchestrated from the client).

```shell
knot space port forward <from-space> <from-port> <to-space> <to-port> [--persistent] [--force]
knot space port list <space>
knot space port stop <space> <local-port>
```

### `knot space tunnel`

Manage a space's agent-owned web tunnels (expose a space port to the internet as `<user>--<name>.<domain>`). Tunnels are owned by the space's agent and run until the agent exits or they are stopped; they are not persisted.

```shell
knot space tunnel http <space> <port> <name>
knot space tunnel https <space> <port> <name>
knot space tunnel list <space>
knot space tunnel stop <space> <name>
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
