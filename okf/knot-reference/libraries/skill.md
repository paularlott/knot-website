---
description: Manage skills — markdown knowledge base content for AI agents.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/libraries/skill/
sources:
    - resource: https://getknot.dev/reference/libraries/skill/
status: stable
tags:
    - ai
    - scripting
    - api
title: knot.skill
type: API Reference
---
# knot.skill

The `knot.skill` library provides functions to manage skills (knowledge base content). Skills are markdown documents with YAML or TOML frontmatter that follow the [Agent Skills Specification](https://agentskills.io/specification).

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, plugin handlers, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| Health check scripts | Only when the space's environment sets `KNOT_API_PORT` or `KNOT_URL`/`KNOT_TOKEN`: there is no built-in transport, so the Python `knot.apiclient` configures itself from the agent (as the space owner) or those variables, and calls raise otherwise. See [Environment Compatibility](../libraries.md#environment-compatibility). |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

---

## Functions

| Function | Description |
|----------|-------------|
| `create(content, is_global=False, groups=None, zones=None, owner=None, active=True)` | Create a new skill — a user skill owned by `owner` (default: you) unless `is_global=True`; returns its ID |
| `get(name_or_id)` | Get a skill by name or UUID (a name resolves to your own skill first, then a global one) |
| `update(name_or_id, content=None, groups=None, zones=None, active=None)` | Update a skill; arguments left as `None` keep their current values. Returns `True` |
| `delete(name_or_id)` | Delete a skill; returns `True` |
| `list(owner=None)` | List all accessible skills, across all zones; `owner` filters by owner user ID (`"current"` for your own) |
| `search(query)` | Fuzzy search skills by name and description; returns up to 3 matches, best first, each with a `score` |

Creating another user's skill (`owner`) or a global skill needs **Manage Global Skills**. `groups` (group IDs) apply to global skills only: a user skill cannot have groups.

## Skill Properties

`list()` and `get()` return dicts with:
- `id` - Skill ID
- `name` - Skill name (from the frontmatter)
- `description` - Skill description (from the frontmatter)
- `user_id` - Owner user ID (empty for a global skill)
- `is_managed` - Whether the skill is system-managed
- `active` - Whether the skill is active
- `groups` - Group IDs a global skill is restricted to
- `zones` - Zone names
- `content` - The full markdown content (`get()` only)

`search()` returns dicts with `id`, `name`, `description`, `user_id`, `content` and `score` (0 to 1). `id` is `None` and `user_id` `""` when the matched skill cannot be fetched by name (for instance when a same-named skill shadows it).

---

## Key Concepts

- **Global Skills**: Available to all users (with group restrictions)
- **User Skills**: Personal skills owned by individual users
- **User Shadowing**: User skills with the same name override global skills
- **Zone Restrictions**: Skills can be limited to specific zones
- **Group Restrictions**: Global skills can be restricted to user groups

---

## Usage

```python
import knot.skill as skill

# Create a user skill
skill_id = skill.create("""---
name: "python-best-practices"
description: "Python coding best practices"
---

# Python Best Practices

- Follow PEP 8
- Use meaningful variable names
""")

# Create a global skill
global_id = skill.create("""---
name: "shared-practices"
description: "Shared team practices"
---
Content here.
""", is_global=True)

# List skills
skills = skill.list()
for s in skills:
    print(f"{s['name']}: {s['description']}")

# Search skills
for match in skill.search("python"):
    print(match["name"], match["score"])

# Get a skill
s = skill.get("python-best-practices")
print(s['content'])
```

---

## Frontmatter Requirements

```yaml
---
name: "my-skill"
description: "Brief description"
---
```

**Validation Rules:**
- `name`: 1-64 chars, lowercase letters/numbers/hyphens, must start with letter
- `description`: 1-1024 chars
- Content: Max 4MB total

---

## Permissions

- User skills: `MANAGE_OWN_SKILLS`
- Global skills: `MANAGE_GLOBAL_SKILLS`
