---
title: CSI Drivers
weight: 15
---

When using the volume management within knot it expects the CSI drivers to be installed on the nomad clients and makes requests to those drivers to create and manage the volumes.

## Local Hostpath Driver

The local hostpath driver is a simple driver that mounts a directory on the host into the container. This is useful for testing and simple development environments, however the volume will only be available on a single server.

### Hostpath Controller

```hcl {filename="csi-hostpath.hcl"}
job "csi-hostpath" {
  datacenters = ["dc1"]
  type = "system"
  priority = 100

  group "csi-hostpath" {
    task "plugin" {
      driver = "docker"

      config {
        image = "registry.k8s.io/sig-storage/hostpathplugin:v1.15.0"

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

### Example Usage

Example usage of the hostpath driver, this should be added to the `Volumes` section of a template or a standalone Volume:

```yaml
volumes:
  - id: "test-volume"
    name: "test-volume"
    plugin_id: "hostpath"
    capabilities:
      - access_mode: "single-node-writer"
        attachment_mode: "file-system"
```

## CephFS Driver

The CephFS driver is a driver that mounts a CephFS filesystem into the container. This is useful for shared storage between multiple containers or servers.

### CephFS Controller

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

      driver = "docker"
      config {
        image = "quay.io/cephcsi/cephcsi:latest"
        mount {
          type = "bind"
          source = "local/config.json"
          target = "/etc/ceph-csi-config/config.json"
        }
        mount {
          type     = "tmpfs"
          target   = "/tmp/csi/keys"
          readonly = false
          tmpfs_options = {
            size = 1000000 # size in bytes
          }
        }
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

### CephFS Node

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
      driver = "docker"
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
        mount {
          type = "bind"
          source = "local/config.json"
          target = "/etc/ceph-csi-config/config.json"
        }
        mount {
          type = "bind"
          source = "/lib/modules/${attr.kernel.version}"
          target = "/lib/modules/${attr.kernel.version}"
        }
        mount {
          type     = "tmpfs"
          target   = "/tmp/csi/keys"
          readonly = false
          tmpfs_options = {
            size = 1000000 # size in bytes
          }
        }

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

### Example Usage

This can be added to the `Volumes` section of a template or a standalone Volume

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

## Ceph RBD Driver

The Ceph RBD driver is a driver that mounts a Ceph RBD block device into the container. This is useful for shared storage between multiple containers or servers.

### Ceph RBD Controller

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

      driver = "docker"
      config {
        image = "quay.io/cephcsi/cephcsi:latest"
        mount {
          type = "bind"
          source = "local/config.json"
          target = "/etc/ceph-csi-config/config.json"
        }
        mount {
          type     = "tmpfs"
          target   = "/tmp/csi/keys"
          readonly = false
          tmpfs_options = {
            size = 1000000 # size in bytes
          }
        }
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

### Ceph RBD Node

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
      driver = "docker"
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
        mount {
          type = "bind"
          source = "local/config.json"
          target = "/etc/ceph-csi-config/config.json"
        }
        mount {
          type = "bind"
          source = "/lib/modules/${attr.kernel.version}"
          target = "/lib/modules/${attr.kernel.version}"
        }
        mount {
          type     = "tmpfs"
          target   = "/tmp/csi/keys"
          readonly = false
          tmpfs_options = {
            size = 1000000 # size in bytes
          }
        }

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

### Example Usage

This can be added to the `Volumes` section of a template or a standalone Volume

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
