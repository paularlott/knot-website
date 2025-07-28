---
title: CephFS
weight: 20
---

The **CephFS driver** mounts a CephFS filesystem into the container, making it ideal for shared storage between multiple containers or servers.

---

## CephFS Controller

Below is the Nomad job specification for deploying the **CephFS controller** using **Podman**:

```hcl {filename="csi-cephfs-controller.hcl"}
job "csi-cephfs-controller" {
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
    "clusterID": "def7c9bb-f0a8-429b-b55a-386c2335d92d",
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
          "--type=cephfs",
          "--controllerserver=true",
          "--drivername=cephfs.csi.ceph.com",
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
        address = "${attr.unique.network.ip-address}"
        tags = [ "prometheus" ]
      }
      csi_plugin {
        id        = "cephfs"
        type      = "controller"
        mount_dir = "/csi"
      }
    }
  }
}
```

---

## CephFS Node

Below is the Nomad job specification for deploying the **CephFS node** using **Podman**:

```hcl {filename="csi-cephfs-node.hcl"}
job "csi-cephfs-node" {
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
    "clusterID": "def7c9bb-f0a8-429b-b55a-386c2335d92d",
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
          "--type=cephfs",
          "--drivername=cephfs.csi.ceph.com",
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
        address = "${attr.unique.network.ip-address}"
        tags = [ "prometheus" ]
      }
      csi_plugin {
        id        = "cephfs"
        type      = "node"
        mount_dir = "/csi"
      }
    }
  }
}
```

---

## Example Usage in Knot

Below is an example of how to use the **CephFS driver**. This configuration can be added to the `Volumes` section of a template or as a standalone volume:

```yaml
volumes:
  - id: "test-volume"
    name: "test-volume"
    plugin_id: "cephfs"
    capacity_min: 10G
    capacity_max: 10G
    capabilities:
      - access_mode: "multi-node-multi-writer"
        attachment_mode: "file-system"
    secrets:
      adminID: "nomad.cephfs"
      adminKey: "FWrwe2323d3QWdqwdqwdce!@+23fiseQW/DQWd=="
      userID: "nomad.cephfs"
      userKey: "FWrwe2323d3QWdqwdqwdce!@+23fiseQW/DQWd=="
    parameters:
      clusterID: "b13bf70b-253c-4691-b3f2-46df86f4318c"
      fsName: "cephfs"
```
