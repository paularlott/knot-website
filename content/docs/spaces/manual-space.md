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

### Example Agent Command

Assuming the **knot** server is running on `192.168.1.100` with the agent interface on port `3010`, use the following command to start the agent and connect it to the server:

```shell
./knot agent --endpoint 192.168.1.100:3010 --space-id=0198384f-59f3-74c2-8a88-3a6b4302b391 --syslog-port=0
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
