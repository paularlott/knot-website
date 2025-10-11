---
title: DNS Server
weight: 70
---

The built-in DNS server provides name resolution for knot domains and can forward other queries to upstream nameservers.

---

## Why Use the DNS Server

The DNS server solves the wildcard domain challenge. Spaces are accessed via URLs like `username--spacename--80.knot.internal`. Without proper DNS configuration, these domains won't resolve.

The built-in DNS server provides:
- Automatic resolution of knot domains
- Wildcard domain support
- Forwarding to upstream DNS servers
- Custom DNS records
- Integration with service discovery (Consul)

---

## Basic Configuration

Enable the DNS server in your configuration:

```toml {filename=knot.toml}
[server.dns]
enabled = true
listen = "0.0.0.0:3053"
records = [
  "A|knot.internal|192.168.1.100",
  "A|*.knot.internal|192.168.1.100"
]

[resolver]
nameservers = ["1.1.1.1", "1.0.0.1"]
```

**Configuration options**:
- `enabled`: Enable DNS server
- `listen`: Address and port to listen on
- `records`: Static DNS records to serve
- `nameservers`: Upstream DNS servers for forwarding

---

## DNS Record Format

Records use pipe-delimited format: `TYPE|NAME|VALUE`

**Supported types**: A, AAAA, CNAME, TXT

**Examples**:

```toml
records = [
  "A|knot.internal|192.168.1.100",
  "A|*.knot.internal|192.168.1.100",
  "AAAA|knot.internal|2001:db8::1",
  "CNAME|www.knot.internal|knot.internal"
]
```

---

## Forwarding Configuration

### Basic Forwarding

```toml
[resolver]
nameservers = ["1.1.1.1", "1.0.0.1"]
```

### Consul Integration

```toml
[resolver]
consul = ["192.168.0.4:8600"]
nameservers = ["1.1.1.1", "1.0.0.1"]
```

Queries for `.consul` domains are sent to Consul, others to nameservers.

## Client Configuration

### Linux (systemd-resolved)

```text {filename="/etc/systemd/resolved.conf.d/knot.conf"}
[Resolve]
DNS=192.168.1.100:3053
DNSSEC=false
Domains=&#126;internal
```

Restart: `systemctl restart systemd-resolved`

### Linux (dnsmasq)

```text {filename="/etc/dnsmasq.conf.d/knot.conf"}
server=/internal/192.168.1.100#3053
```

Restart: `systemctl restart dnsmasq`

### macOS

```text {filename="/etc/resolver/internal"}
nameserver 192.168.1.100
port 3053
```

### Windows

```powershell
Add-DnsClientNrptRule -Namespace ".internal" -NameServers "192.168.1.100"
Clear-DnsClientCache
```


