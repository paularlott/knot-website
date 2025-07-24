---
title: Tunnels
weight: 7000
---

Tunnels allow a space to access a service running on your local workstation. This requires the **knot** [client](/docs/quick-start/client/) to be installed on your computer, as it handles forwarding traffic from the remote space to a local port.

---

### Setting Up a Tunnel

#### Step 1: Connect to the **knot** Server

1. Open a terminal on your local workstation.
2. Run the following command, replacing the URL with the address of your **knot** server:

   ```shell
   knot connect https://knot.internal:3000
   ```

---

#### Step 2: Create a Tunnel

To expose a service running on your local machine to a space, use the `knot space tunnel` command. For example, to expose **Ollama** running on local port `11434` to the space `phptest`, run:

```shell
knot space tunnel phptest 11434 11434
```

- The first `11434` is the local port on your workstation.
- The second `11434` is the port within the space.

---

### Testing the Tunnel

1. Open the **web terminal** of the space.
2. Run the following command to test the connection:

   ```shell
   curl -s http://localhost:11434/api/tags | jq '.models[].name'
   ```

If the tunnel is working correctly, the list of available models will be displayed in the terminal.
