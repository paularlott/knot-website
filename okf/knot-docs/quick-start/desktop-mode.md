---
description: Run Knot on your desktop as a tray application — the full server with a system tray icon and a first-run setup wizard.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/quick-start/desktop-mode/
sources:
    - resource: https://getknot.dev/docs/quick-start/desktop-mode/
status: stable
tags:
    - server
    - configuration
title: Desktop Mode
type: Overview
---
# Desktop Mode

On a standard build, running `knot` with no subcommand starts the full server together with a system tray icon. This is desktop mode: the same server as [`knot server`](../../knot-reference/cli/knot.md#knot-server), plus the tray and a browser-based first-run wizard. It is the simplest way to run Knot on a laptop or desktop.

```shell
knot
```

---

## First run: the setup wizard

If no configuration file is found — or the config enables no database backend — desktop mode serves the setup wizard instead of the server. The wizard runs on `127.0.0.1:3000` (reusing the port from the configured URL if one is set) and opens from the tray's **Open knot setup** menu item.



The wizard is pre-filled from any existing config and writes a complete `knot.toml` to `~/.knot/knot.toml`, validating required fields on save. After saving, it notifies you to quit Knot from the tray menu and reopen it so the new configuration is loaded cleanly. On the next start, the server runs directly. See the [Config Wizard](config-wizard.md) page for what each wizard step covers.

The wizard's **Desktop / Leaf Mode** preset defaults to embedded storage at `~/.knot/data/`, serves the web UI over plain HTTP on loopback, advertises the agent listener and endpoint as `${{ host_ip }}:3010` — a template resolved to your machine's IP address on every start, so agents running in containers can reach the server — and enables the built-in DNS server with `knot.internal` and `*.knot.internal` records pointing at the host, the wildcard domain set to `*.knot.internal`, and the DNS listener bound to `${{ host_ip }}:3053` (agents forward DNS queries directly to it from their containers, so a loopback bind would be unreachable). The wizard also offers an optional **origin server** — connect to an existing knot cluster and sync templates and users from it by providing the origin URL and an access token; leave blank to run standalone. You can use the `${{ host_ip }}` template in your own configuration files (including DNS listen addresses and record values) too; any spacing inside the delimiters works. Like template variables, it uses `${{ }}` delimiters to avoid clashing with Nomad's interpolation.

---

## Re-running setup

While the server is running, the setup wizard is also available at **`/setup`** (linked from the tray menu as **Setup**). It requires an admin login, pre-fills every field from the current configuration, and saving updates `~/.knot/knot.toml` — the running server keeps its current settings until you quit and reopen Knot.

---

## The tray menu

| Item | Action |
| ---- | ------ |
| **Open knot UI** | Open the web interface in your default browser |
| **Setup** | Open the setup wizard (while first-run setup is pending) |
| **Quit** | Shut the server down and exit |

The tray icon is monochrome and adapts to your menu bar or taskbar theme: a template icon on macOS, a theme-aware icon on Windows, and the light variant on Linux panels.

If no system tray is available (for example a headless Linux session), desktop mode falls back to running the server headless: it prints the URL to open and keeps running until Ctrl-C.

---

## Windows behaviour

On Windows, a bare `knot` relaunches itself with no console window, so the tray is not accompanied by a terminal. All subcommands (`knot server`, `knot space list`, ...) keep their normal console behaviour.


The **Knot Pro**  client works with both Pro and open-source Knot servers. You only need the Pro client if you want to use Pro features like OAuth authentication.
