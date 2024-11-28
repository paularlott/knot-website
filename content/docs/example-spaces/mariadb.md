---
title: MariaDB
weight: 60
---

The following example runs a copy of MariaDB within a space, storage is provided by a volume using the hostpath CSI driver.

MariaDB is initialized with the root password set to the users Service Password as set within their user profile.

```hcl {filename=Nomad-Job}
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

    network {
      port "knot_port" {
        to = 3000
      }
      port "mysql_port" {
        to = 3306
      }
    }

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
        KNOT_SERVER         = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT = "${{.server.agent_endpoint}}"
        KNOT_SPACEID        = "${{.space.id}}"
        KNOT_TCP_PORT       = "3306"
        KNOT_USER           = "mysql"

        MARIADB_ROOT_PASSWORD = "${{.user.service_password}}"
      }

      driver = "docker"
      config {
        image = "paularlott/knot-mariadb:10.11"

        ports = ["knot_port", "mysql_port"]
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

      # Knot Agent Port
      service {
        name = "knot-${{.space.id}}"
        port = "knot_port"

        check {
          name            = "alive"
          type            = "http"
          protocol        = "https"
          tls_skip_verify = true
          path            = "/ping"
          interval        = "10s"
          timeout         = "2s"
        }
      }

      # MySQL Port
      service {
        name = "${{.user.username}}-${{.space.name}}"
        port = "mysql_port"

        check {
          name     = "db_check"
          task     = "mariadb"
          type     = "script"
          command  = "/usr/bin/mysqladmin"
          args     = [ "-uroot", "ping" ]
          interval = "10s"
          timeout  = "5s"

          check_restart {
            limit = 3
            grace = "90s"
            ignore_warnings = false
          }
        }
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

plugin_load_add = file_key_management
file_key_management_filename = /local/keyfile
file_key_management_encryption_algorithm = AES_CBC

[mysql]
default-character-set = utf8mb4

[mysqldump]
max_allowed_packet = 256M
EOF

        destination   = "local/custom.cnf"
        change_mode   = "noop"
      }

      # Generate with: openssl rand -hex 32
      template {
        data = <<EOF
1;4404e5c0d8f7ffe6b7ef1eeaa1abc1dfb57681e5124cb819404df424739ef5fd
EOF
        destination   = "local/keyfile"
        change_mode   = "noop"
      }

    }
  }
}
```

```yaml {filename=Volume-Definition}
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
