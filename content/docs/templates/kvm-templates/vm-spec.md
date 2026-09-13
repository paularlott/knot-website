---
title: VM Specification
linkTitle: VM Spec
description: The YAML virtual machine specification used by KVM templates.
type: Guide
tags: [templates, configuration]
weight: 36
---

KVM templates use a YAML specification that the template wizard generates and that can be hand-edited. Knot variables like `${{ .user.username }}` resolve at deploy time like all templates.

```yaml
name: <libvirt domain name>
hostname: <VM hostname>
image: <cloud image>
memory: <e.g. 2G>
cpus: <vCPU count>
disk: <overlay size, e.g. 20G>
network:
  mode: <bridged | nat>
  bridge: <host bridge or libvirt network>
  cidr: <network CIDR>              # bridged only
  ip_range_start: <address>         # bridged only
  ip_range_end: <address>           # bridged only
  gateway: <address>                # bridged only, optional
environment:
  - "<variable>=<value>"
devices:
  - <hostdev spec>
```

---

## Fields

### `name`
The libvirt domain name. Defaults to `${{ .user.username }}-${{ .space.name }}`.

### `hostname`
The VM's hostname. Defaults to the space name.

### `image`
A cloud-init capable qcow2 image matching the node's architecture. Three forms:

- **Bare name** (`ubuntu-24.04`) — resolved against the node's cloud image directory (`--kvm-cloud-image-path`, default `/var/lib/libvirt/images/knot/cloud-images`), with `.qcow2` appended when the name has no suitable suffix. Stock Ubuntu/Debian/Fedora cloud images work as-is.
- **URL** — downloaded once into the node's image cache.
- **Absolute path** — a file on the node.

The image must have cloud-init installed; a plain server image ignores the provisioning seed entirely.

### `memory`
VM memory, e.g. `2G`. Defaults to 512M when unset.

### `cpus`
vCPU count. Defaults to 1.

### `disk`
Caps the VM disk's virtual size, e.g. `20G`. Empty keeps the base image's size. The disk is a copy-on-write overlay of the base image — space data lives on it and persists across restarts.

### `environment`
Entries written into the agent's environment file inside the VM. Values are single-quoted automatically; spaces and special characters are safe.

### `devices`
Host devices passed through to the VM, in the forms virt-install's `--hostdev` accepts:

- PCI address: `pci_0000_01_00_0`
- USB bus.device pair: `usb_002_003`
- vendor:product hex pair: `0x8086:0x1234`

PCI devices (e.g. GPUs) require IOMMU enabled and the device bound to `vfio-pci` on the node; the VM holds the device exclusively while running. The list is edited in the raw YAML and the wizard's Host Devices section.

---

## The `network:` block

The network block is required — a KVM spec without one is rejected at save time. Its shape depends on the mode.

### `mode: bridged` (default)

The VM attaches to a **host Linux bridge** and carries a **static IP** chosen from the template's range at space creation time, directly reachable on the network.

| Field | Required | Description |
|---|---|---|
| `mode` | recommended | `bridged` when omitted |
| `bridge` | optional | Host bridge name, default `br0`. Must exist on the node with the physical NIC enslaved (see [KVM nodes](/docs/configuration/kvm/#bridged-networking)) |
| `cidr` | yes | The IPv4 network the VMs live on, e.g. `192.0.2.0/24` |
| `ip_range_start` / `ip_range_end` | yes | The address range spaces pick their IP from (validated at creation against the range and addresses already in use) |
| `gateway` | optional | Defaults to the network's first usable address |

Values must be literal — template variables are rejected, since they're validated at save time and used to validate space IPs at creation time.

### `mode: nat`

The VM attaches to a **libvirt NAT network** (named by `bridge`, default `default`, started automatically if inactive) and gets its address by DHCP. No addresses to configure or assign; the agent, terminal, VS Code and SSH all work through the relay. The VM is only directly reachable from the node itself — `virsh domifaddr <domain> --source lease` shows its address.

Static addressing fields (`cidr`, `ip_range_start`, `ip_range_end`, `gateway`) must **not** be set in nat mode; validation rejects them.

NAT is the right choice for laptops and WiFi-only hosts — 802.11 cannot bridge VM traffic onto a wireless LAN.

---

## Provisioning

On first boot, cloud-init configures the VM from a seed knot generates:

- The OS account is the **space owner's knot username**, with sudo, and its password set to the owner's knot service password (console debugging via `virsh domdisplay`; SSH stays key-only with the owner's keys pushed by the agent).
- The knot agent is installed to `/usr/local/bin/knot` (re-fetched from the server once per boot) and runs as the owner via systemd.
- `qemu-guest-agent` is installed in bridged mode so `virsh domifaddr --source agent` can see the static address.
- Network configuration per the `network:` block (static in bridged mode; DHCP fallback in nat mode).

The seed's cloud-init instance-id derives from a hash of its own content, so any change — IP, service password, template environment — is re-applied on the VM's next boot, while an unchanged configuration boots fast.
