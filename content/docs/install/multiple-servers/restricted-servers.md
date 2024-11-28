---
title: Restricted Servers
weight: 70
---

Restricted servers are leaf servers that are connected to the origin server using a personal API key, in this mode they run in a restricted mode and have limited access to variables and other elements hosted within the origin server.

Restricted servers are useful to run in a LAN environment when performance is paramount or resources are only available in a specific developer location.

To start a restricted server, first login to the Origin server, select `API Tokens` from the menu and click `Create Token` to create a new token.

![](/docs/administration/create-api-token.webp)

Start the server with the `--shared-token` option or using the environment variable `KNOT_SHARED_TOKEN` set to the new token and `--origin-server` or `KNOT_ORIGIN_SERVER` set to the address of the origin server.

## Shared Items

**Volumes**, are not shared between origin servers and restricted servers. However the volume menu is available on restricted servers, any volume defined and used only on a restricted server will only be available on that server.

**Variables**, only global variables are shared from the origin server to the restricted servers and only if they are not marked restricted.

The variable menu is available on restricted servers but will not show any global variables from the origin server. Additional variables can be defined on the restricted servers, however these variables are marked local and only exist within the restricted servers..
