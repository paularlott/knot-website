---
title: "Changelog"
description: "Keep track of all changes, updates, and improvements to knot."
layout: "changelog"
draft: false
weight: 100
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

## May 2026

{{< version "v0.24.0" >}}

{{< changelog-item "added" >}}

- **Space Resource Telemetry**:
  - Live CPU, memory, load, and disk usage are now collected for spaces
  - Realtime CPU and memory bars are shown directly in the spaces table
  - New per-space usage popup with historical charts for the last 7 days
  - Usage history is stored across MySQL/MariaDB, Redis, and BadgerDB backends
  - Usage history replicates across clustered and leaf-node gossip networks
- **Space Activity Tracking** {{< pro-badge >}}:
  - User filesystem activity is tracked from the in-space agent when it runs as the user
  - Tracks file writes, creates, deletes, renames, distinct paths, and last activity time
  - Tracks user space lifecycle actions including spaces started, stopped, created, and destroyed
  - Activity history is shown on the user management page so managers can review what users are doing
  - Activity data is retained for 7 days for manager review
  - Activity collection can be disabled globally or per template when you want to avoid filesystem watcher overhead
- **Stack Definitions**:
  - Structured stack definitions for creating multi-space application stacks
  - Define reusable blueprints with component spaces, dependencies, and port forwards
  - Personal and global definitions with zone and group restrictions
  - CLI commands: `create-def`, `apply`, `delete-def`, `list-defs`, `create`, `start`, `stop`, `restart`, `delete`
  - `knot.stack` library for stack definition and lifecycle operations from scripts
  - Stack management page in the web interface
- **Space Stacks**:
  - Group spaces under a stack name for visual organization
  - Stacks are displayed as collapsible groups in the spaces list
  - `get_stack` and `set_stack` functions in the `knot.space` library
  - Start and stop operations can be performed on entire stacks, with dependency handling
- **Space Dependencies**:
  - Spaces can declare dependencies on other spaces
  - A space will not start unless all its dependent spaces are running
- **Structured Log Output**:
  - Forward logs to external log aggregation services via HTTP
  - Supports VictoriaLogs (ndjson), Grafana Loki, and Elasticsearch formats
  - Configurable stream name, batching (100 records / 2 seconds), and automatic field mapping
- **Audit Log Download**:
  - New `Download Audit Logs` permission controls who can export logs
  - Download all audit logs as CSV or JSON directly from the audit log page
- **Audit Log Filtering** {{< pro-badge >}}:
  - Filter audit logs by actor, actor type, event type, and date range
  - Full-text search across actor, event, and details fields
- **OAuth Authentication** {{< pro-badge >}}:
  - GitHub, GitLab (including self-hosted), Google, and Auth0 OAuth providers for single sign-on
  - Generic OIDC provider with auto-discovery for any OpenID Connect compatible identity provider (Okta, Keycloak, Azure AD, etc.)
  - Link and unlink external auth providers from user profiles
  - Automatic user provisioning from OAuth providers
- **Visual Port Forwarding** {{< pro-badge >}}:
  - Pro-only Spaces page interface for defining and managing port forwarding between spaces
  - Persistent port forwarding can be configured and edited even when the source space is stopped
  - Persistent port forwarding configuration survives space restarts
- **Health Checks**:
  - Templates can configure health checks to monitor space availability
  - Built-in check types: HTTP HEAD, TCP port, program execution, and custom script
  - Configurable interval, timeout, and failure threshold
  - Automatic space restart when health checks fail beyond the configured threshold
  - `knot.healthcheck` library for custom health check scripts
