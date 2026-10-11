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
Stores users, templates, spaces, and configuration. Options: BadgerDB, MySQL/MariaDB, PostgreSQL, or Redis/Valkey.

**File Storage** 
Optional [buckets of files](../knot-docs/file-storage.md), kept in a storage directory on each server rather than in the database and replicated to every server in the cluster. Reached from the web interface, `knot file`, the `knot.files` library, the API and, on Knot Pro, an S3 endpoint.

**Container Runtime**
Executes spaces. Options include: Docker, Podman, Nomad, or Apple Container.

---

## Topics
