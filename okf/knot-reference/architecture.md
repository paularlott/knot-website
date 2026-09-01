---
description: Core components and topics for understanding knot's architecture and designing effective deployments.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/architecture/
sources:
    - resource: https://getknot.dev/reference/architecture/
status: stable
tags:
    - architecture
title: Architecture
type: Overview
---
# Architecture

Understanding Knot architecture helps you design effective deployments.

---

## Core Components

**Server**
The knot server provides the web interface, API, and manages all resources. It stores data in a database and coordinates with agents.

**Agent**
The agent runs inside containers and communicates with the server. It handles SSH, terminal access, and space lifecycle commands.

**Database**
Stores users, templates, spaces, and configuration. Options: BadgerDB, MySQL/MariaDB, or Redis/Valkey.

**Container Runtime**
Executes spaces. Options include: Docker, Podman, Nomad, or Apple Container.

---

## Topics

- [Deployment Modes](architecture/deployment-modes.md) - Standalone, cluster, and leaf configurations
- [Cluster Architecture](architecture/cluster-architecture.md) - Leaderless design and data flow
- [Network Architecture](architecture/network.md) - Ports, communication, and security
- [Scalability](architecture/scalability.md) - Scaling strategies and performance
