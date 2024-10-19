---
title: Visual Studio Code
weight: 30
---

![](/docs/working-with-spaces/running-space-ports.webp)

To start the web based Visual Studio Code click the `Code Server` icon next to the running space, if this icon isn't available then the agent isn't detecting code-server running within the container. When the icon is clicked a new window is opened the the code-server.

Initially code-server is started without any configuration or plugins, however these can all be added as they would be in the desktop version. For more information on code-server please see the [code-server project page](https://github.com/coder/code-server).

Assuming the template uses a volume for `/home/` then changes to code-server are persistent across restarts.

![](/docs/working-with-spaces/code-server.webp)
