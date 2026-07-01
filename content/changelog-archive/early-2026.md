---
title: "Early 2026"
date: 2026-05-15
layout: "changelog"
draft: false
navSection: docs
---

← [Back to Changelog](/changelog/)

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
