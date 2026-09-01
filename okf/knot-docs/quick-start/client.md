---
description: Install the Knot client CLI for SSH access, tunnels, and exposing ports from spaces.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/quick-start/client/
sources:
    - resource: https://getknot.dev/docs/quick-start/client/
status: stable
tags:
    - deployment
title: Client
type: Overview
---
# Client

While not required to use the Knot web interface, the client CLI provides additional functionality, including:

- **SSH Access**: Seamlessly connect to spaces via SSH.
- **Local Tunnels**: Create tunnels between your local machine and spaces.
- **Public Port Exposure**: Expose ports from spaces to the public internet.

---

## Installation



  
  ### Linux Installation

  The Linux client can be installed via Homebrew or by downloading the latest binary from [GitHub releases](https://github.com/paularlott/knot/releases).

  ```bash
  brew install paularlott/tap/knot
  ```

  For **Knot Pro** , use:

  ```bash
  brew install paularlott/tap/knot-pro
  ```
  Or download from the [knot-pro releases](https://github.com/paularlott/knot-pro/releases) page.
  

  
  ### macOS Installation

  The preferred installation method for macOS is the Homebrew cask, which installs the Knot desktop app (menu bar tray) and the `knot` command:

  ```bash
  brew install --cask paularlott/tap/knot
  ```

  For **Knot Pro** , use:

  ```bash
  brew install --cask paularlott/tap/knot-pro
  ```

  If you only need the CLI, install the formula instead:

  ```bash
  brew install paularlott/tap/knot
  brew install paularlott/tap/knot-pro
  ```

  Or download the latest release from the [knot releases](https://github.com/paularlott/knot/releases) or [knot-pro releases](https://github.com/paularlott/knot-pro/releases) pages.

  **Note:** The app is not notarized with Apple, so a manually downloaded bundle may be blocked on first launch. The Homebrew cask removes the quarantine flag automatically, but for manual downloads run:

  ```shell
  sudo xattr -dr com.apple.quarantine /Applications/Knot.app
  ```
  

  
  ### Windows Installation

  The latest binary for Windows can be downloaded from [GitHub releases](https://github.com/paularlott/knot/releases). For Knot Pro , download from the [knot-pro releases](https://github.com/paularlott/knot-pro/releases) page.
  



## Desktop Mode

On macOS and Windows, running `knot` with no arguments starts **desktop mode**: the full Knot server runs in the background with a tray icon in the menu bar or notification area, and the first run opens the setup wizard automatically. See [Desktop Mode](desktop-mode.md) for the tray menu, the first-run wizard, and re-running setup.
