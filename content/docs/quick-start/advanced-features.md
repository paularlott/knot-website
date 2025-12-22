---
title: Advanced Features
weight: 45
---

Once you're familiar with the basics of **knot**, you can explore advanced features to enhance your development workflow, manage complex deployments, and integrate with AI assistants.

---

## Node Selection

In multi-server environments, **knot** can automatically select the best server for your spaces or allow manual selection based on specific requirements.

- **Automatic Selection**: Let **knot** choose the optimal server based on runtime availability, load balancing, and zone affinity
- **Manual Selection**: Specify which server should host a space during creation
- **Runtime Detection**: **knot** automatically detects available container runtimes (Docker, Podman, Apple Containers) across your cluster

[Learn more about Node Selection](../configuration/node-selection/)

---

## Agent Commands

Spaces run with an agent that provides additional management capabilities and inter-space communication.

### Space Management
- **Shutdown and Restart**: Control space lifecycle from within the container
- **Set Notes**: Add custom notes to spaces for organization
- **Agent Status**: Monitor agent health and connectivity

### Inter-Space Communication
- **Agent-to-Agent Port Forwarding**: Securely forward ports between spaces in the same zone
- **Service Discovery**: Connect microservices and applications across spaces

[Learn more about Agent Commands](../spaces/agent-commands/) | [Agent-to-Agent Port Forwarding](../spaces/agent-agent-port-forwarding/)

---

## AI Integration with MCP

The Model Context Protocol (MCP) enables AI assistants to interact with **knot** for automated space management and development tasks.

- **Tool Discovery**: Dynamic tool availability based on your permissions
- **Native Tools Mode**: Pre-loaded tools for simpler integration
- **Skills Integration**: Access knowledge base for best practices and platform specifications

[Learn more about MCP](../ai/mcp/) | [Skills System](../ai/skills/)

---

## Advanced Configuration

### Templates
Create reusable space templates for consistent deployments:
- **Container Templates**: Docker, Podman, and Apple Containers
- **Nomad Templates**: Orchestrated deployments with Nomad
- **Custom Specifications**: Tailor templates to your infrastructure

[Learn more about Templates](../templates/)

### Tunnels
Expose services publicly with secure tunneling:
- **HTTP Tunnels**: Web applications and APIs
- **TCP Tunnels**: Databases and custom services
- **Wildcard Domains**: Dynamic subdomain allocation

[Learn more about Tunnels](../tunnels/)

### Cluster Mode
Scale **knot** across multiple servers:
- **High Availability**: Automatic failover and load distribution
- **Data Synchronization**: Consistent state across servers
- **Network Modes**: HTTPS and direct TCP/UDP communication

[Learn more about Cluster Mode](../configuration/cluster-mode/)

---

## Next Steps

- Explore the [full documentation](../) for detailed guides
- Check the [API tokens](../api-tokens/) for programmatic access
- Review [best practices](../best-practices/) for production deployments
- Troubleshoot issues with the [troubleshooting guide](../troubleshooting/)