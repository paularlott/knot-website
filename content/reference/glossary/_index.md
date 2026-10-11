---
title: Glossary
description: Glossary of common terms and concepts used throughout knot documentation.
type: Overview
weight: 60
---

Common terms and concepts used in Knot.

---

## A

**Agent**
The knot agent runs inside containers and communicates with the knot server. It handles SSH connections, terminal access, and space management commands.

**Agent Endpoint**
The network address where agents connect to the server. Configured as `server.agent_endpoint`.

**API Token**
Authentication token for accessing the knot API. Tokens expire after 2 weeks of inactivity.

**Audit Log**
Record of actions performed in knot, including user authentication, space creation, and configuration changes.

---

## B

**Backup**
Copy of a running server's data, taken through the API with `knot admin backup` into a folder: users and their tokens, templates, spaces, configuration, audit logs and, with file storage, every bucket and file. Running it again into the same folder refreshes it, copying only new file content. The records can be encrypted; file content is stored as it is. See [Backup and Restore](/docs/best-practices/backup-restore/).

**Backup Server**
Permission to back up the server and restore into it. It is not part of the Admin role, so administrators need it granted separately.

**Backup User**
Role created by a new server holding only the Backup Server permission, and given, with the Admin role, to its first user. An ordinary role that can be edited, assigned or deleted.

**BadgerDB**
Embedded database option for single-server deployments. No external dependencies required.

**Bucket**
Named container of files in file storage, owned by one user and private until shared. Its full name is `<username>--<name>`, and a file in it is written `bucket:path`.

---

## C

**Cluster Mode**
Deployment configuration with multiple knot servers for high availability and geographic distribution. Uses leaderless architecture.

**Cluster Key**
Shared secret used for authentication between cluster nodes.

**Code Server**
VS Code running in the browser, accessible from spaces when enabled in templates.

**Compute Units**
Resource measurement for running spaces. Used for quota management and resource allocation.

**Container**
Isolated runtime environment for a space. Can be Docker, Podman, Nomad, or Apple Container.

**CSI (Container Storage Interface)**
Standard for storage plugins in Nomad. Used for persistent volumes in Nomad-based templates.

**Custom Variables**
Template-defined variables with values set when creating spaces. Accessed as `${{ .custom.name }}`.

---

## D

**DNS Server**
Built-in DNS server for resolving knot domains and wildcard addresses.

---

## E

**Encryption Key**
Secret key for encrypting sensitive data. Generated with `knot genkey`.

**Event**
Notification that something happened: a system event when a space changes state (`space.started`, `space.unhealthy` and so on) or a custom event (`custom.*`) raised from a space or through the API. Delivered to event sinks. See [Events](/reference/events/).

**Event Sink**
User-owned or global listener that receives the events matching its patterns, by calling a webhook, running a script or delivering to a JSON-RPC method.

---

## F

**File Storage**
Optional, experimental store of files in buckets, replicated to every server in the cluster and reached from the Files page, `knot file`, the `knot.files` library, the API or, on Knot Pro, the S3 endpoint. See [File Storage](/docs/file-storage/).

---

## G

**Gravatar**
Service for profile images based on email addresses. Can be enabled in UI configuration.

**Group**
Collection of users with shared template access and resource quotas.

---

## H

**HCL (HashiCorp Configuration Language)**
Configuration language used for Nomad job specifications.

---

## J

**Job**
A scheduled or manual task defined on a space and run by its agent. Managed from the web UI, `knot space jobs`, or the `knot.jobs` scriptling library.

---

## L

**Leaderless Architecture**
Cluster design where all servers are equal. No single point of failure.

**Leaf Mode**
Lightweight deployment that connects to a central cluster. Runs spaces locally while managing templates centrally.

**Lease**
Exclusive checkout of one member of a lease-enabled pool: the caller acquires a warm, healthy space for its own use and releases it back to the pool when done.

---

## M

**Manual Template**
Template for environments where the knot agent is started manually. Used for physical machines or custom setups.

