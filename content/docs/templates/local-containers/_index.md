---
title: Local Containers
description: Local Container templates support Docker, Podman, and Apple Container runtimes for spaces on local machines.
type: Overview
tags: [templates, deployment]
weight: 30
---

Local Container templates run spaces directly on the server's machine using Docker, Podman, or Apple Containers — no orchestrator required. When a space is created and started, Knot provisions the template's volumes and launches the container locally.

The full reference for writing one:

- [Container Specification](container-spec/) — every field of the job YAML with runtime-support notes
- [Volume Specification](volume-spec/) — volume definitions and path resolution rules
- For a walkthrough of creating your first template, see the [quick start](/docs/quick-start/local-containers/creating-a-template/)

---

### Runtime Selection

When creating a template, you can specify the container runtime:

- **Local Container** (default): Automatically selects an available runtime based on preference order
- **Docker**: Explicitly uses Docker
- **Podman**: Explicitly uses Podman
- **Apple Container**: Explicitly uses Apple Container (macOS only)

#### Automatic Runtime Selection

When set to **Local Container**, Knot will attempt to use container runtimes in the following default order:

1. Docker
2. Podman
3. Apple Container

This order can be customized in the server configuration:

```toml
[server.local_containers]
runtime_pref = ["podman", "apple"]
```

The above example configures Knot to prefer Podman first, then Apple Container.

#### Runtime Notes

**Docker and Podman** support all spec fields. Podman requires fully qualified image names (e.g., `registry-1.docker.io/image:tag`).

**Apple Container** does not support `privileged`, `cap_add`, `cap_drop`, `devices`, or `add_host`, has no registry authentication (`auth`), and prefixes image names without a domain with `registry-1.docker.io`.
