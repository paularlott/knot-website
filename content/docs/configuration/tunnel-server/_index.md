---
title: Tunnel Server
weight: 40
---

Tunnels allow local HTTP and HTTPS services to be securely exposed on the internet via a **knot** server.

---

## Configuring the Server

To enable tunneling, the **knot** server must be configured to allow tunnel traffic. Add the following configuration to the `knot.toml` file adjusting as required:

```toml
[server]
listen_tunnel = "0.0.0.0:3001"
# tunnel_server = "https://knot.internal:3001"
tunnel_domain = "*.knot-tunnel.internal:3001"
```

### Configuration Parameters

- **`listen_tunnel`**: The address and port the server will listen on for tunnel traffic. Ensure your firewall is configured to allow traffic to this port.

- **`tunnel_server`** *(optional)*: The address of the tunnel server. By default, this is the URL of the **knot** server instance. This setting is only required when multiple **knot** instances are behind a load balancer. In such cases, this URL should point to each individual **knot** server.

- **`tunnel_domain`**: The wildcard domain name under which tunnels will appear. For example: `<user>--<tunnel name>.knot-tunnel.internal:3001`.
