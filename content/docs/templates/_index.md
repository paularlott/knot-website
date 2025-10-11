---
title: Templates
weight: 50
---

Templates are the foundation of **knot**. They define reusable environment configurations that users can deploy as spaces with a single click. Think of templates as blueprints for development environments, complete with compute resources, storage, networking, and tooling.

---

## What is a Template?

A template defines:

- **Platform**: Where the environment runs (Nomad cluster, Docker, Podman, or Apple Container)
- **Container specification**: The image, environment variables, and runtime configuration
- **Volumes**: Persistent storage that survives space restarts
- **Resources**: CPU, memory, and storage allocations
- **Features**: Enabled capabilities like SSH, web terminal, or Code Server
- **Access control**: Which groups can use the template
- **Custom variables**: User-defined values set when creating a space

---

## Template Types

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

{{< tip "warning" >}}
Deleting a space permanently destroys all volumes and data. Always backup important data before deletion.
{{< /tip >}}

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

- [Managing Templates](managing/)
- [Nomad Templates](nomad-templates/)
- [Local Container Templates](local-containers/)
