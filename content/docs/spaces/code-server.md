---
title: Code Server
weight: 50
---

**knot** provides access to the web-based Code Server, offering a browser-accessible development environment similar to Visual Studio Code.

---

## Starting Code Server

1. Ensure the space is running.
2. Click the **`Code Server`** icon (#2) next to the running space.
   {{< picture src="../images/running-space.webp" caption="Running Space" >}}

3. A new window will open, launching the Code Server interface.

---

## Code Server Configuration

- By default, Code Server starts without any pre-installed configuration or plugins.
- Users can customize Code Server by adding extensions, themes, and settings, just as they would in the desktop version of Visual Studio Code.
- For more details on Code Server, visit the [code-server project page](https://github.com/coder/code-server).

---

## Persistence Across Restarts

If the space template includes a volume for `/home/`, all changes made to Code Server, including installed plugins and configurations, will persist across space restarts.

---

## Permissions and Template Requirements

- To use Code Server, the user must have a role with the **`Use Code Server`** permission.
- Code Server must be enabled in the space template for the feature to be available.

{{< picture src="../images/code-server.webp" caption="Code Server" >}}
