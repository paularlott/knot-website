---
title: Knot Pro Installation
description: Install and configure Knot Pro to unlock advanced features.
weight: 11
---

Knot Pro includes additional features such as OAuth authentication, visual port forwarding, and advanced networking. {{< pro-badge >}}

---

## Installing Knot Pro

{{< tabs items="Homebrew,Linux Binary,macOS Binary,Windows Binary" >}}

  {{< tab >}}
  ### Homebrew (Linux & macOS)

  Install Knot Pro via Homebrew:

  ```bash
  brew install paularlott/tap/knot-pro
  ```

  To upgrade to the latest version:

  ```bash
  brew upgrade knot-pro
  ```
  {{< /tab >}}

  {{< tab >}}
  ### Linux Binary

  Download the latest binary from [GitHub releases](https://github.com/paularlott/knot-pro/releases).

  ```shell
  curl -sL https://github.com/paularlott/knot-pro/releases/latest/download/knot-pro-linux-amd64 -o knot-pro
  chmod +x knot-pro
  sudo mv knot-pro /usr/local/bin/
  ```
  {{< /tab >}}

  {{< tab >}}
  ### macOS Binary

  Download the latest binary from [GitHub releases](https://github.com/paularlott/knot-pro/releases).

  **Apple Silicon:**

  ```shell
  curl -sL https://github.com/paularlott/knot-pro/releases/latest/download/knot-pro-darwin-arm64 -o knot-pro
  chmod +x knot-pro
  sudo mv knot-pro /usr/local/bin/
  ```

  **Intel:**

  ```shell
  curl -sL https://github.com/paularlott/knot-pro/releases/latest/download/knot-pro-darwin-amd64 -o knot-pro
  chmod +x knot-pro
  sudo mv knot-pro /usr/local/bin/
  ```

  **Note:** If you encounter issues launching the application after downloading it from GitHub, try running the following command:

  ```shell
  sudo xattr -d com.apple.quarantine /usr/local/bin/knot-pro
  ```
  {{< /tab >}}

  {{< tab >}}
  ### Windows Binary

  Download the latest binary for Windows from [GitHub releases](https://github.com/paularlott/knot-pro/releases).
  {{< /tab >}}

{{< /tabs >}}

---

## Configuring the License Key

Knot Pro requires a license key in your configuration file. Add the `license` section to the `[server]` block in your `knot.toml`:

```toml {filename=knot.toml}
[server]
  license.name = "Jane Smith"
  license.key = "A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A7B8C9D0E1F2G3H4I5J6K7L8M9N0O1P2Q3R4S5T6U7V8W9X0Y1Z2A3B4C5D6E7F8G9H0"
```

Replace the `name` and `key` values with your license credentials.

---

## Docker Image

When running Knot Pro in Docker, use the `knot-pro` image instead of `knot`:

```shell
docker pull paularlott/knot-pro:latest
```

For a specific version:

```shell
docker pull paularlott/knot-pro:v2.5.0
```

Update any `docker run` commands or Docker Compose files to reference `paularlott/knot-pro` instead of `paularlott/knot`.

---

## What's Next

- [Local Containers Setup](local-containers/server-setup/) - Configure and run the server
- [Nomad Deployment](nomad/server-setup/) - Deploy to a Nomad cluster
- [Desktop Client](client/) - Install the desktop client
