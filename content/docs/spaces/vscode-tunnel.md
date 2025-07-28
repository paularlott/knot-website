---
title: VSCode Tunnel
weight: 40
---

**knot** enables the management of Visual Studio Code Tunnels directly from its web interface, providing seamless access to a fully-featured VSCode editor for your spaces.

---

## Accessing the VSCode Tunnel

1. Start a space from the `Spaces` page.
2. Once the space is running, the **`VSCode Tunnel`** icon (#3) will appear.
   {{< picture src="../images/running-space.webp" caption="Running Space" >}}

---

## Configuring the VSCode Tunnel

- If the tunnel has not been configured, the icon will appear **red**.
- Click the red **`VSCode Tunnel`** icon to open a terminal window.
- Follow the instructions in the terminal to complete the tunnel registration using your **GitHub** or **Microsoft** account.
- Once the URL of the new tunnel is displayed, close the terminal window.

{{< picture src="../images/vscode-tunnel-connect.webp" caption="Connect VSCode Tunnel" >}}

---

## Using the VSCode Tunnel

- After the tunnel is successfully established, the **`VSCode Tunnel`** icon will no longer be red.
- Click the icon to open a new tab or window with the Visual Studio Code editor.

{{< picture src="../images/vscode.webp" caption="VSCode via a Tunnel" >}}

---

## Persistence Across Restarts

If the space template includes a volume for `/home/`, the following configurations will persist across space restarts:
- Tunnel configuration.
- Changes made to Visual Studio Code, including themes and extensions.
