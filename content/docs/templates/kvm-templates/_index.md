---
title: KVM Templates
description: KVM templates run spaces as full virtual machines on KVM-capable nodes, booted from cloud images with configurable networking.
type: Overview
tags: [templates, deployment]
weight: 35
---

KVM templates run spaces as **full virtual machines** rather than containers. Spaces boot from a cloud-init capable qcow2 image, get their own kernel and systemd, and persist across restarts — stopping a space shuts the VM down, starting it boots the same machine, and only deleting the space destroys it.

KVM shines for workloads containers can't host: kernels and modules that must match a target system, systemd services, and non-Linux-compatible toolchains. Everything interactive (terminal, VS Code, SSH, scripts, jobs) works exactly as with containers — the agent installs on first boot and connects back to the server.

The full references:

- [VM Specification](vm-spec/) — every field of the job YAML including the `network:` block
- [KVM Nodes](/docs/configuration/kvm/) — preparing and configuring nodes (packages, storage, networking)

---

### Requirements

KVM spaces run on nodes that advertise the `kvm` runtime: `/dev/kvm` present, `virsh` and `virt-install` installed, and a reachable `qemu:///system` libvirt daemon. Nodes publish the runtime to the cluster automatically; template placement and node selection behave like local container templates. Each node also needs an ISO tool for the cloud-init seed — `genisoimage`, `mkisofs` or `xorriso`.

See [KVM Nodes](/docs/configuration/kvm/) for the full setup, including storage permissions for non-root servers.

### Quick Example

```yaml
name: ${{ .user.username }}-${{ .space.name }}
hostname: ${{ .space.name }}
image: ubuntu-24.04
memory: 4G
cpus: 2
disk: 20G
network:
  mode: bridged
  cidr: 192.0.2.0/24
  bridge: br0
  ip_range_start: 192.0.2.10
  ip_range_end: 192.0.2.100
  gateway: 192.0.2.1
environment:
  - EDITOR=vim
```

The `network.mode` picks between **bridged** (static IPs from the range, directly reachable on the LAN) and **nat** (libvirt NAT network, DHCP inside the VM, no addresses to manage). Both are described in the [VM specification](vm-spec/).

### Pools

Pools can back **NAT** KVM templates — members are created and DHCP without any addresses to assign. **Bridged** KVM templates cannot back pools: their spaces need an IP address chosen at creation, which a pool has no one to pick; pool creation rejects them.

### Lifecycle

VMs persist across stop/start: the domain stays defined and the disk untouched. A template change applied on the next start redefines the domain with the new resources and cloud-init configuration while keeping the disk. A space's IP address can be changed while the space is stopped — cloud-init applies the new address at the next boot. Deleting the space destroys the VM and removes its disks.

### Access

- **SSH** uses the owner's knot username (`ssh <username>@<space>.<domain>`, or directly at the VM's address in bridged mode) — the VM's real sshd is per-user. Spaces whose images rely on knot's built-in SSH server accept any username.
- **Web console**: every running KVM space has a Console action in the spaces list (screen icon), opening the VM's serial console in the browser — a login prompt served by the VM itself, reached even when the agent has not connected. Log in with the owner's knot username and service password. The serial console requires the image to run a getty on `ttyS0` (standard on cloud images); on the host, the same console is available with `virsh console <domain>`.
- **VNC** for a graphical console: `virsh domdisplay <domain>` with a VNC viewer, or `virt-viewer`. The console accepts the space owner's knot service password.
- **Device passthrough**: PCI, USB and vendor:product devices can be handed to the VM exclusively — see the [VM specification](vm-spec/).
