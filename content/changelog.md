---
title: "Changelog"
description: "Keep track of all changes, updates, and improvements to knot."
layout: "changelog"
draft: false
weight: 100
navSection: docs
---

## July 2026

{{< version "v0.30.1" >}}

{{< changelog-item "added" >}}
- **Cross-space stack variables**: spaces in a stack can now reference variables belonging to sibling spaces via the `.stack` group, e.g. `${{ .stack.db.custom.password }}` or `${{ .stack.db.space.id }}`. Siblings are keyed by their stack-definition key (space name with the prefix stripped), and each exposes the full variable set. Keys containing a hyphen are also reachable via a dotted-safe `_` alias (`${{ .stack.space_1.custom.x }}`) or the `index` builtin. See [System Variables](/docs/variables/system-variables/).
- **Template variable autocomplete**: the template editors (Nomad job, container spec, and volume definitions) now suggest system variables like `${{ .space.id }}`, `${{ .user.username }}`, and `${{ .server.url }}` as you type, each with inline documentation. A `${{ .custom.` starter is also offered so you can insert and complete a custom variable.
- **Environment variables for stdio MCP servers**: stdio-based MCP servers (local executables launched as subprocesses) can now set one or more environment variables that are applied to the child process. Variables are merged on top of the inherited environment, so `PATH`, `HOME`, and other defaults remain available. Configure them from the MCP Servers UI (one `KEY=value` per line) or via `env` in `knot.toml`. See [Remote MCP Servers](/docs/ai/mcp-remote/).
{{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **Template/volume validation**: validation errors now point at the exact source line (the editor annotates the offending line instead of stacking errors at the top), messages are clearer and consistently include the offending value, and additional checks are enforced — `cap_add`/`cap_drop` must be `CAP_*` capabilities, `command` must be a list, and `privileged` must be a boolean.

- **Improvements to UI**
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- **Stack name clashes on create**: creating a new stack no longer silently reuses an existing stack name, which previously mixed spaces from different stack instances under one name. The CLI (`knot stack create`) and the web create-stack flow now refuse to create a stack whose name is already in use. Editing a normal space can still be assigned to an existing stack.

- **Web VNC for shared spaces**: opening web VNC on a space shared with you no longer fails. VNC access now resolves against the authenticated viewer and grants access to the space owner and any user the space is shared with, matching the SSH and terminal proxies.
{{< /changelog-item >}}

{{< changelog-item "security" >}}
- **Web VNC now requires authentication**: the web VNC subdomain previously had no authentication and was reachable by anyone who knew the URL. It now requires an active session with the *Use VNC* permission. The web session cookie is also shared across the wildcard domain so it reaches the VNC subdomain; existing sessions pick this up on the next login.
{{< /changelog-item >}}

---

{{< version "v0.30.0" >}}

{{< changelog-item "added" >}}
- **In-space file search and edit (`grep` / `find` / `sed` / `edit_file`)**: Search file contents, find files by name/type/mtime/size, perform literal or regex in-place edits, and make targeted search-and-replace edits with uniqueness verification. Operations run in the space's agent via the scriptling `extlibs` worker pool (no interpreter, no file contents leave the space). Each operation has its own typed agent message (`CmdGrep`, `CmdFind`, `CmdSed`, `CmdEditFile`) and API endpoint. Exposed four ways:
  - **Scripting library**: `knot.space.grep`, `find`, `sed_replace`, `sed_replace_pattern`, `sed_extract`, `edit_file` — see [knot.space reference](../reference/libraries/space/).
  - **CLI**: `knot space grep`, `find`, `sed` (with `--regex` / `--extract` / `--json`), `edit` (with `--search` / `--replace`) — see [CLI reference](../reference/cli/knot/).
  - **MCP tools**: `grep`, `find`, `sed_replace`, `sed_replace_pattern`, `sed_extract`, `edit_file` — discoverable by default; the replace/edit ops require approval.
- **`knot.space.eval` + `knot space eval`**: Execute inline Scriptling code in a running space without first storing a named script. The library function (`knot.space.eval`) and the CLI command both hit the existing inline-content execution path; the CLI streams output live and reads code from an argument or stdin (`-`). See [knot.space reference](../reference/libraries/space/) and [CLI reference](../reference/cli/knot/).
- **Additional Scripting Libraries**:
  - `scriptling.grep`
  - `scriptling.find`
  - `tempfile`
  - `shutil`
  - `shlex`
  - `zipfile`
  - `tarfile`
  - `scriptling.csv`
  - `scriptling.xml`
{{< /changelog-item >}}

---

{{< version "v0.29.0" >}}

{{< changelog-item "added" >}}

- **Agent-managed tunnels**: Tunnels started inside a space with `--daemon` are now handed to the knot agent, which keeps them running for the life of the agent. Manage them with `knot tunnel stop <name>` and `knot tunnel list`. See [Agent Tunnels](/docs/tunnels/agent-tunnels/).
- **Remote tunnel management**: Start and manage a space's tunnels from your desktop CLI with `knot space tunnel http|https|stop|list`, without needing to be inside the space.
- **Scripting tunnel library**: Manage tunnels from scripts via `knot.space.tunnel_start`, `tunnel_list`, and `tunnel_stop` — available in all Scriptling environments through the server API.
- **AI Assistant chat overhaul**: The built-in floating chat window is now draggable, resizable, and supports conversation history, streaming responses, tool call approval flow, slash command autocomplete, per-user skills, and MCP tools.
- **Slash commands**: Create custom per-user or global slash commands from the web UI with markdown bodies (`$ARGUMENTS` substitution), argument hints, and auto-allowed tools. Changes appear instantly in open chat windows.
- **MCP tool refresh notifications**: Knot's MCP server now notifies connected clients when its tool set changes (e.g. when scripts are created or updated), so clients always show the latest available tools. Remote servers can also push their own change notifications with `notifications = true`.
- **stdio remote MCP servers**: Configure a remote MCP server as a local executable (`command` + `args`) instead of an HTTP endpoint, for greater flexibility in how you connect external tools.
- **Scriptling MCP client enhancements**: The embedded Scriptling runtime now supports resource and prompt access — `list_resources()`, `read_resource(uri)`, `list_prompts()`, and more — with autocomplete support in the script editor.

{{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **Compact navigation**: frequently used items (Spaces, Tunnels, API Tokens, Volumes) are always visible; everything else collapses under a single expandable "More" section.
- **Movable form popups**: all form modals are now draggable and resizable so you can position them alongside the AI chat or other content.
- **CLI reorganisation (port & tunnel commands)**: port and tunnel commands have been reorganised for clarity — see [Agent Tunnels](/docs/tunnels/agent-tunnels/) for details on the new command layout.

{{< /changelog-item >}}

{{< changelog-item "fixed" >}}

- **Volume deletion on space delete**: volumes are now properly cleaned up when a space is deleted, even if Nomad takes time to terminate the underlying job (up to 5 minutes).
- **Space delete with missing job**: deleting a space whose underlying job was already removed no longer fails — the operation completes successfully.
- **Volume deletion resilience**: a single volume deletion failure no longer aborts cleanup of remaining volumes, and previously silent errors are now logged for debugging.
- **Space deletion on volume failure**: if volume cleanup fails, the space is left in place so you can retry the delete rather than being left with orphaned volumes.
- **Crash fixes**: fixed crashes when internal transport objects were nil (previously could occur during testing or early startup), and improved Apple container volume cleanup reliability.

{{< /changelog-item >}}

---

{{< version "v0.28.2" >}}

{{< changelog-item "changed" >}}

- **UI improvements**

{{< /changelog-item >}}

---

{{< version "v0.28.1" >}}

{{< changelog-item "added" >}}

- **Events**: `knot.event.emit()` now works from MCP tool execution and external standalone scripts (delivered via `knot.apiclient`), not just from inside a space. Events raised outside a space are user-scoped with a nil space id.

{{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **UI improvements**: refined stack template permissions and filters.

{{< /changelog-item >}}

---

## June 2026

{{< version "v0.28.0" >}}

{{< changelog-item "added" >}}

- **Events system**
  - Route lifecycle and custom events to webhooks, scripts, or JSON-RPC methods, scoped per-user or global.
  - System events fire automatically on space lifecycle transitions: `space.created`, `space.started`, `space.stopped`, `space.deleted`, `space.healthy`, `space.unhealthy`. System event payloads now include `space_name` and `space_id` (plus `space_urls` for created/started).
  - Raise custom events from inside a space via the `knot event` CLI, the agent's `POST /event`, or the `knot.event.emit()` scriptling function.
  - Sinks match on glob patterns (`space.*`, `custom.myapp.*`) and deliver zone-local, in-order per sink, with at-least-once semantics. Webhook sinks render a Go template body and sign with HMAC-SHA256; script sinks run an existing scriptling server-side; JSON-RPC sinks deliver events to running script methods via `events`/`event_sinks` method annotations.
  - Simplified default webhook template: just `event_id`, `event_type`, `event_ts`, `data`.
  - Two new permissions: `Manage Own Event Sinks` and `Manage Global Event Sinks`.
  - New endpoints: `GET/POST/PUT/DELETE /api/event-sinks`, `POST /api/spaces/{id}/emit-event`.

- **Space pools**
  - Fixed-size, self-healing pools keep a target number of identical spaces running from a template; the cluster leader reconciles membership every 15 seconds, drains method traffic before stopping members, and applies a grace period before deleting excess spaces.
  - Pool members are reachable via the pool name (`username--poolname--port.domain`), with the proxy falling back to pool lookup and round-robining across healthy, non-drained members. TCP WebSocket proxy routing (`/proxy/spaces/{name}/port/{port}`) accepts pool names too.
  - Manage via `knot.pool` scriptling functions (list, utilization, `desired_count`, start/stop), the `/api/pools` endpoints, or MCP tools `create_pool`, `delete_pool`, `start_pool`, `stop_pool`, `set_pool_size`.

- **Space methods**
  - Running spaces can register JSON-RPC methods backed by a long-running stdio method server, and optionally expose them as discoverable MCP tools (`mcp_tool = true`; dotted names are rewritten to underscores).
  - Methods can be private or shared, filtered by group, discovered with `GET /api/methods`, and called via `POST /api/methods/call`.
  - The server supports concurrent (default) or serial request handling, JSON-RPC notifications, and batch calls; scriptlings can serve as the server via `scriptling --json-rpc`.
  - Register from inside a space with `knot methods register <file>.toml` (or `.py`), or from startup scripts via the agent-only `knot.methods` library and `knot.methods.schema` JSON Schema builder.
  - Register methods automatically at agent startup with `knot agent start --methods-file <file>.toml` (or `.py`); also configurable via the `agent.methods_file` config key or `KNOT_METHODS_FILE` environment variable.

- **`knot run-script` server modes**
  - The agent embeds the Scriptling runtime, so `knot run-script` now mirrors the Scriptling CLI's run modes — no separate `scriptling` binary needed in a space. Run a script as a stdio JSON-RPC method server (`--json-rpc`), an HTTP server (`--listen :PORT`), or an MCP server (`--mcp-tools DIR`), with the sandbox flags (`--allowed-path`, `--disable-lib`, `--bearer-token`, `--web-root`, `--kv-storage`, `--tls-*`). Container runtime libraries are excluded.
  - Plain `knot run-script <file>` now exposes the full Scriptling library set (minus container) plus Knot's own libraries.
  - `knot --version` reports the bundled Scriptling runtime version.

- **User access overview** {{< pro-badge >}}
  - A new **Access** button on the users list opens a popup showing everything a user can reach, derived from their roles and groups: effective permissions (grouped by category, with the ones they lack greyed out), effective quota, owned and shared spaces, and the templates, variables, volumes, scripts, skills, and stack definitions they can access.
  - Backed by `GET /api/users/{user_id}/access`.

{{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **SSH key updates**: in-space SSH key updates are now driven by the agent's reported SSH port (`SSHPort > 0`) rather than the template's SSH capability, so keys are pushed only once the agent is actually ready to accept them — including during reconnect churn before the first state report fully lands.
- **Name field sanitization**: space, pool, and volume name fields now strip invalid characters as you type or paste (e.g. pasting `test #1234` yields `test1234`), matching the URL-safe character set the backend already enforces.
- **Administration sidebar group**: Templates, Variables, Users, Groups, Roles, Audit Logs, and Cluster Info are grouped under a collapsible **Administration** section in the sidebar (hidden entirely if you have none of the relevant permissions). On leaf nodes, Templates and Variables remain top-level entries.
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}

- **Agent monitoring and health reporting**: fixes to the agent's per-server connection data races that could leave a server stuck on a closed session after a reconnect (presenting as "mux ping succeeds but agent state goes stale") or racing the stale-session checker.
{{< /changelog-item >}}

---

{{< version "v0.27.0" >}}

**Internal Release**

---

{{< version "v0.26.2" >}}

{{< changelog-item "added" >}}

- **Delete a stack from the web UI**: a new **Delete** button on each stack header deletes every space in the stack in one action. The button only appears when all of the stack's spaces are stopped (and local to the current zone), matching the existing rules for deleting a single space. A confirmation modal lists the space count before the stack is removed, and the underlying `DELETE /api/stacks/{name}` endpoint validates the entire stack before mutating anything, so a stack with a running space is rejected up front rather than partially deleted
{{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **Stack action buttons**: the Start, Stop, Restart, and Delete buttons on each stack header have been restyled to match the outlined row-action look used elsewhere in the UI (white/slate background with a coloured icon and label). Delete and Stop both use a red icon to signal their destructive intent, Start uses green, and Restart uses blue
- **"Stacks" renamed to "Stack Templates"**: the web UI menu item and the page that lists stack blueprints is now labelled **Stack Templates** to distinguish the blueprint from a running stack. The CLI, API, and scripting library still use the historical name **stack definition** for the same concept
- **Primary buttons**: the solid blue **+ New …** buttons across the listing pages have been restyled as outlined buttons (white background, blue border and label) to match the visual weight of the other action buttons
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}

- **My Usage page**: the four usage doughnut charts (spaces, tunnels, compute, storage) are rendering again — a regression introduced in v0.26.1 left the chart canvases without their Alpine `x-ref` attributes, so Chart.js could not acquire them
{{< /changelog-item >}}

---

{{< version "v0.26.1" >}}

{{< changelog-item "added" >}}

- New `${{ .space.stack }}` system variable exposes the space's stack name in job and volume templates, allowing templates to react to stack membership
- New `${{ .space.stack_prefix }}` system variable exposes the prefix used when creating a stack, so job and volume templates can reference sibling containers in the same stack (e.g. `${{ .space.stack_prefix }}-db`)
{{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **SSH Authorized Keys**: the "SSH Public Key" field on the user profile form has been renamed to "SSH Authorized Keys" to better reflect that these keys are written to the space's `authorized_keys` file
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}

- **SSH private key isolation**: the private key file (`id_ed25519` / `id_rsa` / `id_ecdsa`) is now only modified when the private key value itself changes, not when authorized keys or GitHub username are updated
- **SSH private key on transfer**: the private key always reflects the current space owner's profile — if the owner has no private key set, any existing key file is removed on next space start, preventing the previous owner's key from persisting after a space transfer
- **SSH key type cleanup**: switching between key formats (e.g. RSA to Ed25519) now removes the old key file so only the current format remains
- **Modal behaviour**: clicking outside a modal no longer closes it — all modals now require an explicit action (button or Escape key) to dismiss
{{< /changelog-item >}}

---

{{< version "v0.26.0" >}}

{{< changelog-item "added" >}}
- New API endpoints to support the Visual Studio Code extension
{{< /changelog-item >}}

---

{{< version "v0.25.2" >}}

{{< changelog-item "added" >}}

- `knot spaces create` now accepts repeatable `--custom-field name=value` flags so CLI-created spaces can receive template custom field values at creation time
- `knot stack list` now shows per-space health alongside stack status, making unhealthy running spaces visible from the CLI
{{< /changelog-item >}}

{{< changelog-item "changed" >}}

- CLI documentation now covers stack lifecycle commands (`create`, `list`, `start`, `stop`, `restart`, `delete`) and stack definition management commands
{{< /changelog-item >}}

---

{{< version "v0.25.1" >}}

{{< changelog-item "added" >}}

- New `list_scripts` MCP tool — discover runnable scripts before calling `run_script` (previously `run_script` had no discovery companion)
- `list_templates` MCP tool now returns each template's custom field definitions, removing the need for a separate `get_template` call when creating spaces with custom fields
- `list_spaces` MCP tool now returns each space's custom field values (previously the field was always empty)
- New **MCP Tools** reference page in the documentation, grouping every tool by what it operates on and showing native vs on-demand visibility
{{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **MCP tool surface trimmed** based on a clearer principle: MCP exposes runtime operations on instances plus read-only discovery; authoring of curated artifacts and access-control management happen in the UI/CLI:
  - Removed template authoring tools (`create_template`, `update_template`, `delete_template`, `get_template`) — `list_templates` now carries custom field definitions
  - Removed `get_stack_definition` (covered by `list_stack_definitions`)
  - Removed space access-control tools (`share_space`, `stop_sharing_space`, `transfer_space`)
- `list_spaces` now defaults to the current zone only; pass `show_all=true` to include spaces from other zones (matches the behaviour of scripts, skills, and templates)
- `list_templates` and `list_scripts` default to active items only
- `restart_space` is now a native tool, matching `start_space` and `stop_space`
- The web assistant no longer asks "are you sure?" in chat before destructive operations — knot's browser approval prompt already handles confirmation, and the previous behaviour caused redundant double-confirmations
- Stack definition builder now blocks saving a component without a template selected (matches the server-side validation that was already enforced)
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}

- Calling MCP tools with template or space names containing spaces (e.g. "ubuntu testing") no longer panics with `malformed HTTP version`; the `knot.*` script libraries now URL-encode path segments via `urllib.parse.quote`, and the in-process API client validates request paths before dispatch
{{< /changelog-item >}}

{{< version "v0.25.0" >}}

{{< changelog-item "added" >}}

- **Local Container Node Migration**:
  - Templates can allow local-container spaces to be manually reassigned to another live node while stopped
  - Node selection now prefers the least-loaded eligible node when placing or migrating local-container spaces
- **Automatic Failed-Node Recovery** {{< pro-badge >}}:
  - Zone leaders can detect failed gossip nodes and automatically restart eligible spaces on another live node
  - Automatic migration requires both node migration and Auto-restart on failure to be enabled on the template
  - Leader election reconciliation ensures failed-node migrations continue if the previous zone leader fails
- **Multiple SSH Public Keys**:
  - User profiles now support multiple SSH public keys, with one key per line
  - All profile keys are copied through to SSH-enabled spaces and running spaces receive profile key updates
- **Profile SSH Private Key**:
  - Users can store an SSH private key in their profile for SSH-enabled spaces
  - SSH private keys are only visible and editable by the owning user
  - The key is written to `~/.ssh/id_ed25519`, `~/.ssh/id_rsa`, or `~/.ssh/id_ecdsa` depending on key format
  - Running spaces receive updates when the key changes and old keys of a different type are cleaned up
- **Managed Template Paths**:
  - Local-container and Nomad templates can define `paths` alongside `volumes`
  - Paths are created before spaces start and removed when spaces are deleted
  - `~` resolves to the server user's home directory, absolute paths start with `/`, and relative paths resolve from the agent working directory
- **Health Checks**:
  - Added Agent health check mode for monitoring whether the space agent is still transmitting state
  - Agent health checks can restart local-container and Nomad spaces when Auto-restart on failure is enabled
- **Template Ports**:
  - Templates can define named ports (TCP, HTTP, HTTPS) that spaces expose
  - Defined ports are injected into spaces as `KNOT_HTTP_PORT`, `KNOT_HTTPS_PORT`, and `KNOT_TCP_PORT` environment variables
  - Alt names can route to specific ports defined in the template
- **Scripting Libraries**:
  - Added DNS resolution library (`scriptling.resolve`) for IP lookup and SRV record resolution
  - Added file provisioning library (`scriptling.provision.file`) for file management in scripts
- **Script CLI Commands**:
  - New `knot scripts read` and `knot scripts write` commands for reading and writing script files
  - New `knot run-script` agent command for executing scripts in running spaces
  {{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **Template Migration Controls**:
  - Clarified local-container migration wording in the template form
  - In Pro, Auto-restart on failure is shown when node migration is enabled, making the automatic migration policy visible from the template form
- **Container Volume Safety**:
  - Docker, Podman, and Apple container jobs now reject undeclared named volume binds instead of allowing runtimes to silently create untracked volumes
  - Host-path binds continue to work, and named volumes must be declared in the template volume definition so they can be tracked and cleaned up correctly
  {{< /changelog-item >}}

{{< changelog-item "fixed" >}}

- Stopping a space assigned to an offline remote node now marks the space as stopped locally instead of leaving it shown as running
- Migrated local-container spaces clean up their old container and tracked volumes when the failed node returns
- Apple container cleanup now treats already-removed containers and volumes as successful cleanup instead of reporting false failures
- Prevented undeclared named volumes such as `volume-paul` from being auto-created outside Knot volume tracking during space start
  {{< /changelog-item >}}

---

