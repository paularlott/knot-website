---
title: Nomad
description: Quick start guide to getting knot up and running in a Nomad cluster.
weight: 20
---

In this section, you'll learn how to deploy **knot** to a Nomad cluster and walk through creating a simple template to deploy a space.

---

## System Requirements

To complete this tutorial, ensure you have the following:

- A working **Nomad cluster**.
- The **knot** binary installed on your operating system.
- Storage drivers accessible via **Container Storage Interface (CSI)** or space available for use via bind mounts.
- A working **ingress controller**.

---

## Install the Binary

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

---

## What's Next

- [Server Setup](server-setup/)
