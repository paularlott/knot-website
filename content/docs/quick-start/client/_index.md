---
title: Desktop Client
description: Covers the installation of the desktop client.
weight: 5
---

While not required to use the **knot** web interface, the desktop client provides additional functionality, including:

- **SSH Access**: Seamlessly connect to spaces via SSH.
- **Local Tunnels**: Create tunnels between your local machine and spaces.
- **Public Port Exposure**: Expose ports from spaces to the public internet.

---

## Installation

{{< tabs items="Linux,macOS,Windows" >}}

  {{< tab >}}
  ### Linux Installation

  The Linux client can be installed via Homebrew or by downloading the latest binary from [GitHub releases](https://github.com/paularlott/knot/releases).

  ```bash
  brew install paularlott/tap/knot
  ```
  {{< /tab >}}

  {{< tab >}}
  ### macOS Installation

  The preferred installation method for macOS is via Homebrew:

  ```bash
  brew install paularlott/tap/knot
  ```

  Alternatively, you can download the latest binary from [GitHub releases](https://github.com/paularlott/knot/releases).

  **Note:** If you encounter issues launching the application after downloading it from GitHub, try running the following command:

  ```shell
  sudo xattr -d com.apple.quarantine <path to binary>/knot
  ```
  {{< /tab >}}

  {{< tab >}}
  ### Windows Installation

  The latest binary for Windows can be downloaded from [GitHub releases](https://github.com/paularlott/knot/releases).
  {{< /tab >}}

{{< /tabs >}}
