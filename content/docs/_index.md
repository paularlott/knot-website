---
title: Introduction
linkTitle: Documentation
description: Getting started and working with knot for the management of cloud based development environments.
---

**knot** is a lightweight, single-binary tool that simplifies managing development environments. Whether you need a single local setup or a globally distributed cluster, knot provides consistent, on-demand environments for your team.

## The Problem knot Solves

Development teams face common challenges:

- Developers waste time configuring local environments
- "Works on my machine" issues slow down collaboration
- Remote teams experience high latency to centralized resources
- QA teams need quick, isolated test environments
- Onboarding new developers takes days instead of minutes

**knot** solves these by providing instant, consistent environments that can run anywhere.

## How It Works

Environments are defined using templates that specify everything needed: container images, storage, resources, and features. Users create spaces from templates with a single click. Each space is isolated, persistent, and accessible via web terminal, SSH, or IDE integrations.

knot runs as a standalone application on Docker/Podman or scales across Nomad clusters with a leaderless architecture for high availability.

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

- [Quick Start](quick-start/)
