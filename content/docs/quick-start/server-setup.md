---
title: Server Setup
weight: 10
---

The **knot** server requires a configuration file, environment variables, or command-line parameters for setup. In this tutorial, we'll use a configuration file and run **knot** via a Docker container.

### Step 1: Generate the Configuration File and Encryption Key

First, generate a configuration file using the `knot scaffold --server` command, and then create an encryption key:

```shell
docker run --rm paularlott/knot knot scaffold --server > knot.toml
docker run --rm paularlott/knot knot genkey
```

This will generate a stub configuration file. You'll need to edit the file as follows:

- **`server.agent_endpoint`**: Update this to the host IP and the port from `listen_agent`. For this tutorial, the host IP is `192.168.1.100`, so `agent_endpoint` should be `192.168.1.100:3010`.
- **`server.wildcard_domain`**: Update this to `*.knot.internal` for the tutorial.
- **`server.encrypt`**: Replace this with the output of the `knot genkey` command above.
- **`server.badgerdb.enabled`**: Set this to `true` to use BadgerDB for data storage.
- **`server.tls.use_tls`**: Add this setting and set it to `false` to disable HTTPS.

### Example Configuration File

Below is the updated configuration file (`knot.toml`):

```toml {filename=knot.toml}
# Server configuration
[server]

# Address and port to listen on
listen = "0.0.0.0:3000"

# Address and port to listen on for agents
listen_agent = "0.0.0.0:3010"

# Address and port for the agents to connect to
agent_endpoint = "192.168.1.100:3010"

# The wildcard domain to expose the web interface of spaces on
wildcard_domain = "*.knot.internal"

[server.tls]
use_tls = false

[server.terminal]
webgl = true

# Encryption key for protected variables (knot genkey)
encrypt = "2gJcpKPGqDK8JWUCdgCeQQx1uZwP8fhe"

# Optional server zone, defaults to the hostname
#zone = "myservers"

# MySQL storage
[server.mysql]
enabled = false
# MySQL host if prefixed with srv+ then SRV+ lookup will be performed
host = "localhost"
port = 3306
user = "root"
password = ""
database = "knot"

# BadgerDB storage
[server.badgerdb]
enabled = true
path = "./badgerdb/"

# Redis storage
[server.redis]
enabled = false
# Redis host if prefixed with srv+ then SRV+ lookup will be performed
hosts = ["localhost:6379"]
password = ""
db = 0

[server.nomad]
addr = "http://127.0.0.1:4646"
token = ""

# [server.cluster]
# advertise_addr = "wss://knot.example.com/"
# key = "VF9hmdXZyzNF3rcP6M0P" # knot genkey
# peers = [
#   "wss://knot.example.com",
#   "wss://knot1.example.com",
#   "wss://knot2.example.com"
# ]

# Optional nameservers to use for SRV lookups
# [resolver]
#   consul = ["192.168.0.4:8600"]
#   nameservers = ["192.168.0.2:53"]

[log]
level = "info"
```

### Step 2: Start the Server

Run the server using the following command:

```shell
docker run --rm -v "$PWD"/knot.toml:/etc/knot/knot.toml -p 3000:3000 -p 3010:3010 paularlott/knot
```

Any errors will be displayed in the terminal.

---

## What's Next

- [Creating the Admin User](../create-admin-user)
