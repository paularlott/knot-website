---
title: Hostpath
weight: 10
---

The **local hostpath driver** is a simple driver that mounts a directory on the host into the container. This is useful for testing and simple development environments; however, the volume will only be available on a single server.

{{< tip "warning" >}}
This driver is **not recommended for production use**.
{{< /tip >}}

---

## Hostpath Controller

Below is the Nomad job specification for deploying the **hostpath controller** using **Podman**:

```hcl {filename="csi-hostpath.hcl"}
job "csi-hostpath" {
  datacenters = ["dc1"]
  type = "system"
  priority = 100

  group "csi-hostpath" {
    task "plugin" {
      driver = "podman"

      config {
        image = "registry.k8s.io/sig-storage/hostpathplugin:v1.17.0"

        privileged = true

        args = [
          "--endpoint=unix:///csi/csi.sock",
          "--logtostderr",
          "--v=5",
          "--nodeid=${attr.unique.hostname}",
        ]

        mount {
          type = "bind"
          source = "/csi-data-dir/"
          target = "/csi-data-dir/"
        }
      }

      csi_plugin {
        id        = "hostpath"
        type      = "monolith"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 50
        memory = 32
      }
    }
  }
}
```

---

## Example Usage in Knot

Below is an example of how to use the **hostpath driver**. This configuration should be added to the `Volumes` section of a template or as a standalone volume:

```yaml
volumes:
  - id: "test-volume"
    name: "test-volume"
    plugin_id: "hostpath"
    capabilities:
      - access_mode: "single-node-writer"
        attachment_mode: "file-system"
```
