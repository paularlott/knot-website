---
title: knot.skill
weight: 40
---

The `knot.skill` library provides functions to manage skills (knowledge base content). Skills are markdown documents with YAML or TOML frontmatter that follow the [Agent Skills Specification](https://agentskills.io/specification).

---

## Functions

| Function | Description |
|----------|-------------|
| `create(content, global=False, groups=[], zones=[])` | Create a new skill |
| `get(name_or_id)` | Get a skill by name or UUID |
| `update(name_or_id, content=None, groups=None, zones=None)` | Update a skill |
| `delete(name_or_id)` | Delete a skill |
| `list(owner=None)` | List all accessible skills |
| `search(query)` | Search skills by name and description |

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

# List skills
skills = skill.list()
for s in skills:
    print(f"{s['name']}: {s['description']}")

# Search skills
results = skill.search("python")
print(results)

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
