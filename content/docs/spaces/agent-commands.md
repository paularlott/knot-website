---
title: Agent Commands
description: Control a running space from within the space using knot agent commands like shutdown and restart.
type: Guide
tags: [spaces, scripting]
weight: 150
---

Within a space, the **knot** agent provides commands to control the space. These commands include:
- [`set-note`](../notes/)
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
