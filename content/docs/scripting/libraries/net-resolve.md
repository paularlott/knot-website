---
title: scriptling.net.resolve
weight: 140
---

DNS resolution library for IP lookup, SRV record resolution, and srv+http URL resolution. Available in all environments.

---

## Functions

| Function | Description |
|----------|-------------|
| `lookup_ip(host)` | Resolve a hostname to a list of IP addresses |
| `lookup_srv(service)` | Resolve an SRV record to a list of addresses |
| `resolve_srv_http(uri)` | Resolve a srv+http(s):// URI to a concrete URL |

---

## Usage

```python
import scriptling.net.resolve as resolve

# Resolve a hostname to IPs
ips = resolve.lookup_ip("example.com")
print(ips)  # ["93.184.216.34"]

# Resolve an SRV record
addrs = resolve.lookup_srv("_myservice._tcp.example.com")
for addr in addrs:
    print(f"{addr['ip']}:{addr['port']}")

# Resolve a srv+ URL
url = resolve.resolve_srv_http("srv+https://api.example.com/v1")
print(url)  # "https://api.example.com:8443/v1"
```

---

## Environment Compatibility

| MCP | Remote | External |
|-----|--------|----------|
| ✓   | ✓      | ✓        |
