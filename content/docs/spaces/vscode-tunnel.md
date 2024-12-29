---
title: VSCode Tunnel
weight: 40
---

Knot allows the management of Visual Studio Code Tunnels from it's web interface.

After starting a new space the `Visual Studio Code` icon will be shown against to the space.

If the tunnel hasn't been created then it will be red, clicking the icon will open a terminal window allowing completion of tunnel registration with the users GitHub or Microsoft account. Simply follow the instructions in the terminal window to complete the registration, once the URL of the new tunnel appears close the terminal window.

{{< image src="../connect-tunnel-icon.webp" alt="Connect VSCode Tunnel" >}}

![Register Tunnel](vscode-tunnel-connect.webp)

When the tunnel is established the icon will no longer be red and clicking it will open a new tab or window with the Visual Studio Code editor.

{{< image src="../vscode-tunnel-connected.webp" alt="VSCode Tunnel Connected" >}}

Assuming the space template uses a volume for `/home/` then the tunnel configuration and changes made to Visual Studio Code including themes and extensions are persistent across restarts of the space.

![VSCode via Tunnel](vscode.webp)
