---
title: Stacks
weight: 75
---

Stacks let you define and manage multi-space application environments as a single unit. A stack definition is a reusable blueprint that describes which spaces make up an application, how they depend on each other, and how they are wired together with port forwarding.

---

## What is a Stack?

A stack definition is a blueprint. When you create a stack from a definition, Knot creates the individual spaces, sets their stack field, resolves dependencies, and configures port forwards. The resulting spaces are grouped under a stack name and can be started, stopped, and deleted together.

Each stack definition specifies:

- **Spaces** — which templates to use, identified by name and prefixed when created
- **Dependencies** — which spaces must be running before others can start
- **Port forwards** — how traffic is routed between spaces
- **Custom fields** — environment variables and configuration for each space

---

## Stack Lifecycle

**Define**
Create a stack definition from a TOML file. The definition is stored on the server and can be reused.

**Create**
Create spaces from a definition. Spaces are named with a prefix and grouped under a stack name. Spaces are created in a stopped state.

**Start**
Start all spaces in dependency order. Spaces that depend on others wait for their dependencies to be running first.

**Stop**
Stop all spaces in reverse dependency order. Dependent spaces are stopped before the spaces they depend on.

**Delete**
Delete all spaces in the stack. Each space and its data are permanently removed.

---

## Stack Definitions vs Stacks

| | Stack Definition | Stack |
|---|---|---|
| **What** | Blueprint (TOML) | Running spaces |
| **Created by** | `knot stack create-def` | `knot stack create` |
| **Lives in** | Database | Spaces with stack field |
| **Editable** | Yes, via `apply` | No, delete and recreate |
| **Shared** | Personal or global | Per-user spaces |

---

## CLI Commands

### Managing Definitions

| Command | Description |
|---------|-------------|
| `knot stack create-def <file>` | Create a new stack definition from a TOML file |
| `knot stack apply <file>` | Update an existing stack definition from a TOML file |
| `knot stack delete-def <name>` | Delete a stack definition |
| `knot stack enable-def <name>` | Enable a stack definition for creating stacks |
| `knot stack disable-def <name>` | Disable a stack definition |
| `knot stack list-defs` | List all stack definitions |
| `knot stack list-defs --details` | List definitions with space details |

### Managing Stacks

| Command | Description |
|---------|-------------|
| `knot stack create <definition> <prefix> [name]` | Create spaces from a definition |
| `knot stack start <name>` | Start all spaces in a stack |
| `knot stack stop <name>` | Stop all spaces in a stack |
| `knot stack restart <name>` | Restart all spaces in a stack |
| `knot stack delete <name>` | Delete a stack and all its spaces |
| `knot stack list` | List stacks and their space status |

---

## What's Next

- [Stack Definitions](definitions/) — TOML file format and options
- [Using Stacks](using-stacks/) — Creating and managing stacks from definitions
