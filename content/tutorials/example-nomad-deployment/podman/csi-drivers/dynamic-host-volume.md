---
title: Host Volumes
weight: 5
---

**Dynamic Host Volumes** is a simple driver built into Nomad which allocates storage from a local directory on the host. This is useful for testing and simple development environments; however, the volume will only be available on a single server.

---

## Nomad Configuration

The location where the host volume plugin should create the volumes can be set using the `host_volumes_dir` parameter in `client` section of the `nomad.hcl`:

```hcl {filename="nomad.hcl"}
client {
  host_volumes_dir = "/srv/host_volumes"
}
```

By default Nomad stores them under the `data_dir`

---

## Example Usage in Knot

Below is an example of how to use the **dynamic host volume driver**. This configuration should be added to the `Volumes` section of a template or as a standalone volume:

```yaml
volumes:
  - name: "test-volume"
    type: "host"
    plugin_id: "mkdir"
    parameters:
      mode: "0755"
      uid: 1000
      gid: 1000
```
