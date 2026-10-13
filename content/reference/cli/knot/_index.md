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

Running bare `knot` with no subcommand starts the same server together with a system tray icon — see [Desktop Mode](/docs/quick-start/desktop-mode/).

### `knot server config-wizard`

Run the web-based configuration wizard: a local web UI with an embedded TOML editor that writes a `knot.toml`.

```shell
knot server config-wizard [--port PORT] [--listen ADDR]
```

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

Manage stored connections:

```shell
knot connect list
knot connect delete <alias>
```

### `knot ping`

Verify connectivity to a server.

```shell
knot ping
```

### `knot mcp`

Serve the knot MCP server over stdio, proxying a remote knot server's `/mcp` endpoint, for MCP hosts that launch a server as a subprocess (e.g. Claude Desktop) rather than connecting over HTTP. The endpoint serves knot's own tools, `--show-all` also surfaces discoverable tools, change notifications flow through, and authentication comes from the stored connection, so no token appears in the host's configuration.

```json
{
  "mcpServers": {
    "knot": { "command": "knot", "args": ["mcp", "--alias", "default"] }
  }
}
```

Options:
- `--alias`: the stored connection to use (default `default`)
- `--server`, `--token`: address and API token of the server, overriding the alias
- `--tls-skip-verify`: skip TLS verification (default `true`)
- `--show-all`: also expose discoverable tools, not just native ones

Without `--show-all`, the host can still find and run the discoverable tools with `tool_search` and `execute_tool`, which go through to the server. The server's skills are served too. The server must have MCP enabled (`[server.mcp]` `enabled = true`) and the user the **Use MCP Server** permission; otherwise `knot mcp` exits with the reason.

Also built into the agent binary — inside a space, `knot mcp` connects through the agent socket with no configuration.

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
knot space delete <space> [-f]
knot space logs <space> [--follow]
```

Options for `create`:
- `--shell`: shell for the terminal (`sh`, `bash`, `zsh`, `fish`)
- `--custom-field name=value`: set a custom field at creation (repeatable)

`delete` asks for confirmation; `-f`/`--force` skips the prompt.

### Running commands and scripts

```shell
knot space run <space> <command> [args...]
knot space run-script <space> <script> [args...]
knot space eval <space> <code|-> [args...]
```

`run` takes `-t`/`--timeout` (seconds, default 30) and `-w`/`--workdir` (working directory for the command; a relative path is relative to the space user's home directory). Give these before the space name: everything after the command is passed to it unchanged, flags included, so `knot space run -t 600 dev claude -p "fix the tests"` hands `-p` to `claude`. Each argument reaches the command as it is, without shell expansion; to use pipes or redirection, pass one quoted string, as in `knot space run dev 'npm test | tail -20'` or `knot space run dev sh -c '...'`. The command's stdout and stderr go to knot's stdout and stderr, and knot exits with the command's exit code (124 when it timed out), so `run` works in scripts with `set -e` and redirection.

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

# Watch for local changes and sync them live (Ctrl+C to stop)
knot space mirror --watch --exclude node_modules ./src <space>:/var/www/html
```

`knot space mirror` uploads a local directory tree to a space in parallel (default 8 workers, configurable via `--parallel N`). Each file's mtime and permission bits are preserved on the destination. A destination path without a leading `/` is relative to the space user's home directory. If any file can't be uploaded, mirror exits with an error once it has done the rest. After the uploads complete, any file on the space that doesn't exist locally is removed (subject to `--exclude`) — the destination ends up as a one-way mirror of the source.

`--dry-run` lists every intended upload and delete without performing any I/O against the space.

By default mirror decides whether a file needs uploading by comparing mtime and size (fast, uses stat only). To force content-based comparison, pass `--hash`: each file is crc64-hashed locally before upload and remotely during the walk — only truly different bytes are transferred. Pass `--verify` for a read-only check: every file is hashed on both sides and mismatches are reported without uploading.

`--verbose` prints every file action (upload, skip, delete, hash, verify) to stderr as the mirror progresses. `--debug` logs why each file was uploaded (new, size differs, mtime drift), for diagnosing a mirror that keeps re-uploading.

