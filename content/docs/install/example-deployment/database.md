---
title: Database
weight: 20
---

In this example a redis server is being used as the storage database.

The redis data is stored in `/data/redis-data`.

```hcl {filename="redis.hcl"}
job "redis" {
  group "cache" {
    network {
      port "redis" {
        to = 6379
        static = 6379
      }
    }

    task "redis" {
      driver = "docker"
      config {
        image = "redis:7"
        ports = [ "redis" ]

        mounts {
          type = "bind"
          source = "/data/redis-data"
          target = "/data"
        }
      }
    }

    service {
      name = "redis"
      port = "redis"

      check {
        name     = "redis_check"
        type     = "tcp"
        interval = "10s"
        timeout  = "5s"
      }
    }
  }
}
```

Create the data directory and deploy the job to nomad.

```shell
mkdir -p /data/redis-data
nomad run redis.hcl
```
