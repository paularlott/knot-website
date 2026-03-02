---
title: Skills
weight: 30
---

Skills are knowledge base content for AI assistants. They are markdown documents with YAML or TOML frontmatter that follow the [Agent Skills Specification](https://agentskills.io/specification).

---

## Overview

Skills provide context and instructions to AI assistants, helping them understand how to perform specific tasks. Knot supports two types of skills:

- **Global Skills**: Available to all users (with optional group restrictions)
- **User Skills**: Personal skills owned by individual users

User skills with the same name override (shadow) global skills, allowing users to customize behavior.

---

## Default Skills

The web assistant includes default skills for creating space templates:

- **`nomad-spec`**: Explains how to create Nomad-based space templates
- **`docker-spec`**: Explains how to create Docker-based space templates
- **`podman-spec`**: Explains how to create Podman-based space templates

These default skills are generic and may need to be customized for your specific environment.

---

## Managing Skills

### Via Web Interface

Skills can be created and managed through the web interface under the Skills section. The editor supports:

- Markdown content with syntax highlighting
- YAML frontmatter editing
- Zone and group access control

### Via CLI

```bash
# List skills
knot skills list

# Create a skill
knot skills create my-skill.md

# Get a skill
knot skills get my-skill

# Update a skill
knot skills update my-skill --file updated.md

# Delete a skill
knot skills delete my-skill
```

### Via Scripts

```python
import knot.skill as skill

# Create a skill
skill.create("""---
name: "python-best-practices"
description: "Python coding best practices"
---

# Python Best Practices

- Follow PEP 8
- Use meaningful variable names
""")

# List skills
skills = skill.list()

# Search skills
results = skill.search("python")
```

---

## Skill Format

Skills are markdown documents with YAML frontmatter:

```markdown
---
name: "my-skill"
description: "Brief description of what this skill does"
---

# Skill Content

Your markdown content here...
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill name (1-64 chars, lowercase letters/numbers/hyphens) |
| `description` | Yes | Brief description (1-1024 chars) |

---

## Access Control

### Zone Restrictions

Skills can be limited to specific zones:

```python
skill.create(content, zones=["us-east-1", "eu-west-1"])
```

### Group Restrictions

Global skills can be restricted to specific user groups:

```python
skill.create(content, global=True, groups=["dev-team", "ops-team"])
```

---

## Permissions

- `MANAGE_OWN_SKILLS`: Create, update, and delete your own skills
- `MANAGE_GLOBAL_SKILLS`: Create, update, and delete global skills

---

## Legacy File-Based Skills

For backwards compatibility, skills can still be loaded from files by setting `server.skills_path` in `knot.toml`. However, database-stored skills are recommended for better management and access control.

To fetch default skill files:

```bash
knot scaffold --nomad-spec
```