`--watch` keeps mirror running after the initial sync. It watches the local tree for file creations, modifications, and deletions, and syncs each change to the space in real time (one-way: local → space). Excludes are honoured — excluded paths are never watched or uploaded. New directories are picked up automatically, including their contents. Vim swap files (`.*.swp`) are excluded by default. Events are debounced (300ms) so editors that save atomically (write temp → rename) produce a single upload, not a burst. Press Ctrl+C to stop.

Mirror is one-directional (local → space) and always performs deletes — that's what "mirror" means. For continuous two-way sync with a space, mutagen against the space's SSH endpoint is the recommendation. To keep a local directory and a [file storage](#knot-file) bucket folder in step both ways, use `knot file sync --two-way --watch`.

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

### Custom fields

```shell
knot space get-field <space> <field>
knot space set-field <space> <field> <value>
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

Lists the templates available to you, with name, platform and resource settings. Export and import moved to [`knot admin template`](#knot-admin).

### `knot script`

```shell
knot script list [--global]
knot script read <name> [--info]
knot script write <name> [file] [-c|--create] [-d|--description TEXT] [--active]
knot script delete <name>
```

`write` reads the script from stdin when no file is given. `--active` defaults to true.

### `knot skill`

```shell
knot skill list
knot skill show <name>
knot skill create <file> [--global] [--group ID] [--zone NAME] [--active]
knot skill update <file> [--group ID] [--zone NAME] [--active | --inactive]
knot skill delete <name>
```

### `knot pool`

Manage space pools (pre-warmed sets of spaces), including exclusive member leases on lease-enabled pools.

```shell
knot pool list
knot pool create <pool> <template> [--count 3] [--start] [--lease-time 2h|none] [--lease-extensions N|unlimited] [--custom-field name=value]
knot pool start <pool>
knot pool stop <pool>
knot pool set-size <pool> <count>
knot pool update <pool> [--custom-field name=value] [--unset-custom-field name] [--clear-custom-fields]
knot pool delete <pool> [-y]

# Exclusive member leases (requires lease_max_time on the pool)
knot pool acquire <pool> [--time 5m|none] [--wait 2m] [--json]
knot pool extend <member> [--time 5m|none] [--json]
knot pool release <member> [--destroy] [--json]
knot pool leases <pool> [--json]
```

`create` makes a pool from a template name or ID, stopped unless `--start` is given. `--lease-time` enables exclusive member leases with that maximum lease length (`none` = leases last until released); leases are off without it. `--lease-extensions` sets how many times a lease may be extended (default 0, `unlimited` for no cap). `--custom-field` (repeatable) sets a template custom field on every member.

`update` sets (`--custom-field`) or removes (`--unset-custom-field`) the custom field values members get; `--clear-custom-fields` removes them all first. With no flags it shows the current values. Members pick up a change when they are next created or started, so restart the pool (stop, then start) to apply it to all of them.

`delete` asks for confirmation; `-y`/`--yes` skips the prompt.

`acquire` checks one member out for the caller's exclusive use until the
lease ends — shared method routing and pool-name port routing skip it while
held. `--time` bounds the hold (`none` = never expire, on no-timeout pools
only, otherwise the pool's configured maximum); `--wait` waits for a member
when none is free yet — including one that is mid-start or being replaced —
and defaults to 10s (`--wait 0s` fails immediately). `release --destroy`
deletes the member and creates a fresh replacement instead of returning it. `extend` renews from now, bounded by the
pool's extension count. `release` returns the member early; it rejoins the
pool once in-flight work drains (~15s). Lease operations key off the space —
the name or id acquire returned — never a lease id; the space is what you
ssh to, and a member holds at most one lease. The lease commands accept the lease
id or the held member's name / space id, and `--json` emits the structured
lease (or lease list) for piping into other tools.

---

## File storage

### `knot file`

Work with [file storage](/docs/file-storage/) buckets. A bucket's files are written `bucket:path` (`bucket:` is the whole bucket); any other path is local. Buckets are named `<username>--<name>`: use the short name for your own buckets and the full name for buckets shared with you.

```shell
knot file ls [bucket:[path]] [-r] [--all] [--json]
knot file copy [-r] <source>... <destination>
knot file mv [-f|--overwrite] <source>... <destination>
knot file cat <bucket:path>...
knot file rm [-r] <bucket:path>...
knot file sync <source> <destination> [--delete] [-n|--dry-run] [-w|--watch] [--two-way]
               [-x|--exclude PATTERN] [--no-default-excludes] [--allow-mass-delete] [--state-file PATH]
knot file usage [--json]

knot file bucket list [--all] [--json]
knot file bucket create <name>
knot file bucket delete <name> [--force]
knot file bucket info <name> [--json]
knot file bucket permissions <name> [--json]
knot file bucket share <name> (--user NAME | --group NAME | --all) [--write]
knot file bucket unshare <name> (--user NAME | --group NAME | --all)
knot file bucket transfer <name> <user> [--force]
```

`ls` is also `list`, `copy` is also `cp`, `mv` is also `move` and `rm` is also `delete`.

- `copy` goes from the sources to the last argument, in the direction the paths imply: local to bucket, bucket to local, or bucket to bucket (on the server, moving no data). `-r` copies directories and bucket folders; their contents go into the destination folder. Several sources, a folder or a wildcard need a destination folder: a bucket path ending in `/` (or `bucket:`), or a local directory. A wildcard (`*`, `?`, `[...]`, and `**` for any number of folders) in a bucket path is quoted: `'bucket:logs/*.log'`. `-` is stdin as the source or stdout as the destination. Files at the destination are replaced. See [Working with Files](/docs/file-storage/using-files/#working-with-files) for the full rules.
- `mv` renames or moves files and folders: into a destination folder (ending in `/`) keeping the names, or to a new name for a single source. Within a bucket it happens on the server and moves no data; between buckets it copies on the server and then removes the source. It refuses to replace an existing file unless `-f`/`--overwrite` is given.
- Modification times are recorded on upload and restored on download, and kept when copying between buckets.
- `sync` makes the destination match the source, either side being a local directory or a bucket folder, so it uploads, downloads or copies between buckets as the paths imply. It transfers only files whose size or SHA-256 differ, keeping modification times; `--delete` removes destination files missing from the source, `-n`/`--dry-run` shows the changes without making them. `-x`/`--exclude` leaves out paths matching a pattern such as `node_modules/` or `*.log` (a trailing `/` matches folders only; repeatable).
- `sync -w`/`--watch` keeps running and makes each change as it happens, until interrupted. `--two-way` syncs a local directory and a bucket folder both ways: a file changed on both sides since they last matched is kept both ways, the local copy renamed `name.conflict-<host>-<time>`, and deletions pass to the other side only with `--delete` (without it a deleted file is put back from the other side). The state the two sides last agreed on is kept between runs in the user's configuration directory, or in `--state-file` (two-way only). `--watch` and `--two-way` work between a local directory and a bucket folder, not two bucket folders, and `--dry-run` can't be combined with `--watch`.
- Watched and two-way syncs leave out version control folders (`.git`, `.hg`, `.svn`) and editor and system scratch files unless `--no-default-excludes` is given. As a guard, a pass that would delete more than half of a side's files (and more than 10), or everything because the other side is empty, is refused unless `--allow-mass-delete` is given; while watching, those deletions are held back and the rest of the changes go ahead.
- `ls` with no path lists your buckets; `--all` lists every bucket for file storage managers (users with the Manage File Storage permission). A path may be a folder (listed one level, or everything below with `-r`), a file or a wildcard.
- `rm` takes several paths and wildcards; a folder or `bucket:` needs `-r`. It never deletes the bucket itself.
- `bucket delete` refuses a bucket that still holds files unless `--force` is given.
- `bucket create` takes the short name (3–30 lowercase letters, digits and hyphens, no `--`) and creates `<username>--<name>`.
- `--json` prints the result as JSON for scripts: `ls` of a bucket path gives `{"bucket", "prefix", "prefixes", "objects"}`, `ls` and `bucket list` give an array of buckets, `bucket info` one bucket, `bucket permissions` `{"bucket", "owner", "access", "grants"}` and `usage` the usage and limits. Empty results are empty arrays.
- `bucket share` and `unshare` need the Share Buckets permission. `bucket transfer` needs Transfer Buckets for your own buckets; file storage managers can transfer any bucket.
- `bucket transfer` renames the bucket into the new owner's namespace (`paul--configs` becomes `bob--configs`). It refuses when the new owner already has that name. It also refuses when the bucket would take them over their limits, unless a file storage manager gives `--force`.
- `bucket permissions` lists the owner and grants (the full list for the owner and file storage managers, your own access otherwise).
- Inside a space the server and credentials are discovered through the agent; on the desktop `--alias` picks the saved connection. An explicit `--server`/`--token` pair overrides both.

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
knot port <space> <space-port> <local-port> [--tls] [--port-tls-name NAME] [--port-tls-skip-verify]
```

`--tls` encrypts the tunnel. When the local service speaks HTTPS, `--port-tls-name` sets the name presented to it and `--port-tls-skip-verify` (default true) accepts a self-signed certificate.

### `knot space port`

Manage a space's inter-space port forwards (orchestrated from the client).

```shell
knot space port forward <from-space> <from-port> <to-space> <to-port> [--persistent] [--force]
knot space port list <space>
knot space port stop <space> <local-port>
knot space port throttle <space> <local-port> [options]
```

`throttle` applies network simulation to an existing forward: `--latency` (ms), `--jitter` (ms), `--bandwidth` (KB/s), `--timeout` (ms, kills the connection after this duration), `--down` (block all traffic), and `--reset` to clear all limits.

```shell
knot space port throttle web 8080 --latency 200 --jitter 50 --bandwidth 1024
knot space port throttle web 8080 --reset
```

### `knot space tunnel`

Manage a space's agent-owned web tunnels (expose a space port to the internet as `<user>--<name>.<domain>`). Tunnels are owned by the space's agent and run until the agent exits or they are stopped; they are not persisted.

```shell
knot space tunnel http <space> <port> <name>
knot space tunnel https <space> <port> <name>
knot space tunnel list <space>
knot space tunnel stop <space> <name>
```

`http` / `https` accept target flags to create the tunnel on another knot server instead of the space's own: `--tunnel-server` + `--tunnel-token` (an API token valid on that server), or `--tunnel-alias` (a `client.connection.<alias>` entry from the config file), plus `--tunnel-tls-skip-verify` (default true) for the agent's connection to it. See [Agent Tunnels](/docs/tunnels/agent-tunnels/).

### `knot space jobs`

Manage the jobs defined on a space (see [Space Jobs](/docs/spaces/jobs/)). Definitions are stored on the space and pushed to the agent, so they survive restarts and can be edited while the space is stopped.

```shell
knot space jobs list <space>
knot space jobs add <space> <job> --command <cmd> [--schedule <cron>] [--disabled]
knot space jobs update <space> <job> [--command <cmd>] [--schedule <cron>] [--enable|--disable]
knot space jobs remove <space> <job>
knot space jobs run <space> <job>
knot space jobs enable <space>
knot space jobs disable <space>
```

`run` triggers a job immediately — it works for disabled and manual-only jobs too, but needs the space running. `enable`/`disable` start and stop the space's job runner (scheduled firing); the state is persisted on the space. `--schedule` takes a 5-field cron expression; omit it for a manual-only job.

### `knot tunnel`

Expose a local port on your machine publicly via the knot server.

```shell
knot tunnel <protocol> <port> <name>
knot tunnel http 8080 myapp
```

Protocols: `http`, `https`. Options: `--server`, `--token`, `--tls-skip-verify`. The `--tunnel-server` / `--tunnel-token` / `--tunnel-alias` spellings are accepted as synonyms, matching the target flags on `knot space tunnel`. `--port-tls-name` and `--port-tls-skip-verify` (default true) control the connection to a local service that speaks HTTPS, as on `knot port`.

### `knot ssh-config`

Manage `~/.ssh/config` entries for spaces (uses `knot forward ssh` as ProxyCommand).

```shell
knot ssh-config update [--agent-forwarding=false] [--reset] [--binary PATH]
knot ssh-config remove
```

`update` adds every space that exposes SSH and removes spaces that have gone. Spaces already in `~/.ssh/config` keep their agent forwarding setting, so you can turn `ForwardAgent` on or off for a space by editing its entry and `update` won't undo it. New spaces you own get agent forwarding by default (`--agent-forwarding`, `ssh.agent_forwarding`, `KNOT_SSH_AGENT_FORWARDING`); spaces shared with you don't get it, as forwarding lets anyone with root in the space use your SSH keys while you're connected. `--reset` applies these defaults to every space again. `--binary` sets the path to the `knot` binary used in the ProxyCommand (default `knot`).

---

## Administration

### `knot admin`

Server administration commands.

```shell
knot admin backup [selection flags] [-e|--encrypt-key KEY] [--no-content] [--prune] [--limit-user USER] [--limit-template NAME] <folder>
knot admin restore [-e|--encrypt-key KEY] [--no-content] <folder>
knot admin file ls [-r] [--json] [-e|--encrypt-key KEY] <folder> [bucket:path]
knot admin file restore [-r] [--overwrite] [-n] [--to bucket:path] [-e|--encrypt-key KEY] <folder> <bucket:path>
knot admin file fsck [--repair] [--deep] [--from-backup FOLDER] [-e|--encrypt-key KEY] [--json]
knot admin rename-zone <old> <new>
knot admin reset-totp <email-address>
knot admin set-password <email-address>
knot admin refresh-base-images [--local-only]
knot admin template export <name>
knot admin template import [--file path] [--name NAME]
```

`backup` and `restore` stream a running server's data to and from a folder through its API, so they need a token with the Backup Server permission; to restore into a new server, create its first user and use that user's token. See [Backup and Restore](/docs/best-practices/backup-restore/). The `admin` commands that talk to a server choose it with `--server` and `--token`, or `--alias` for one in the config file, like other `knot` commands. `file ls` and `file restore` list and restore files from a backup folder. `file fsck` checks [file storage](/docs/file-storage/operations/#checking-and-repairing) for damage and, with `--repair`, fixes it; `--from-backup` restores content no server holds from a backup folder. The `-e`/`--encrypt-key` flag of `restore` and `file ls|restore|fsck` is the key the backup was encrypted with (`KNOT_RESTORE_ENCRYPT_KEY`).

With no selection flags, `backup` saves everything the server holds (`-a`/`--all` is the default); giving any selection flag (`-t` templates, `-v` template variables, `-l` volumes, `-g` groups, `-r` roles, `-s` spaces, `-u` users, `-k` tokens, `-o` configuration values, `-c` scripts, `-i` skills, `--commands`, `-p` responses, `--audit-logs`, `--files`) backs up only those. `--files` covers file storage: buckets, files and their content; `--no-content` keeps the bucket and file records but not the content, and `--prune` removes content from the folder that no file refers to any more, so the folder mirrors the server. `--limit-user` and `--limit-template` limit the backup to one user (by username) or one template (by name). `-e`/`--encrypt-key` encrypts the records with a 32-byte key.

`set-password` prompts for the new password.

`refresh-base-images` forces every server in the cluster to fetch the base image manifest from its update URL immediately (`--local-only` limits the refresh to the local server). Each server must have both `server.base_image.update_enabled` and `server.base_image.update_url` configured.

`template export` writes a portable YAML representation of a template to stdout — pipe it to a file for version control. `template import` creates (or updates) a template from a YAML file, or stdin when no file is given, resolving referenced scripts by name. Both need a token with the manage templates permission; see [Managing Templates](/docs/templates/managing/#exporting-and-importing-templates).

---

## Global flags and configuration

Global flags available on most commands:

- `--config`, `-c`: configuration file to use (searched in `.`, `$HOME`, `$HOME/.knot/`, `$HOME/.config/knot/`, and `/etc/knot/`)
- `--log-level`: `trace`, `debug`, `info`, `warn`, `error`, `fatal`, `panic`
- `--log-output-url`: HTTP URL to also send log output to (e.g. `http://localhost:9428/insert/jsonline`)
- `--log-output-format`: `ndjson` (default), `loki`, `elasticsearch` or `gelf`
- `--log-output-stream`: stream name sent with each log record (default `knot`)
- `--log-output-username`, `--log-output-password`: optional HTTP basic auth for the log endpoint
- `--log-output-token`: optional bearer token for the log endpoint, taking precedence over basic auth
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
- `KNOT_LOG_OUTPUT_URL`, `KNOT_LOG_OUTPUT_FORMAT`, `KNOT_LOG_OUTPUT_STREAM`, `KNOT_LOG_OUTPUT_USERNAME`, `KNOT_LOG_OUTPUT_PASSWORD`, `KNOT_LOG_OUTPUT_TOKEN`: the `--log-output-*` settings (also `log.output.*` in the config file)

### Shell completion

```shell
knot completion <bash|zsh|fish|powershell>
```

Prints a completion script for the given shell.

### Exit codes

- `0`: success
- `1`: error
