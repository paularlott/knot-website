---
description: Preparing and configuring nodes to run KVM virtual machine spaces.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/configuration/kvm/
sources:
    - resource: https://getknot.dev/docs/configuration/kvm/
status: stable
tags:
    - configuration
    - deployment
title: KVM Nodes
type: Guide
---
# KVM Nodes

KVM spaces run on cluster nodes that advertise the `kvm` runtime. This page covers preparing a node and the server configuration options that control KVM behaviour.

---

## Preparing a Node

A node advertises `kvm` when all of the following are true:

- `/dev/kvm` exists (virtualization enabled in firmware)
- `virsh` and `virt-install` are installed
- the `qemu:///system` libvirt daemon is reachable
- an ISO tool is installed for the cloud-init seed: `genisoimage`, `mkisofs` or `xorriso`

On a Debian/Ubuntu node:

```sh
sudo apt install qemu-kvm libvirt-daemon-system virtinst genisoimage
sudo usermod -aG libvirt <knot-user>
```

Once up, the node lists `kvm` alongside its container runtimes (visible on the cluster info page), and KVM templates become schedulable there.

### Storage permissions

Knot needs to create per-space directories under its images path, and the qemu user must be able to traverse every parent directory. The simplest arrangement is the default images path inside libvirt's tree, pre-created and owned by the knot user:

```sh
sudo mkdir -p /var/lib/libvirt/images/knot/cloud-images
sudo chown -R <knot-user>:<knot-user> /var/lib/libvirt/images/knot
```

knot does not need to run as root. libvirt's dynamic ownership chowns each VM's disk and seed to the qemu user when the domain starts, so the standard `/var/lib/...` parents (already world-traversable) work as-is.

If you keep images under a home directory instead, grant the qemu user (`libvirt-qemu` on Debian/Ubuntu, `qemu` on Fedora) search permission on every parent — home directories are commonly `0750`, which fails with `Cannot access storage file ... Permission denied`:

```sh
sudo setfacl -m u:libvirt-qemu:--x /home/<user>
```

Templates whose `image:` is an `https://` URL download the base into the cache directory (`--kvm-base-image-path`, default `<images path>/base/`) on first use and reuse the cached file afterwards. To pre-seed a node (or to control exactly what runs on it), drop the qcow2 into that directory named as the URL's last path segment, or into the cloud-images library and reference it by bare name.

### Cloud images

Drop cloud-init capable qcow2 images (matching the node's architecture) into `/var/lib/libvirt/images/knot/cloud-images`, or point `--kvm-cloud-image-path` at your library. A spec's bare `image:` name resolves there — e.g. `ubuntu-24.04` finds `ubuntu-24.04.qcow2`. Images must have cloud-init installed; stock cloud images from Ubuntu, Debian and Fedora all qualify.

---

## Networking

### Bridged networking

Bridged mode requires a host Linux bridge with the physical NIC enslaved — the bridge is the VM's path onto the LAN. With netplan, move the host's LAN address onto the bridge:

```yaml
# /etc/netplan/01-kvm-bridge.yaml
network:
  version: 2
  bridges:
    br0:
      interfaces: [<physical-nic>]
      addresses: [192.0.2.50/24]
      routes: [{to: default, via: 192.0.2.1}]
      nameservers: {addresses: [192.0.2.1, 1.1.1.1]}
```

Apply with `sudo netplan try` — it auto-rolls-back after 30 seconds, which protects remote changes. On NetworkManager-managed hosts, create the bridge and a bridge-slave connection for the NIC with `nmcli` (or the GUI) and make sure the bridge connection has autoconnect enabled — a GUI-created bridge with no enslaved NIC passes no traffic.

Verify with `bridge link`: both the physical NIC and the VM's `vnet*` tap should show `master br0`.

**WiFi cannot bridge** — 802.11 rejects frames from foreign source MACs. On WiFi-only hosts use NAT mode.

### NAT networking

No host setup: the VM attaches to libvirt's `default` NAT network (or any libvirt network you name), DHCPs its address, and reaches the world through the node. Choose it per template with `mode: nat` in the [VM specification](../templates/kvm-templates/vm-spec.md).

---

## Server configuration

| Option | Default | Description |
|---|---|---|
| `--kvm-images-path` | `/var/lib/libvirt/images/knot` | Working storage: per-space disk overlays and cloud-init seeds (one directory per space, named after the domain) |
| `--kvm-base-image-path` | *follows images path* (`<images path>/base`) | Cache for base images downloaded from URLs in KVM specs; files are named after the URL's last path segment and reused by later spaces |
| `--kvm-cloud-image-path` | *follows images path* (`<images path>/cloud-images`) | Read-only library of cloud images; bare `image:` names resolve here |
| `--kvm-resolvers` | `1.1.1.1, 1.0.0.1` | DNS servers handed to bridged VMs via cloud-init. The gateway is never injected implicitly — add your router's address here if it should answer DNS |

All three are also settable via environment (`KNOT_KVM_IMAGES_PATH`, `KNOT_KVM_CLOUD_IMAGE_PATH`, `KNOT_KVM_RESOLVERS`) and config file (`server.kvm.*`). Relative paths are resolved against the directory the server starts in.

## Troubleshooting

- **Boot fails, "bridge does not exist"** — create the bridge and enslave the NIC, or switch the template to `mode: nat`.
- **`Cannot access storage file ... Permission denied`** — the qemu user can't traverse the images path's parents; see storage permissions above.
- **VM boots, agent never connects** — check the VM's console (`virsh domdisplay <domain>`, service password login), then `journalctl -u knot-agent -b` inside. NAT mode: confirm the server's URL is reachable from inside the VM.
- **`virsh domifaddr` empty** — static-IP VMs have no DHCP leases; bridged installs `qemu-guest-agent` so `--source agent` works, NAT works with `--source lease`.
