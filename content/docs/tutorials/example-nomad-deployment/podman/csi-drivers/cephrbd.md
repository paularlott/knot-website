---
title: Ceph RBD
weight: 30
---

The **Ceph RBD driver** mounts a Ceph RBD block device into the container, making it ideal for shared storage between multiple containers or servers.

---

## Ceph RBD Controller

Below is the Nomad job specification for deploying the **Ceph RBD controller** using **Podman**:

```hcl {filename="csi-cephrbd-controller.hcl"}
job "csi-rbd-controller" {
  datacenters = ["dc1"]
  priority = 100

  group "controller" {
    network {
      port "metrics" {}
    }
    task "ceph-controller" {
      template {
        data        = <<EOF
[{
    "clusterID": "b13bf70b-253c-4691-b3f2-46df86f4318c",
    "monitors": [
        "192.168.0.100",
        "192.168.0.101",
        "192.168.0.102"
    ]
}]
EOF
        destination = "local/config.json"
        change_mode = "restart"
      }

      driver = "podman"
      config {
        image = "quay.io/cephcsi/cephcsi:latest"

        volumes = [
          "local/config.json:/etc/ceph-csi-config/config.json:ro,noexec"
        ]
        tmpfs = [
          "/tmp/csi/keys"
        ]

        args = [
          "--type=rbd",
          "--controllerserver=true",
          "--drivername=rbd.csi.ceph.com",
          "--endpoint=unix://csi/csi.sock",
          "--nodeid=${node.unique.name}",
          "--instanceid=${node.unique.name}-controller",
          "--pidlimit=-1",
          "--logtostderr=true",
          "--v=5",
          "--metricsport=$${NOMAD_PORT_metrics}"
        ]
      }
      resources {
        cpu    = 10
        memory = 32
      }
      service {
        name = "${NOMAD_JOB_NAME}"
        port = "metrics"
        tags = [ "prometheus" ]
      }
      csi_plugin {
        id        = "cephrbd"
        type      = "controller"
        mount_dir = "/csi"
      }
    }
  }
}
```

---

## Ceph RBD Node

Below is the Nomad job specification for deploying the **Ceph RBD node** using **Podman**:

```hcl {filename="csi-cephrbd-node.hcl"}
job "csi-rbd-node" {
  datacenters = ["dc1"]
  type = "system"
  priority = 100

  group "node" {
    network {
      port "metrics" {}
    }
    task "ceph-node" {
      driver = "podman"
      template {
        data        = <<EOF
[{
    "clusterID": "b13bf70b-253c-4691-b3f2-46df86f4318c",
    "monitors": [
        "192.168.0.100",
        "192.168.0.101",
        "192.168.0.102"
    ]
}]
EOF
        destination = "local/config.json"
        change_mode = "restart"
      }
      config {
        image = "quay.io/cephcsi/cephcsi:latest"

        volumes = [
          "local/config.json:/etc/ceph-csi-config/config.json:ro,noexec",
          "/lib/modules/${attr.kernel.version}:/lib/modules/${attr.kernel.version}:ro"
        ]
        tmpfs = [
          "/tmp/csi/keys"
        ]

        args = [
          "--type=rbd",
          "--drivername=rbd.csi.ceph.com",
          "--nodeserver=true",
          "--endpoint=unix://csi/csi.sock",
          "--nodeid=${node.unique.name}",
          "--instanceid=${node.unique.name}-nodes",
          "--pidlimit=-1",
          "--logtostderr=true",
          "--v=5",
          "--metricsport=$${NOMAD_PORT_metrics}"
        ]
        privileged = true
      }
      resources {
        cpu    = 10
        memory = 64
      }
      service {
        name = "${NOMAD_JOB_NAME}"
        port = "metrics"
        tags = [ "prometheus" ]
      }
      csi_plugin {
        id        = "cephrbd"
        type      = "node"
        mount_dir = "/csi"
      }
    }
  }
}
```

---

## Example Usage in Knot

Below is an example of how to use the **Ceph RBD driver**. This configuration can be added to the `Volumes` section of a template or as a standalone volume:

```yaml
volumes:
  - id: "test-volume"
    name: "test-volume"
    plugin_id: "cephrbd"
    capacity_min: 10G
    capacity_max: 10G
    mount_options:
      fs_type: "ext4"
      mount_flags:
        - rw
        - noatime
    capabilities:
      - access_mode: "single-node-writer"
        attachment_mode: "file-system"
    secrets:
      userID: "nomad.rbd"
      userKey: "FWrwe2323d3QWdqwdqwdce!@+23fiseQW/DQWd=="
    parameters:
      clusterID: "b13bf70b-253c-4691-b3f2-46df86f4318c"
      pool: "rbd"
      imageFeatures: "deep-flatten,exclusive-lock,fast-diff,layering,object-map"
```
