---
title: Skills
weight: 30
---

The web assistant uses skills to determine how to perform specific tasks. By default, three skills are built in:

- **`nomad-spec.md`**: Explains how to create Nomad-based space templates.
- **`docker-spec.md`**: Explains how to create Docker-based space templates.
- **`podman-spec.md`**: Explains how to create Podman-based space templates.

These default skills are generic and may need to be customized for your specific environment. For example, if you use GlusterFS instead of Ceph, adjustments will be required.

---

## Replacing Skills

You can replace the default skills by setting the `server.skills_path` in the `knot.toml` configuration file. This allows you to specify a directory where custom skill files can be added.

To replace the Nomad spec, create a file named `nomad-spec.md` in the specified skills folder. The assistant will automatically start using the new file on the next request.

### Fetching Default Skills

The current versions of the default skills files can be retrieved using the `scaffold` subcommand. For example:

```bash
knot scaffold --nomad-spec
```

This command fetches the Nomad spec, which can then be used as a starting point for creating a more tailored version of the file.

---

## Creating Skills

Skills files are simple Markdown documents that instruct the LLM on how to perform a task. Each skill should include front matter to describe its contents to the LLM.

For example, the front matter for a Podman skill might look like this:

```markdown
---
title: knot Podman Job Template Specification for AI Assistants
---
```

This structure ensures the assistant understands the purpose and context of the skill.
