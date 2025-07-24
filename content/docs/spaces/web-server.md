---
title: Accessing Web Pages in a Space
weight: 60
---

When a space is configured to expose web ports (e.g., for a web server), the **`Ports`** icon provides access to these ports. This feature allows users to view web pages or services running within the space directly from their browser.

---

### Viewing Exposed Ports

1. Ensure the space is running.
2. Click the **`Ports`** icon next to the running space.
   {{< picture src="../images/space-ports.webp" caption="Ports" >}}

3. A list of available ports will be displayed:
   - **Clickable Ports**: The top group of ports in the menu are clickable. Clicking a port name or number will open a new browser tab pointing to that port.
   - **Informational Ports**: The bottom group of ports is for use with command-line port forwarding and is shown for informational purposes only.

4. For example, clicking **port 80** will open the web interface exposed by the space.

---

### Example: Caddy File Browser

If the space is running the **knot** PHP image, clicking **port 80** will open the Caddy file browser:
{{< picture src="../images/caddy-file-browser.webp" caption="Caddy Server" >}}

Other container images may display different content depending on their configuration.

---

### Important Notes

- **Authentication**: Ports exposed via the web interface do not require authentication to access them.
- **Port Groups**:
  - The **top group** in the Ports menu is interactive and allows direct access to web pages or services.
  - The **bottom group** is for advanced users who need to forward ports via the command line.

{{< tip "warning" >}}
Be cautious when exposing ports via the web interface, as they are accessible without authentication.
{{< /tip >}}