**MCP (Model Context Protocol)**
Open protocol for exposing tools to AI assistants. Knot scripts can be exposed as MCP tools, and the server can proxy MCP tool calls to spaces.

**Method**
JSON-RPC method published by a running space. Knot handles discovery, access control and routing calls to the space, and can expose methods as MCP tools.

**MySQL / MariaDB**
External database option, including Galera clusters, for multi-server deployments.

---

## N

**Nomad**
Container orchestration platform. Knot can deploy spaces to Nomad clusters.

**Nomad Template**
Template that deploys spaces to a Nomad cluster using HCL job specifications.

---

## P

**Peer Mesh** {{< pro-badge >}}
Direct agent-to-agent connections for port forwarding between spaces on the same host or network, falling back to relaying through the server.

**Permission**
Specific action a user can perform. Granted through roles.

**Podman**
Container runtime alternative to Docker. Supported for local container templates.

**Pool**
A pre-warmed set of spaces kept ready so that new spaces can be assigned instantly.

**Port Forwarding**
Tunneling connections from local machine to ports in a space.

**PostgreSQL**
External database option for multi-server deployments. Can also hold sessions itself, without Redis / Valkey.

**Protected Variable**
User-defined variable stored encrypted in the database.

---

## Q

**Quota**
Limit on resources a user or group can consume. Includes space count, compute units, storage units, file storage size (MB) and the maximum number of buckets.

---

## R

**Redis / Valkey**
Database option, in single-server, Sentinel or cluster mode. Used alongside another database, it holds only session data.

**Replication**
How file storage reaches every server: bucket and file records are gossiped, the newest change winning by hybrid logical clock (HLC) timestamp, and file content, stored by its SHA-256, is pulled directly from peers that hold it.

**Restore**
Loading a backup folder into a running server with `knot admin restore`, which is how a lost server is rebuilt: start a new server, create its first user and restore with that user's token. Single files or folders are restored with `knot admin file restore`. Backups made before v0.37.0 can't be restored.

**Role**
Collection of permissions defining what actions users can perform.

---

## S

**S3 Endpoint** {{< pro-badge >}}
The S3 API served at `<server>/s3` on servers with file storage, so S3 clients such as rclone and the AWS CLI can use buckets, signing in with a username and an API token.

**Schedule**
Time-based rules for when spaces can run. Spaces outside schedule are automatically stopped.

**Scriptling**
The Python-compatible scripting language used for knot scripts, JSON-RPC methods, event sinks, and MCP tools. Runs on the server and inside spaces.

**Skill**
A script packaged with metadata describing what it does, exposed to AI assistants as an MCP tool.

**Space**
Running instance of a template. Isolated environment with compute, storage, and network resources.

**Stack**
A reusable definition that creates a set of related spaces (components) with dependencies, port forwards, and shared custom fields.

**Storage Units**
Resource measurement for persistent storage. Used for quota management.

**System Variables**
Variables automatically provided by knot. Include user info, space details, and server configuration. Accessed as `${{ .user.username }}`.

---

## T

**Template**
Blueprint for creating spaces. Defines container specification, volumes, resources, and features.

**TOTP (Time-based One-Time Password)**
Two-factor authentication method using apps like Google Authenticator.

**Tunnel**
Secure connection exposing services to the internet through the knot tunnel server.

**Tunnel Server**
Knot component that accepts public traffic and routes to user tunnels.

---

## U

**User-Defined Variables**
Variables created by administrators in the web interface. Shared across templates. Accessed as `${{ .var.name }}`.

---

## V

**Volume**
Persistent storage attached to spaces. Survives space restarts but deleted with space.

**VS Code Tunnel**
Microsoft service for connecting desktop VS Code to remote environments.

**VNC**
Remote desktop protocol. Knot supports web-based VNC for graphical environments.

---

## W

**Web Terminal**
Browser-based terminal for accessing spaces. No SSH client required.

**Wildcard Domain**
DNS pattern like `*.knot.internal` that matches all subdomains. Used for space URLs.

---

## Z

**Zone**
Geographic or logical grouping of servers. Used for placing spaces near users and organizing resources.
