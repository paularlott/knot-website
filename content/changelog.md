---
title: "Changelog"
description: "Keep track of all changes, updates, and improvements to knot."
layout: "changelog"
draft: false
weight: 100
---

## April 2026

{{< version "v0.24.0" >}}

This release introduces Knot Pro with OAuth authentication and visual port forwarding between spaces, along with persistent port forwarding for agents and significant UI improvements.

{{< changelog-item "added" >}}

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
  - Visual interface for defining and managing port forwarding between spaces
  - Persistent port forwarding configuration that survives space restarts
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
