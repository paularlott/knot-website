---
title: DNS
description: Troubleshooting DNS server issues.
type: Guide
tags: [troubleshooting, networking]
weight: 60
---

Troubleshooting DNS server issues.

---

## DNS Not Resolving

**Symptom**: Cannot resolve knot domains.

**Test DNS resolution**:

```shell
dig @192.168.1.100 -p 3053 knot.internal
nslookup knot.internal 192.168.1.100
```

**Verify client configuration**:

```shell
# Linux
resolvectl status

# macOS
scutil --dns

# Windows
Get-DnsClientNrptPolicy
```

**Solutions**:
- Verify DNS server is running
- Check DNS server listen address and port
- Ensure client is configured to use knot DNS
- Check firewall rules allow DNS traffic
- Verify DNS records are configured correctly

---

## Slow DNS Resolution

**Symptom**: DNS queries take long time to resolve.

**Solutions**:
- Check upstream nameserver performance
- Reduce number of upstream nameservers
- Use local caching DNS resolver
- Check network latency to upstream servers
- Monitor DNS server resource usage

---

## A Space With a Long Name Doesn't Resolve

**Symptom**: Other spaces' web ports open, but one whose name is long gives "DNS not found" or "server not found".

DNS refuses any name with more than 63 characters before the first dot, and `<user>--<space>--<port>` can pass that when the space name is long. knot shortens it: the space name is cut and ends with a hyphen and an 8-character hash. Open the port from the web interface, or take its URL from an event or `knot.server.host_label`, rather than typing the full name. A shortened address made by hand must match the name's hash exactly.

---

## Wildcard Domains Not Working

**Symptom**: Specific domains resolve but wildcard doesn't.

**Test wildcard**:
```shell
dig @192.168.1.100 -p 3053 test.knot.internal
```

**Solutions**:
- Verify wildcard record in configuration: `A|*.knot.internal|IP`
- Check client DNS resolver supports wildcards
- Test with different DNS tools
- Verify no conflicting DNS records
