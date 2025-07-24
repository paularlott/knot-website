---
title: Port Forwarding
weight: 120
---

Port forwarding allows you to securely access ports within a remote space from your local machine. This requires the **knot** [client](/docs/quick-start/client/) to be installed on your computer, as it handles forwarding a local port to a port within the remote container.

---

## Viewing Advertised Ports

1. Ensure the space is running.
2. Click the **`Ports`** icon next to the running space.
   {{< picture src="../images/space-ports.webp" caption="Ports" >}}

3. The list of advertised ports will appear below the dividing line. These ports cannot be clicked but are available for port forwarding.
   - For example, **port 80** may be exposed for web access, and **port 22** (SSH) may also be advertised.

---

## Setting Up Port Forwarding

### Step 1: Connect to the **knot** Server

1. Open a terminal on your local machine.
2. Run the following command, replacing the URL with the address of your **knot** server:

   ```shell
   knot connect https://knot.internal:3000
   ```

3. Enter your username and password when prompted.
4. The generated access key will be stored in `~/.config/knot/knot.yml` for future use.

---

### Step 2: Forward a Local Port to the Space

1. Forward a local port (e.g., `9010`) to a port within the space (e.g., `80`) by running the following command:

   ```shell
   knot forward port 127.0.0.1:9010 phptest 80
   ```

   - **`127.0.0.1:9010`**: The local port to forward.
   - **`phptest`**: The name of the space.
   - **`80`**: The port within the space to forward to.

2. Open a web browser and navigate to `http://127.0.0.1:9010`.
   - If everything is set up correctly, the Caddy file browser (or the service running on port 80) will open in your browser.

---

## Important Notes

- **Authentication**: Ports forwarded in this way require authentication and are not publicly accessible.
- **Security**: The **knot** client ensures secure communication between your local machine and the remote space.

{{< tip >}}
Port forwarding is a secure way to access services within a space without exposing them publicly.
{{< /tip >}}
