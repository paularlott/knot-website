---
title: Introduction
linkTitle: Documentation
description: Getting started and working with knot for the management of cloud based development environments.
---

**knot** is a lightweight, single-binary tool designed to simplify the management of development environments. It can operate as a standalone application or within a Nomad cluster, offering flexibility for both cloud-based and local setups.

With **knot**, environments are defined using `Templates`. These templates specify storage, compute, and other requirements, enabling developers and users to launch new environments with a single click. Storage needs can be met using CSI drivers in a Nomad cluster or local volumes when running on Docker or Podman.

## Key Benefits

- **Distributed Architecture**:
  **knot** supports a leaderless distributed cluster, allowing servers to be placed closer to developers. This reduces network latency while maintaining centralized management of templates and users. It's an ideal solution for globally distributed development teams.

- **Local and Cluster Modes**:
  In addition to cluster mode, **knot** supports a hybrid setup where a local instance connects to a cluster member using a personal token. This allows templates to be managed centrally while running environments locally for maximum performance.

- **Versatility Across Teams**:
  While originally designed for developers, **knot** has become a valuable tool for quality assurance teams. Its ability to quickly spawn and destroy test environments enables efficient testing workflows, including destructive testing without risk to production systems.

## Core Features

- Unified management for users and environments
- Flexible tunneling options:
  - From a cloud environment to a local machine
  - From a local machine to a cloud environment
  - From the public web to a cloud or local environment
- SSH support for seamless integration with tools like VSCode
- Local-like experience for cloud environments
- Self-hosted for full control over data and infrastructure
- Role-based access control (RBAC) with permissions and groups
- Web-based terminal for easy access
- Scalability through Nomad and Consul
- Compatibility with single-machine setups using Docker or Podman
- Open-source under the Apache 2.0 License

## What's Next

- [Get Started](getting-started/)
