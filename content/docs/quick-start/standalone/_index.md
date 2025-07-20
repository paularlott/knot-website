---
title: Standalone
description: Quick start guide to getting knot up and running on a local machine.
weight: 10
---

In this section, you'll learn how to set up knot and get started quickly. We'll cover the system requirements, guide you through deploying a standalone instance of knot, and walk you through creating a simple Template to deploy a space.

Once your space is up and running, this guide will introduce you to key features of knot, helping you explore its capabilities and understand how it can streamline your development workflows.

## System Requirements

To complete this tutorial, ensure you have the following:

- A machine with Docker or Podman installed and properly configured.
- The **knot** binary available for your operating system.

## Install the Binary

{{< tabs items="Linux,macOS,Windows" >}}

  {{< tab >}}
  The Linux client can be installed via Homebrew or by downloading the latest binary from [GitHub releases](https://github.com/paularlott/knot/releases).

  ```bash
  brew install paularlott/tap/knot
  ```
  {{< /tab >}}
  {{< tab >}}
  The preferred install method for macOS is via Homebrew

  ```bash
  brew install paularlott/tap/knot
  ```

  Alternatively the latest binary can be downloaded from [GitHub releases](https://github.com/paularlott/knot/releases).

  **Note:** If you encounter issues launching the application after downloading it from GitHub, try running the following command:

  ```shell
  sudo xattr -d com.apple.quarantine <path to binary>/knot
  ```
  {{< /tab >}}

  {{< tab >}}
  The latest binary can be downloaded from [GitHub releases](https://github.com/paularlott/knot/releases)
  {{< /tab >}}

{{< /tabs >}}

---

## What's Next

- [Server Setup](server-setup/)
