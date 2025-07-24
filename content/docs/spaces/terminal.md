---
title: Web Based Terminal
weight: 30
---

The web-based terminal in **knot** provides users with shell access to their spaces directly from a browser. This feature is accessible from the `Spaces` page and offers a seamless way to interact with running spaces.

---

## Accessing the Web Terminal

1. Navigate to the `Spaces` page.
2. Click the **`Terminal`** icon (#1) next to the running space.
   {{< picture src="../images/running-space.webp" caption="Running Space" >}}

3. A new browser window will open, displaying the web-based terminal.
   {{< picture src="../images/web-terminal.webp" caption="Web Based Terminal" >}}

---

## Terminal Behavior

- The terminal will attempt to use the shell specified in the space configuration.
- If the specified shell is unavailable within the container, the **knot** agent will search for an alternative shell in the following order:
  1. `bash`
  2. `zsh`
  3. `fish`
  4. `sh`

- Closing the browser window will close the terminal session.

---

## Permissions

To use the web terminal, the user must have a role with the `Use Web Terminal` permission.
