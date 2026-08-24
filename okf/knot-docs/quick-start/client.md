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

On macOS and Windows, running `knot` with no arguments starts **desktop mode**: the full knot server runs in the background and a tray icon appears in the menu bar (or notification area). The tray menu provides:

- **Open knot UI** — opens the web interface in your default browser.
- **Quit** — stops the server.

Closing the browser does not stop the server; environments keep running until you quit from the tray or press Ctrl-C. To run the server headless without the tray, use `knot server`.

### First-run setup

On first launch (no `knot.toml` found, or a config with no database configured), desktop mode opens a **setup wizard** instead of the server. The wizard guides you through storage, addresses, and features, pre-filled with sensible local defaults and with any values from an existing partial config. It writes the result to `~/.knot/knot.toml`, then asks you to quit and reopen Knot so the new configuration is loaded.

The wizard's **Desktop / Leaf Mode** preset defaults to embedded storage at `~/.knot/data/`, serves the web UI over plain HTTP on loopback, advertises the agent listener and endpoint as `${{ host_ip }}:3010` — a template resolved to your machine's IP address on every start, so agents running in containers can reach the server — and enables the built-in DNS server with `knot.internal` and `*.knot.internal` records pointing at the host, the wildcard domain set to `*.knot.internal`, and the DNS listener bound to `${{ host_ip }}:3053` (agents forward DNS queries directly to it from their containers, so a loopback bind would be unreachable). The wizard also offers an optional **origin server** — connect to an existing knot cluster and sync templates and users from it by providing the origin URL and an access token; leave blank to run standalone. You can use the `${{ host_ip }}` template in your own configuration files (including DNS listen addresses and record values) too; any spacing inside the delimiters works. Like template variables, it uses `${{ }}` delimiters to avoid clashing with Nomad's interpolation.

### Re-running setup

While the server is running, the setup wizard is also available at **`/setup`** (linked from the tray menu as **Setup**). It requires an admin login, pre-fills every field from the current configuration, and saving updates `~/.knot/knot.toml` — the running server keeps its current settings until you quit and reopen Knot.


The **Knot Pro**  client works with both Pro and open-source Knot servers. You only need the Pro client if you want to use Pro features like OAuth authentication.
