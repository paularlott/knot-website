---
title: Stack Templates
description: Stack templates bundle multiple spaces into a single deployable unit with dependencies and port forwarding.
type: Overview
tags: [stacks, templates]
weight: 75
---

Stack templates let you define and manage multi-space application environments as a single unit. A stack template is a reusable blueprint that describes which spaces make up an application, how they depend on each other, and how they are wired together with port forwarding.

> The CLI and API still use the historical name **stack definition** for these blueprints (`knot stack create-def`, the `knot.stack.create_def` function, the `stack_definition_id` field, etc.). "Stack template" and "stack definition" refer to the same thing.

---

## What is a Stack Template?

A stack template is a blueprint. When you create a stack from a template, Knot creates the individual spaces, sets their stack field, resolves dependencies, and configures port forwards. The resulting spaces are grouped under a stack name and can be started, stopped, and deleted together.

Each stack template specifies:

- **Spaces** — which templates to use, identified by name and prefixed when created
- **Dependencies** — which spaces must be running before others can start
- **Port forwards** — how traffic is routed between spaces
- **Custom fields** — environment variables and configuration for each space

---

## Stack Lifecycle

**Define**
Create a stack template from a TOML file. The template is stored on the server and can be reused.

**Create**
Create spaces from a template. Spaces are named with a prefix and grouped under a stack name. Spaces are created in a stopped state.

**Start**
Start all spaces in dependency order. Spaces that depend on others wait for their dependencies to be running first.

**Stop**
Stop all spaces in reverse dependency order. Dependent spaces are stopped before the spaces they depend on.

**Delete**
Delete all spaces in the stack. Each space and its data are permanently removed.

---

## Stack Templates vs Stacks

| | Stack Template | Stack |
|---|---|---|
| **What** | Blueprint (TOML) | Running spaces |
| **Created by** | `knot stack create-def` | `knot stack create` |
| **Lives in** | Database | Spaces with stack field |
| **Editable** | Yes, via `apply` | No, delete and recreate |
| **Shared** | Personal or global | Per-user spaces |

---

## CLI Commands

### Managing Templates

| Command | Description |
|---------|-------------|
| `knot stack create-def <file>` | Create a new stack template from a TOML file |
| `knot stack apply <file>` | Update an existing stack template from a TOML file |
| `knot stack delete-def <name>` | Delete a stack template |
| `knot stack enable-def <name>` | Enable a stack template for creating stacks |
| `knot stack disable-def <name>` | Disable a stack template |
| `knot stack list-defs` | List all stack templates |
| `knot stack list-defs --details` | List templates with space details |

### Managing Stacks

| Command | Description |
|---------|-------------|
| `knot stack create <template> <prefix> [name]` | Create spaces from a template |
| `knot stack start <name>` | Start all spaces in a stack |
| `knot stack stop <name>` | Stop all spaces in a stack |
| `knot stack restart <name>` | Restart all spaces in a stack |
| `knot stack delete <name>` | Delete a stack and all its spaces |
| `knot stack list` | List stacks and their space status |

---

## What's Next

- [Stack Template Format](definitions/) — TOML file format and options
- [Using Stacks](using-stacks/) — Creating and managing stacks from templates
