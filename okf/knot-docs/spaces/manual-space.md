---
description: Run the knot agent manually on a VM or physical server and connect it to knot as a space.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/spaces/manual-space/
sources:
    - resource: https://getknot.dev/docs/spaces/manual-space/
status: stable
tags:
    - spaces
title: Manual Space
type: Guide
---
# Manual Space

Manual spaces allow you to run the Knot agent manually on a virtual machine or physical server and connect it to the Knot web interface. This provides flexibility for environments where fully managed spaces are not suitable.

---

## Creating a Manual Template

1. Create a new template with the `Platform` set to `Manual`.
2. Use this template to create a space.

---

## Connecting the Agent to the Server

Once the manual space is created, the **Space ID** and an **agent registration key** are displayed. Both are required for the agent to connect to the Knot server; clicking either copies it to the clipboard.

### Download the Agent

The Knot agent is available for download directly from your Knot server. Agents are available for:

- Linux (amd64, arm64)
- macOS (amd64, arm64)

Download the appropriate agent for your platform from your Knot server:

```shell
# Linux amd64
wget https://your-knot-server/agents/knot_agent_linux_amd64.zip
unzip knot_agent_linux_amd64.zip
chmod +x knot-agent

# Linux arm64
wget https://your-knot-server/agents/knot_agent_linux_arm64.zip
unzip knot_agent_linux_arm64.zip
chmod +x knot-agent

# macOS amd64
curl -O https://your-knot-server/agents/knot_agent_darwin_amd64.zip
unzip knot_agent_darwin_amd64.zip
chmod +x knot-agent

# macOS arm64
curl -O https://your-knot-server/agents/knot_agent_darwin_arm64.zip
unzip knot_agent_darwin_arm64.zip
chmod +x knot-agent
```

For Windows, download the full Knot binary from the [client download](../quick-start/client.md) page and use `knot agent start` with the same flags shown below.

Replace `your-knot-server` with the actual address of your Knot server.

### Start the Agent

Assuming the Knot server is running on `192.168.1.100` with the agent interface on port `3010`, use the following command to start the agent and connect it to the server:

```shell
# Using the dedicated agent binary
./knot-agent --endpoint 192.168.1.100:3010 --space-id=0198384f-59f3-74c2-8a88-3a6b4302b391 --registration-key=<key> --syslog-port=0

# Or using the full knot binary
./knot agent start --endpoint 192.168.1.100:3010 --space-id=0198384f-59f3-74c2-8a88-3a6b4302b391 --registration-key=<key> --syslog-port=0
```

- **`--endpoint`**: The IP address and port of the Knot server. Adjust this value based on your environment.
- **`--space-id`**: The unique ID of the space, as displayed in the web interface.
- **`--registration-key`**: The space's registration key, displayed next to the Space ID. The agent proves possession of this key when it registers; without it the server refuses the registration.
- **`--syslog-port=0`**: Disables the syslog port (optional).

This is the minimum configuration required for the agent to connect to the Knot server.

The agent's connection to the server is always TLS. The server's certificate is generated from the zone's encryption key, so the same key value applies to every server in the zone. For strict verification pass `--server-cert-fingerprint` (the certificate fingerprint from the space's API details); without it the connection is still TLS-encrypted and registration-key verified.

---

## Monitoring and Using the Manual Space

Once the agent is successfully started:

1. The Knot web interface will update to show the space as running.
2. Services such as the web terminal will become available.

The web terminal for a manual space functions the same way as it does for a fully managed space, providing shell access and other features.
