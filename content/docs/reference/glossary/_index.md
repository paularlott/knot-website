---
title: Glossary
weight: 30
---

Common terms and concepts used in **knot**.

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

**BadgerDB**
Embedded database option for single-server deployments. No external dependencies required.

**Backup**
Export of knot data including users, templates, spaces, and configuration. Can be encrypted for security.

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

## L

**Leaf Mode**
Lightweight deployment that connects to a central cluster. Runs spaces locally while managing templates centrally.

**Leaderless Architecture**
Cluster design where all servers are equal. No single point of failure.

---

## M

**Manual Template**
Template for environments where the knot agent is started manually. Used for physical machines or custom setups.

---

## N

**Nomad**
Container orchestration platform. Knot can deploy spaces to Nomad clusters.

**Nomad Template**
Template that deploys spaces to a Nomad cluster using HCL job specifications.

---

## P

**Permission**
Specific action a user can perform. Granted through roles.

**Podman**
Container runtime alternative to Docker. Supported for local container templates.

**Port Forwarding**
Tunneling connections from local machine to ports in a space.

**Protected Variable**
User-defined variable stored encrypted in the database.

---

## Q

**Quota**
Limit on resources a user or group can consume. Includes space count, compute units, and storage units.

---

## R

**Role**
Collection of permissions defining what actions users can perform.

**Restore**
Import knot data from a backup file.

---

## S

**Schedule**
Time-based rules for when spaces can run. Spaces outside schedule are automatically stopped.

**Space**
Running instance of a template. Isolated environment with compute, storage, and network resources.

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
