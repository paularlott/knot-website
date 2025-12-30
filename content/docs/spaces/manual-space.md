---
title: Manual Space
weight: 20
---

Manual spaces allow you to run the **knot** agent manually on a virtual machine or physical server and connect it to the **knot** web interface. This provides flexibility for environments where fully managed spaces are not suitable.

---

## Creating a Manual Template

1. Create a new template with the `Platform` set to `Manual`.
2. Use this template to create a space.

{{< picture src="../images/manual-template.webp" caption="Manual Template" >}}

---

## Connecting the Agent to the Server

Once the manual space is created, the **Space ID** will be displayed. This ID is required for the agent to connect to the **knot** server. Clicking the ID will copy it to the clipboard.

{{< picture src="../images/manual-space.webp" caption="Manual Space" >}}

### Download the Agent

The **knot** agent is available for download directly from your **knot** server. Agents are available for:

- Linux (amd64, arm64)
- macOS (amd64, arm64)
- Windows (amd64, arm64)

Download the appropriate agent for your platform from your **knot** server:

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

# Windows (PowerShell)
Invoke-WebRequest -Uri https://your-knot-server/agents/knot_agent_windows_amd64.exe.zip -OutFile knot_agent_windows_amd64.exe.zip
Expand-Archive knot_agent_windows_amd64.exe.zip
```

Replace `your-knot-server` with the actual address of your **knot** server.

### Start the Agent

Assuming the **knot** server is running on `192.168.1.100` with the agent interface on port `3010`, use the following command to start the agent and connect it to the server:

```shell
./knot-agent --endpoint 192.168.1.100:3010 --space-id=0198384f-59f3-74c2-8a88-3a6b4302b391 --syslog-port=0
```

- **`--endpoint`**: The IP address and port of the **knot** server. Adjust this value based on your environment.
- **`--space-id`**: The unique ID of the space, as displayed in the web interface.
- **`--syslog-port=0`**: Disables the syslog port (optional).

This is the minimum configuration required for the agent to connect to the **knot** server.

---

## Monitoring and Using the Manual Space

Once the agent is successfully started:

1. The **knot** web interface will update to show the space as running.
2. Services such as the web terminal will become available.

The web terminal for a manual space functions the same way as it does for a fully managed space, providing shell access and other features.
