---
title: Server Setup
weight: 10
---

The **knot** server requires a configuration file, environment variables, or command-line parameters for setup. In this tutorial, we'll use a configuration file and run the **knot** binary from the command line.

---

### Step 1: Generate the Configuration File and Encryption Key

First, generate a configuration file using the `knot scaffold --server` command, and then create an encryption key:

```shell
knot scaffold --server > knot.toml
knot genkey
```

This will generate a stub configuration file. You'll need to edit the file as follows:

- **`server.agent_endpoint`**: Update this to the host IP and the port from `listen_agent`. For this tutorial, the host IP is `192.168.1.100`, so `agent_endpoint` should be `192.168.1.100:3010`.
- **`server.url`**: Update this to `https://knot.internal:3000` for the tutorial i.e. use http rather than https.
- **`server.wildcard_domain`**: Update this to `*.knot.internal:3000` for the tutorial.
- **`server.encrypt`**: Replace this with the output of the `knot genkey` command above.
- **`server.badgerdb.enabled`**: Set this to `true` to use BadgerDB for data storage.

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

# The URL to the Knot server (used for the web interface)
url = "https://knot.internal:3000"

# The wildcard domain to expose the web interface of spaces on
wildcard_domain = "*.knot.internal:3000"

# Encryption key for protected variables (knot genkey)
encrypt = "2gJcpKPGqDK8JWUCdgCeQQx1uZwP8fhe"

# Optional server zone, defaults to the hostname
#zone = "myservers"

[server.terminal]
webgl = true

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

#### DNS Resolution

To allow access to websites hosted within spaces, **knot** uses a wildcard DNS. Spaces are created with URLs in the format `<user>--<space>--<port>.<wildcard_domain>`.

Depending on your network setup, you may be able to point the domain names (`knot.internal` and `*.knot.internal`) to your computer's IP address. If not, you can enable the internal DNS server by adding the following to `knot.toml` and forwarding DNS requests to knot for resolution:

```toml {filename=knot.toml}
[server.dns]
  enabled = true
  listen = "0.0.0.0:3053"
  records = ["A|knot.internal|127.0.0.1", "A|*.knot.internal|127.0.0.1"]

# Use CloudFlare DNS servers for any unknown record
[resolver]
  nameservers = ["1.1.1.1", "1.0.0.1"]
```

{{< tabs items="Linux,macOS,Windows" >}}

  {{< tab >}}
  ##### systemd-resolved

  For systemd 246 or newer, create the following file to forward `.internal` requests to the **knot** server:

  ```text {filename="/etc/systemd/resolved.conf.d/knot.internal.conf"}
  [Resolve]
  DNS=127.0.0.1:3053
  DNSSEC=false
  Domains=~internal
  ```

  Then restart `systemd-resolved`:

  ```shell
  systemctl restart systemd-resolved
  ```

  ##### Dnsmasq

  Add a configuration file for the `.internal` domain:

  ```text {filename="/etc/dnsmasq.conf.d/knot.internal.conf"}
  server=127.0.0.1:3053
  domain=knot.internal
  ```

  Then restart `dnsmasq`:

  ```shell
  systemctl restart dnsmasq
  ```
  {{< /tab >}}

  {{< tab >}}
  To forward `.internal` requests to **knot**, create the following file:

  ```text {filename="/etc/resolver/knot.internal"}
  nameserver 127.0.0.1
  port 3053
  ```

  **Note:** You may need create the `/etc/resolver` folder first. Use `sudo` to access and modify these files.
  {{< /tab >}}

  {{< tab >}}
  Adjust the `knot.toml` configuration file to use port 53 instead of 3053:

  ```toml
  [server.dns]
    enabled = true
    listen = "0.0.0.0:3053"
    records = ["A|knot.internal|127.0.0.1", "A|*.knot.internal|127.0.0.1"]
  ```

  Then run the following powershell commands:

  ```powershell
  Add-DnsClientNrptRule -Namespace ".knot.internal" -NameServers "127.0.0.1"
  Clear-DnsClientCache
  ```
  {{< /tab >}}
{{< /tabs >}}

---

### Step 2: Start the Server

Run the server using the following command:

```shell
knot server --config knot.toml
```

Any errors will be displayed in the terminal.

---

## What's Next

- [Creating the Admin User](../create-admin-user)
