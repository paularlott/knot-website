---
description: Minimum configuration to deploy Nomad, Consul, and knot using Podman.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/tutorials/example-nomad-deployment/podman/
sources:
    - resource: https://getknot.dev/docs/tutorials/example-nomad-deployment/podman/
status: stable
tags:
    - deployment
    - installation
title: Nomad & Podman
type: Overview
---
# Nomad & Podman

This example provides the minimum configuration required to deploy Nomad and Consul. While it offers a functional setup, it is **not suitable for production environments**.


In a production cluster, the setup would include:

- Multiple servers to ensure **high availability**.
- An **ingress controller** for managing external access.
- Proper **DNS handling**.
- **Two-Factor Authentication (2FA)** enabled for **knot**.

---

### Assumptions

This guide assumes the following setup:

- A virtual machine with a clean install of **Ubuntu 22.04**.
- The virtual machine has an IP address of `192.168.0.10`.
- The following domain names are correctly pointed to the virtual machine:
  - `knot.getknot.dev`
  - `*.knot.getknot.dev`
  - `*.tunnel.getknot.dev`
