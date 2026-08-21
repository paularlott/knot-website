---
description: Control a running space from within the space using knot agent commands like shutdown and restart.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/spaces/agent-commands/
sources:
    - resource: https://getknot.dev/docs/spaces/agent-commands/
status: stable
tags:
    - spaces
    - scripting
title: Agent Commands
type: Guide
---
# Agent Commands

Within a space, the **knot** agent provides commands to control the space. These commands include:
- [`set-note`](notes.md)
- `shutdown`
- `restart`

---

### `shutdown` Command

The `shutdown` command allows the space to request an immediate shutdown. To execute this command, run:

```shell
knot agent shutdown
```

---

### `restart` Command

The `restart` command allows the space to request a restart. To execute this command, run:

```shell
knot agent restart
```
