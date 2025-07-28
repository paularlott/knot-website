---
title: MariaDB
weight: 40
---

The following example runs a **MariaDB server** within a space. Storage is provided by a volume configured with the **hostpath CSI driver**.

MariaDB is initialized with the root password set to the user's **Service Password** as defined in their user profile.

The job assumes **Docker** is being used for container management. If **Podman** is being used, change the `driver` to `podman` and update the `image` to `registry-1.docker.io/paularlott/knot-mariadb:11.04` to enable spaces to be created using Podman.

---

## Nomad Cluster

### Nomad Job

```hcl
job "${{.user.username}}-${{.space.name}}" {
  datacenters = ["dc1"]

  update {
    max_parallel     = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert      = false
  }

  group "mariadb" {
    count = 1

    volume "data_volume" {
      type            = "csi"
      source          = "mariadb_${{.space.id}}"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "mariadb" {
      env {
        # Define environment variables for agent
        KNOT_SERVER           = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT   = "${{.server.agent_endpoint}}"
        KNOT_SPACEID          = "${{.space.id}}"
        KNOT_TCP_PORT         = "3306"
        KNOT_USER             = "mysql"
        MARIADB_ROOT_PASSWORD = "${{.user.service_password}}"
      }

      driver = "docker"
      config {
        image = "paularlott/knot-mariadb:11.04"

        hostname = "${{ .space.name }}"

        mount {
          type   = "bind"
          source = "local/custom.cnf"
          target = "/etc/mysql/conf.d/custom.cnf"
        }
      }

      volume_mount {
        volume      = "data_volume"
        destination = "/var/lib/mysql"
      }

      resources {
        cpu = 300
        memory = 1024
      }

      template {
        data = <<EOF
[mysqld]
port=3306
default_storage_engine   = InnoDB
innodb_file_per_table    = 1
innodb_lock_wait_timeout = 120
table_definition_cache   = 3000

innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size         = 8M
innodb_log_file_size           = 512M

key_buffer_size    = 16M
max_allowed_packet = 256M
thread_stack       = 192K
thread_cache_size  = 8

myisam-recover  = BACKUP
max_connections = 100

query_cache_size        = 512M
query_cache_limit       = 8M
join_buffer_size        = 256K
table_cache             = 5000
open_files_limit        = 15000
innodb_buffer_pool_size = 8000M
character-set-server    = utf8mb4
collation-server        = utf8mb4_general_ci
init-connect            = 'SET NAMES utf8mb4'
group_concat_max_len    = 10240

[mysql]
default-character-set = utf8mb4

[mysqldump]
max_allowed_packet = 256M
EOF

        destination   = "local/custom.cnf"
        change_mode   = "noop"
      }
    }
  }
}
```

---

### Volume Definition

```yaml
volumes:
  - id: "mariadb_${{.space.id}}"
    name: "mariadb_${{.space.id}}"
    plugin_id: "hostpath"
    capacity_min: 10G
    capacity_max: 10G
    mount_options:
      fs_type: "xfs"
      mount_flags:
        - rw
        - noatime
    capabilities:
      - access_mode: "single-node-writer"
        attachment_mode: "file-system"
```

---

### Connecting to MariaDB

The space exports the **MariaDB port 3306** via the TCP proxy, allowing it to be connected to using [port forwarding](/docs/spaces/port-forwarding). For example:

```shell
knot forward port 127.0.0.1:3306 <space> 3306
```

Where `<space>` is the name of the space.

Once the above command is running, any desktop **MySQL/MariaDB client** should be able to connect to port `3306` on `localhost`. **knot** will handle forwarding the data to the MariaDB server running within the space.
