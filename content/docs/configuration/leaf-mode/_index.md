---
title: Leaf Node
weight: 30
---

Leaf node mode allows a **knot** server to run on a local machine while maintaining access to templates and resources configured within the cluster. This setup is ideal for scenarios where performance is critical or when accessing resources that are only available in a local configuration.

By default, support for leaf mode is enabled. However, it can be disabled by setting `server.cluster.allow_leaf_nodes` to `false` in the `knot.toml` configuration file.

{{< picture src="images/leaf-node.svg" caption="Cluster with Leaf Node" >}}

---

## Configuring the Leaf Server

To configure a leaf server, follow these steps:

### 1. Set Up the Local Server

Begin by setting up a **knot** server on the local workstation. Follow the [Local Containers Server Setup Guide](../../quick-start/local-containers/server-setup/), but **do not start the server yet**. Once the setup is complete, return to this guide.

---

### 2. Create a Personal Access Token

A personal access token is required for the leaf server to connect to the cluster. To create one:

1. Log in to the **knot** server that the leaf will connect to.
2. Click on `API Tokens` in the menu. If this option is unavailable, request permission from your site administrator.
3. Click `New Token` and provide a name for the token (e.g., `Leaf Test`) to identify it.
   {{< picture src="images/create-token.webp" caption="New Token Form" >}}
4. Click `Create Token` to generate the access token.
   {{< picture src="images/token-list.webp" caption="List of Available Tokens" >}}

---

### 3. Configure the Leaf Node

Add the token and server information to the `knot.toml` configuration file of the leaf node:

```toml
[server.origin]
server = "https://knot-server.internal"
token = "dp2IlH_wQWIA_ad_UApHjAGYLZMcvn4vsH383N-AB2I="
```

#### Configuration Parameters

- **`server`**: The URL of the **knot** server that the leaf will connect to.
- **`token`**: The API token generated in the previous step. Click the token in the list to copy it to your clipboard for easy pasting.

---

### 4. Start the Leaf Server

Start the **knot** server on the local machine using the following command:

```shell
knot server --config knot.toml
```

Once the server is running, open the web interface of the local instance at `https://knot.internal:3000` (as per the Local Containers guide). Log in using your email address and password from the cluster.

---

{{< tip "warning" >}}
Tokens that have not been used for access in over two weeks are automatically removed from the system.
{{< /tip >}}
