---
title: Nomad Deployment
weight: 10
---

This section will guide you through deploying a Nomad cluster to run **knot** and the spaces it manages. While this is not a comprehensive guide to deploying multi-server clusters, it serves as a solid starting point.

---

### Choosing a Container Runtime

Nomad can be configured to use either **Docker** or **Podman** for managing containers. If you're unsure which to choose, go with **Docker**, as it is the more mature solution and does not require an additional plugin to work with Nomad.

It is also possible for knot to support both Podman and Docker containers simultaneously, providing flexibility for your deployment.

---

### Deployment Guides

- **[Deploying Nomad & Docker](docker/)**
  A guide to setting up Nomad with Docker for container management.

- **[Deploying Nomad & Podman](podman/)**
  A guide to setting up Nomad with Podman, including the required plugin.

---

### Assumptions

These guides assume the following:
- Installation is on a **single server**.
- DNS is pointed to the server.
- Ingress controllers for the cluster are **not deployed**.
