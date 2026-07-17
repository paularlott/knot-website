---
title: System Variables
description: System variables are automatically provided by knot to reference space, template, user, and server details.
type: Guide
tags: [variables, configuration]
weight: 10
---

System variables are accessible in both job templates and volume templates. These variables are automatically provided by **knot** and can be used to dynamically reference information about spaces, templates, users, servers, and more.

To use a system variable, simply specify it in the format `${{ .<group>.<name> }}`. For example:
`${{ .space.name }}`

---

### Available System Variables

| **Group**    | **Name**               | **Description**                                                                 |
|--------------|------------------------|---------------------------------------------------------------------------------|
| **space**    | `space.id`             | The UUID of the space                                                          |
|              | `space.name`           | The name of the space                                                          |
|              | `space.stack`          | The name of the stack the space belongs to, empty if not part of a stack       |
|              | `space.stack_prefix`   | The prefix used when the stack was created (space names are `prefix-key`); empty if not part of a stack. Use it to reference sibling containers, e.g. `${{ .space.stack_prefix }}-db` |
|              | `space.first_boot`     | Flags if this is the first boot of the space                                   |
| **template** | `template.id`          | The UUID of the template used to create the space                              |
|              | `template.name`        | The name of the template used to create the space                              |
| **user**     | `user.id`              | The UUID of the user running the space                                         |
|              | `user.timezone`        | The timezone of the user                                                       |
|              | `user.username`        | The username of the user running the space                                     |
|              | `user.email`           | The user's email address                                                       |
|              | `user.service_password`| Service password for the user                                                  |
| **server**   | `server.url`           | The URL of the **knot** server                                                 |
|              | `server.agent_endpoint`| The endpoint agents should use to connect to the server                        |
|              | `server.wildcard_domain`| The wildcard domain without the leading `*`                                    |
|              | `server.zone`          | The server zone string                                                         |
|              | `server.timezone`      | The server timezone                                                            |
| **nomad**    | `nomad.dc`             | The Nomad datacenter the server is running in (from the `NOMAD_DC` environment variable) |
|              | `nomad.region`         | The Nomad region the server is running in (from the `NOMAD_REGION` environment variable) |

---

### Stack Variables

When a space is part of a [stack](../stacks/), it can reference variables belonging to any **sibling space** in the same stack via the `.stack` group. This lets one space consume values produced by another — for example, a web space reading a database password defined on a `db` space.

The syntax is:

```
${{ .stack.<key>.<group>.<name> }}
```

where `<key>` is the sibling's **stack key** — its space name with the stack prefix removed (the same key used in the stack definition for `depends_on` and port forwards). For a stack with prefix `myapp`, a space named `myapp-db` is referenced as `db`.

`.stack.<key>` exposes the same variable groups as the current space, resolved for that sibling:

- `${{ .stack.db.space.id }}` — the sibling's space UUID
- `${{ .stack.db.space.name }}` — the sibling's full space name
- `${{ .stack.db.custom.password }}` — a custom variable defined on the sibling
- `${{ .stack.db.template.name }}`, `${{ .stack.db.user.username }}`, etc.

**Example** — a `web` space wiring up a connection to a `db` space in the same stack:

```yaml
environment:
  - "DB_HOST=${{ .space.stack_prefix }}-db"
  - "DB_PASSWORD=${{ .stack.db.custom.password }}"
```

**Keys containing hyphens** — Go templates treat `-` as subtraction, so `.stack.my-db` won't parse. Each sibling is therefore exposed under **two equivalent keys**: the literal key (for `index`) and a dotted-safe alias with `-` replaced by `_` (for dotted access). Pick whichever you prefer:

```
${{ .stack.my_db.custom.password }}              # dotted, using the _ alias
${{ (index .stack "my-db").custom.password }}    # index, using the literal key
```

The dotted path *after* the key (`.custom.password`, `.space.id`) works as normal in either form.

**Quoting inside YAML/HCL values** — only the `index` form has inner double quotes, which collide with a YAML double-quoted value. If you use `index` inside a quoted value, switch the surrounding YAML string to single quotes (or escape the inner quotes):

```yaml
environment:
  - 'DB_PASSWORD=${{ (index .stack "my-db").custom.password }}'
```

The dotted `_` form has no inner quotes, so it needs no special handling.

**Note:** `.stack.<key>` only resolves if the sibling space has already been created. Stacks created the normal way (`knot stack create` then `knot stack start`) create every space before any of them start, so sibling references resolve in both directions. If a sibling does not yet exist, the reference renders as `<no value>` (the standard fallback for a missing variable).

---

## What's Next

- [User Defined Variables](../user-defined-variables/)
