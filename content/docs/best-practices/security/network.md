---
title: Network Security
weight: 10
---

Network configuration and access control.

---

## Private Network Deployment

Knot is designed for trusted environments. Deploy on private networks with access via VPN.

**Recommendations**:
- Run knot servers on private network segments
- Use VPN for remote developer access
- Implement network segmentation
- Use firewall rules to restrict access to knot ports

---

## Public Exposure

If exposing knot to the internet:
- Enable two-factor authentication (required)
- Use strong passwords
- Implement IP rate limiting
- Monitor authentication logs
- Consider additional authentication layers (SSO, OAuth)

---

## Tunnel Server Security

The tunnel server exposes services publicly:
- Run tunnel server on separate port from main interface
- Only expose tunnel port to internet
- Monitor tunnel usage and connections
- Implement rate limiting on tunnel port
- Use HTTPS for all tunnel traffic

---

## Firewall Configuration

Restrict access to knot ports:

**Internal network**:
- Port 3000: Web interface (allow from VPN)
- Port 3010: Agent connections (allow from container network)

**Public internet** (if needed):
- Port 3001: Tunnel server only

Block all other ports from public access.

---

## Container Network Isolation

Isolate container networks:
- Use separate networks for different environments
- Implement network policies
- Restrict container-to-container communication
- Monitor network traffic