- **Secret Providers** {{< pro-badge >}}:
  - Fetch secrets from external secret managers directly in template variable resolution
  - HashiCorp Vault support (KV v2, token and AppRole authentication)
  - 1Password Connect support
  - Use `${{ secret "alias" "path" "field" }}` in container environment variables and volume definitions
  - Configurable provider aliases for multiple instances of the same provider type
  - TTL-based caching with configurable expiry
  {{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **Usernames**:
  - Dots are now allowed in usernames (e.g. `first.last`)
- **Agent Port Forwarding**:
  - Added persistent port forwarding support to agents
  - Port forwards can be configured to persist across agent restarts
- **Volume Management**:
  - Refactored Docker and Podman volume management to reduce dependencies
  - Improved local container volume support
- **UI/UX**:
  - Improved form styles for better accessibility and visual consistency
  - Enhanced autocompleter inputs with ARIA roles and properties
  - Improved modal close buttons and popup behaviour
- **Database Migrations**:
  - Improved migration code reliability
  {{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- Large docker images could cause timeouts during space creation
  {{< /changelog-item >}}

## March 2026

{{< version "v0.23.0" >}}

This release introduces a powerful scripting system, skills management for AI assistants, enhanced MCP capabilities, OpenAI-compatible chat API, and improved agent authentication.

- **Database Migration**: Database schema changes requires `migrate.sql` to be applied to all MySQL databases

{{< changelog-item "added" >}}

- **Scripting System**:
  - Added comprehensive scripting support using Python-like syntax
  - Three execution environments: local (CLI), MCP (AI tools), and remote (space execution)
  - Scripts can be exposed as MCP tools for AI assistants with parameter schemas
  - Support for library scripts for reusable code across scripts
  - Streaming script execution with binary frame support
- **Script API Client Library**:
  - Python client libraries for scripts to interact with knot: knot.api, knot.space, knot.template, knot.user, knot.group, knot.role, knot.var, knot.volume
  - Full CRUD operations for spaces, templates, users, groups, roles, variables, and volumes
- **Skills Management**:
  - Added skills system for AI knowledge base content following the Agent Skills Specification
  - Skills are markdown documents with YAML/TOML frontmatter
  - Global and user-level skills with user shadowing
  - Zone and group restrictions for access control
  - CLI commands for skill management
- **AI Library**:
  - Added knot.ai library providing pre-configured AI client access from scripts
  - Support for multiple LLM providers (OpenAI, Claude, Gemini, Ollama, etc.)
  - Integration with scriptling.ai.agent for agentic AI workflows
- **Startup/Shutdown Scripts**:
  - Templates can define startup and shutdown scripts
  - User startup scripts configured per-space
  - Automatic execution when spaces start or stop
- **Space to Space Copy**:
  - Added ability to copy files between spaces
- **Remote MCP Servers**:
  - Support for connecting to external MCP servers
  - Bearer token authentication for remote servers
- **OpenAI-Compatible Chat API**:
  - New `/v1/chat/completions` endpoint with streaming support
  - Async response processing with worker pool for scalability
  - Automatic recovery of incomplete responses on server restart
  - New Responses API for long-running async operations
- **MCP Tools**:
  - Built-in MCP tools (create_space, start_space, stop_space, etc.) are now script-based and customizable
  - Tools support discoverable flag for visibility control
- **Script CLI Commands**:
  - `knot scripts list` - List available scripts
  - `knot scripts show` - Display script details
  - `knot scripts delete` - Remove scripts
- **Space File Operations CLI**:
  - `knot space read-file` - Read files from running spaces
  - `knot space write-file` - Write files to running spaces
    {{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **Agent Authentication**:
  - Improved agent token system using deterministic HMAC-SHA256 generation
  - Tokens are zone-specific and work across all servers in a zone
  - No database lookups required for validation
- **Chat System**:
  - Rewritten to use OpenAI-compatible endpoint architecture
  - Improved integration with MCP server functions for tool calling
- **MCP Enhancements**:
  - On-demand tool discovery for better MCP integration
  - Tool visibility configuration for MCP remote servers
- **UI Improvements**:
  - Enhanced form handling with better popup behavior
  - Script and skill management UI
  - Improved leaf node interface
  - Better mobile responsiveness
- **Leaf Node**:
  - Various reliability and UI improvements for leaf node operation
    {{< /changelog-item >}}

## December 2025

{{< version "v0.22.0" >}}

This release introduces agent-to-agent port forwarding capabilities, enhanced MCP support, significant UI/UX improvements, and a more robust container runtime detection system.

- **Database Migration**: Database schema changes requires `migrate.sql` to be applied to all MySQL databases

{{< changelog-item "added" >}}

- **Agent-to-Agent Port Forwarding**:
  - Added complete port management CLI with `forward`, `list`, and `stop` subcommands
  - Enables secure port forwarding between agents in spaces within the same zone owned by the same user
  - Implemented proper authentication and validation for port forwarding requests
  - Added tracking and management of active port forwards with automatic cleanup
- **Node Selection Service**:
  - Added node selection for automatic or manual placement of containers within a zone
    {{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **MCP (Model Context Protocol) Support**:
  - Added support for on-demand tool discovery alongside native MCP tools
  - Enhanced tool discovery mechanism for better MCP integration
  - Refactored MCP handling to support multiple tool discovery approaches
- **Container Runtime Detection**:
  - Improved detection with enhanced logging and error handling
  - Refactored architecture for better maintainability
  - Enhanced Apple Silicon container support
- **UI/UX Improvements**:
  - Improved mobile responsiveness and UI components
  - Fixed popup closing behavior - forms no longer close accidentally when clicking outside
  - Enhanced template node management UI
- **API & Backend Enhancements**:
  - Enhanced cluster information endpoints with better data structure
  - Improved space API with additional fields and validation
  - Enhanced Server-Sent Events reconnection logic for better reliability
  - Added new query utilities for cluster operations
- **Transport Layer**:
  - Improved transport service for better inter-service communication
- **Security Enhancements**:
  - Enhanced authentication for port forwarding operations
  - Improved token validation for API clients
  - Better error handling for sensitive operations
- **Dependencies**:
  - Updated Go modules with latest security patches
  - Refreshed frontend dependencies for better compatibility
    {{< /changelog-item >}}

{{< changelog-item "fixed" >}}

- Improved error handling in container operations
- Fixed form popup auto-close issues
- Fixed popup closing behavior
  {{< /changelog-item >}}

## October 2025

{{< version "v0.20.x" >}}

{{< changelog-item "added" >}}

- **Apple Container Support**:
  Added support for Apple Container templates using the macOS container CLI.
  {{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **Safari**:
  Improved the web interface compatibility with Safari.
- **HTTP/2 Errors**:
  HTTP/2 errors are no longer fatal, they are logged and knot continues operation.
- **UI**:
  Minor UI improvements.
- **Cluster**:
  Improvements to data synchronization.
  {{< /changelog-item >}}

## September 2025

{{< version "v0.19.1" >}}

{{< changelog-item "changed" >}}

- **Message History UX**:
  Improvements to the usability of the message history.
  {{< /changelog-item >}}

{{< version "v0.19.0" >}}

This release brings Artificial Intelligence to **knot**, with both a built in assistant and connectivity to use with editors and applications that support MCP.

{{< changelog-item "added" >}}

- **Model Content Protocol (MCP)**:
  Added ability to use knot servers as MCP servers exporting tools for creating and managing spaces and templates.
- **AI Assistant**:
  Added web based AI assistant allowing control of spaces and templates including assistance in writing new templates (requires OpenAI compatible LLM).
- **Run In Space**:
  Run commands within a space via the command line client.
- **Copy Files**:
  Copy files between the local machine and the space.
- **Soft Keyboard**:
  When accessing **knot** from a tablet the terminal window now has a soft keyboard which provides cursor keys, control key and other keys that are not generally available on the keyboard.
  {{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **Tunnel Server**:
  Allow running the tunnel server on the same port as the main web interface.
- **Nomad Volumes**:
  Added support for Nomads builtin `mkdir` storage plugin.
  {{< /changelog-item >}}

## July 2025

{{< version "v0.18.2" >}}

This release introduces significant updates, with the most notable being a complete rewrite of the cluster mode. The new leaderless architecture ensures that all servers in the cluster are equal, eliminating the need for a designated leader. This change improves both availability and performance, allowing the system to continue functioning seamlessly even if connections between nodes are interrupted.

{{< changelog-item "added" >}}

- **Enhanced Tunneling**:
  Tunnel functionality has been improved, enabling the creation of tunnels from a port within a space to a port on the local machine.
- **Leaf Node Support**:
  Restructured leaf nodes to work seamlessly with the new cluster mode.
- **Cluster Management**:
  - Added support for multiple servers within a location/zone.
  - Enhanced cluster startup code and introduced a cluster info API endpoint.
- **DNS Server**:
  Implemented a basic DNS server with forwarding support.
- **Backup and Restore**:
  - Added encryption to backup/restore functionality.
  - Enabled support for audit logs and configuration values in backup/restore.
- **Template Enhancements**:
  - Templates can now define variables, which are made available when creating a space.
  - Added the ability to mark templates as inactive.
  - Introduced a duplicate template function for easier template management.
- **Space Management**:
  - Added a "space note" feature for descriptions and notes.
  - Introduced a restart command for spaces in both the UI and CLI.
  - Enabled forwarding into spaces without requiring port specifications.
- **UI/UX Enhancements**:
  - Added usage graphs for better resource monitoring.
  - Improved login screen, added white-label support, and refined the user list UI.
  - Added icons to spaces and templates, including Gravatar support in share dialogs.
- **Miscellaneous**:
  - Added IP rate limiting for authentication to enhance security.
    {{< /changelog-item >}}

{{< changelog-item "changed" >}}

- **UI/UX Enhancements**:
  - Enhanced feedback for over-quota errors and improved messaging across the UI.
- **Performance and Reliability**:
  - Refined tunnel handling and connection management with improved logging and synchronization.
  - Improved data flow between servers in the same zone.
  - Extended token life to two weeks for better user experience.
- **CLI Updates**:
  - Refactored CLI commands for better organization and usability.
  - Added support for managing multiple servers from the CLI.
  - Improved error handling and feedback in the CLI.
- **Code Refactoring**:
  - Removed deprecated commands and unused code for a cleaner codebase.
  - Replaced the `viper` dependency with an internal CLI package for improved performance.
- **Audit Log**:
  - Enhanced audit log handling and forwarding to clusters for better traceability.
- **Templates**:
  - Added platform change warning modals to template and volume forms for better user guidance.
    {{< /changelog-item >}}

{{< changelog-item "fixed" >}}

- Fixed issues with standalone spaces and manual space deletion.
- Resolved incorrect termination of the main server loop.
- Addressed storage quota bugs.
- Corrected permission checks for space transfers and admin roles.
- Fixed the SSH info window not closing properly.
  {{< /changelog-item >}}

---
