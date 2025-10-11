---
title: DNS
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
