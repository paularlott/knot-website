---
title: Database
weight: 20
---

In this example, we will use a **Valkey server** as the storage database.

The Redis data will be stored in the directory `/data/valkey-data`.

---

## Valkey Job Configuration

Below is the Nomad job specification for deploying the Valkey server using **Podman**:

```hcl {filename="valkey.hcl"}
job "valkey" {
  group "cache" {
    network {
      port "valkey" {
        to = 6379
        static = 6379
      }
    }

    task "valkey" {
      driver = "podman"
      config {
        image = "registry-1.docker.io/valkey/valkey:8.1"
        ports = [ "valkey" ]

        volumes = [
          "/data/valkey-data:/data"
        ]
      }
    }

    service {
      name = "valkey"
      port = "valkey"

      check {
        name     = "valkey_check"
        type     = "tcp"
        interval = "10s"
        timeout  = "5s"
      }
    }
  }
}
```

---

## Steps to Deploy

1. **Create the Data Directory**
   Ensure the directory for storing Valkey data exists by running:

   ```shell
   mkdir -p /data/valkey-data
   ```

2. **Deploy the Job to Nomad**
   Use the following command to deploy the Valkey job:

   ```shell
   nomad run valkey.hcl
   ```
