---
title: DNS Server
description: Built-in DNS server for knot domain name resolution with upstream forwarding.
type: Overview
tags: [networking, configuration]
weight: 70
---

The built-in DNS server provides name resolution for knot domains and can forward other queries to upstream nameservers.

Enabling it (`server.dns.enabled`) serves the wildcard domain to two audiences from one authoritative source:

- **External clients** (your laptop, a browser, another host) — e.g. point macOS `/etc/resolver/internal` at it.
- **Inside every space** — each space's in-container agent runs a resolver on `127.0.0.1:53` that forwards `*.<wildcard>` queries here and the rest to your upstream nameservers, so processes inside the space resolve `<space>.<wildcard-domain>` with no per-container configuration.

See [In-Space Resolution](#in-space-resolution-agent-dns) below for the space-side details.

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

Records use pipe-delimited format: `TYPE|NAME|VALUE[|TTL]`, where the trailing `TTL` (seconds) is optional and overrides the default.

**Supported types**: A, AAAA, CNAME, MX, SRV, TXT

| Type   | Format                                         |
|--------|------------------------------------------------|
| A      | `A\|NAME\|IP[\|TTL]`                             |
| AAAA   | `AAAA\|NAME\|IPv6[\|TTL]`                        |
| CNAME  | `CNAME\|NAME\|TARGET[\|TTL]`                     |
| MX     | `MX\|NAME\|TARGET\|PRIORITY[\|TTL]`              |
| SRV    | `SRV\|NAME\|TARGET\|PORT\|PRIORITY\|WEIGHT[\|TTL]` |
| TXT    | `TXT\|NAME\|VALUE[\|TTL]`                        |

The default TTL when none is given is `server.dns.default_ttl` (`--dns-default-ttl` / `KNOT_DNS_DEFAULT_TTL`, default **300**).

**Examples**:

```toml
[server.dns]
default_ttl = 60                       # default TTL for records without one

records = [
  "A|knot.internal|192.168.1.100",     # uses default_ttl (60)
  "A|*.knot.internal|192.168.1.100|10", # explicit 10s TTL
  "AAAA|knot.internal|2001:db8::1",
  "CNAME|www.knot.internal|knot.internal",
  "MX|knot.internal|mail.knot.internal|10",
  "SRV|_http._tcp.knot.internal|knot.internal|80|10|60"
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

---

## In-Space Resolution (Agent DNS)

Enabling the DNS server (`server.dns.enabled`) does double duty: it serves the wildcard domain to **external** clients (your laptop, macOS `/etc/resolver`, …) *and* makes processes **inside** every space resolve through the knot server too. No separate flag — `dns-enabled` is the signal that knot manages DNS for the wildcard domain everywhere.

```toml {filename=knot.toml}
[server.dns]
enabled = true
listen   = "0.0.0.0:3053"
records  = ["A|*.knot.internal|192.168.8.53"]   # the authoritative wildcard record(s)

[server]
wildcard_domain = "knot.internal"

[resolver]
nameservers = ["1.1.1.1", "1.0.0.1"]             # upstream for non-wildcard queries (optional)
```

The server's DNS serves the wildcard zone from `server.dns.records` and forwards everything else upstream — using `resolver.nameservers` if set, otherwise the system default. So `nameservers` is **optional**: leave it unset and the server falls back to the host resolver.

For each space the server injects:

- `--dns 127.0.0.1` — the container's **sole** nameserver, pointing at the agent resolver.
- `KNOT_AGENT_DNS=1` — gates the agent's resident resolver on.
- `KNOT_SERVER_DNS=<ip>:<port>` — the address of the knot server's own DNS server, derived from the **agent endpoint** host (where the server process — and its `:3053` listener — actually runs, often a different host from the URL/ingress) plus `server.dns.listen`'s port. The agent forwards **every** query here.
- `KNOT_SERVER_RESOLVE=<host>:<port>:<ip>` — a `curl --resolve` value derived from the **URL** host (the address the entrypoint fetches the agent from). Since the nameserver is `127.0.0.1` (not up until the agent starts), the entrypoint can't resolve `KNOT_SERVER`; it passes this to `curl`, which connects straight to the IP while keeping the hostname for SNI/Host. If the server can't resolve either hostname, it refuses to start the space.

The agent then starts a resolver on `127.0.0.1:53` that forwards all queries to the knot server DNS (`KNOT_SERVER_DNS`) over **TCP**. TCP is used (rather than UDP) because the knot DNS frequently runs on the same host as the container (e.g. macOS Apple Containers), where UDP to the host's own address is refused by the OS (hairpin NAT) but TCP works; the knot DNS listens on TCP already. The resolver binds before the agent's command socket, so once the agent is ready DNS is guaranteed up.

Every base image entrypoint runs `knot agent wait-for-start` (an agent subcommand that blocks until the daemon's command socket is accepting connections) right after launching the agent and before any startup scripts — so startup scripts never race the agent. This wait is unconditional; with DNS enabled it additionally guarantees `:53` is bound before the first lookup. If the agent predates this subcommand (older server), the wait exits silently with an informational note.

{{< tip >}}
The wildcard record must be defined in `server.dns.records` (e.g. `A|*.knot.internal|<server-ip>`) for `*.<wildcard>` to resolve — that's the authoritative record the server serves and the agents forward to.
{{< /tip >}}

{{< tip >}}
Because each space already depends on the agent endpoint for its core connection, routing all DNS through the server adds no new dependency — if the server is unreachable the space is non-functional regardless.
{{< /tip >}}

{{< tip "warning" >}}
On **Nomad**, the server injects the environment signal into every task and sets `dns_servers = ["127.0.0.1"]` on each **docker- or podman-driver** task's config (both pass it through as `--dns`). Knot's Nomad jobs use one of those drivers, so this needs no extra configuration. Tasks using other drivers won't get the DNS entry and would need it set manually in the job spec.
{{< /tip >}}

---

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


