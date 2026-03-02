---
title: Skills
weight: 30
---

Skills are knowledge base content for AI assistants. They are markdown documents with YAML or TOML frontmatter that follow the [Agent Skills Specification](https://agentskills.io/specification).

---

## Overview

Skills provide context and instructions to AI assistants, helping them understand how to perform specific tasks. Skills can be used by:

- The built-in **knot** web assistant
- External AI tools that connect via MCP
- Any AI system that supports the Agent Skills format

Knot supports two types of skills:

- **Global Skills**: Available to all users (with optional group restrictions)
- **User Skills**: Personal skills owned by individual users

User skills with the same name override (shadow) global skills, allowing users to customize behavior.

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

- If no zones are specified, the skill is available in all zones
- Zones prefixed with `!` are exclusions (e.g., `!us-west-1` excludes that zone)

```python
skill.create(content, zones=["us-east-1", "eu-west-1"])
```

### Group Restrictions

Global skills can be restricted to specific user groups. Only users in those groups can access the skill.

```python
skill.create(content, global=True, groups=["dev-team", "ops-team"])
```

---

## Permissions

| Permission | Description |
|------------|-------------|
| `MANAGE_OWN_SKILLS` | Create, update, and delete your own skills |
| `MANAGE_GLOBAL_SKILLS` | Create, update, and delete global skills |

---

## Example Skills

### Team Conventions

```markdown
---
name: "team-conventions"
description: "Coding conventions and best practices for our team"
---

# Team Conventions

## Branch Naming
- Feature: `feature/<ticket-id>-<description>`
- Bugfix: `fix/<ticket-id>-<description>`
- Hotfix: `hotfix/<ticket-id>-<description>`

## Commit Messages
- Use conventional commits format
- Reference ticket numbers in commit messages

## Code Review
- All changes require at least one approval
- Reviewers should check for test coverage
```

### Deployment Guide

```markdown
---
name: "deployment-guide"
description: "How to deploy applications to our environments"
---

# Deployment Guide

## Environments
- **dev**: Automatic deployment on merge to develop
- **staging**: Manual approval required
- **production**: Requires two approvals and change ticket

## Deployment Process
1. Create a release branch from main
2. Update version numbers
3. Run full test suite
4. Create pull request
5. After approval, merge to main
6. Tag the release
```

---

## What's Next

- [AI Assistant](../ai-assistant/) - Using the built-in AI assistant
- [MCP Integration](../mcp/) - Connecting external AI tools
- [Scripts](../../scripts/) - Creating executable automation scripts
