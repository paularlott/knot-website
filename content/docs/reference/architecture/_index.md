---
title: Architecture
weight: 20
---

Understanding **knot** architecture helps you design effective deployments.

---

## Core Components

**Server**
The knot server provides the web interface, API, and manages all resources. It stores data in a database and coordinates with agents.

**Agent**
The agent runs inside containers and communicates with the server. It handles SSH, terminal access, and space lifecycle commands.

**Database**
Stores users, templates, spaces, and configuration. Options: BadgerDB, MySQL/MariaDB, or Redis/Valkey.

**Container Runtime**
Executes spaces. Options: Docker, Podman, Nomad, or Apple Container.

---

## Topics

- [Deployment Modes](deployment-modes/) - Standalone, cluster, and leaf configurations
- [Cluster Architecture](cluster-architecture/) - Leaderless design and data flow
- [Network Architecture](network/) - Ports, communication, and security
- [Scalability](scalability/) - Scaling strategies and performance
