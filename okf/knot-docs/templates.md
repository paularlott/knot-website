---
description: Templates are reusable blueprints that define compute, storage, networking, and tooling for knot spaces.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/templates/
sources:
    - resource: https://getknot.dev/docs/templates/
status: stable
tags:
    - templates
title: Templates
type: Overview
---
# Templates

Templates are the foundation of Knot. They define reusable environment configurations that users can deploy as spaces with a single click. Think of templates as blueprints for development environments, complete with compute resources, storage, networking, and tooling.

---

## What is a Template?

A template defines:

- **Platform**: Where the environment runs (Nomad cluster, Docker, Podman, Apple Container, or KVM virtual machines)
- **Container specification**: The image, environment variables, and runtime configuration
- **Volumes**: Persistent storage that survives space restarts
- **Resources**: CPU, memory, and storage allocations
- **Features**: Enabled capabilities like SSH, web terminal, or Code Server
- **Access control**: Which groups can use the template
- **Custom variables**: User-defined values set when creating a space

---

## Available Platforms

Admins can restrict which backends templates may use with the server's `--enabled-backends` flag (`KNOT_ENABLED_BACKENDS`, config `server.enabled_backends`): a list of `manual`, `docker`, `podman`, `apple`, `nomad` and `kvm`. Empty (the default) offers everything — manual included. A non-empty list must name everything it wants offered, manual included: `["docker"]` disables manual templates too, `["docker", "manual"]` keeps them. The template editor only shows offered platforms — with a single container backend enabled it shows that backend as a plain option instead of the Local Container dropdown.

The list also sets the auto-detection order for `Local Container` templates: container backends are probed in the order listed, so `--enabled-backends podman,docker` makes Podman the auto-detected runtime when both are available. (This flag replaced the former `--local-container-runtime-pref`.)

This is a policy allowlist, separate from runtime detection: a listed backend still needs a node that can run it (see [runtime availability](templates/kvm-templates.md#requirements)). Existing templates on a since-disabled platform stay editable but can't be switched to another disabled one, and new templates can't use it.

## Template Types

**KVM Templates**
Run spaces as full virtual machines on KVM-capable nodes, booted from cloud images with bridged or NAT networking. Best for workloads that need their own kernel, systemd, or non-container toolchains. See [KVM Templates](templates/kvm-templates.md).

**Nomad Templates**
Run in a Nomad cluster using HCL job specifications. Best for production deployments with high availability and scalability.

**Docker/Podman Templates**
Run on local machines or single servers using container runtimes. Ideal for individual developers or small teams.

**Apple Container Templates**
Run on macOS using Apple's native container runtime. Perfect for macOS-specific development.

**Manual Templates**
For environments where you manually start the knot agent. Useful for physical machines or custom setups.

---

## Volume Lifecycle

Understanding how volumes work is critical:

- **Space creation**: All volumes defined in the template are created
- **Space start/stop**: Volumes persist and retain all data
- **Space deletion**: All volumes and their data are permanently removed
- **Template updates**: If volumes are removed from a template, they are deleted when the space next starts


Deleting a space permanently destroys all volumes and data. Always backup important data before deletion.


---

## Storage Systems

**Nomad Templates**
Use Container Storage Interface (CSI) plugins for flexible storage options including network storage, local storage, and cloud provider volumes.

**Local Container Templates**
Use the native volume system of Docker, Podman, or Apple Container for local persistent storage.

---

## Common Use Cases

- **Development environments**: Pre-configured with languages, tools, and dependencies
- **Testing environments**: Isolated spaces for QA with specific configurations
- **Training environments**: Consistent setups for workshops or onboarding
- **Demo environments**: Quick deployment of product demos
- **CI/CD runners**: Ephemeral build and test environments

---

## What's Next

- [Managing Templates](templates/managing.md)
- [Nomad Templates](templates/nomad-templates.md)
- [Local Container Templates](templates/local-containers.md)
