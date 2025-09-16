---
title: Recipes
weight: 30
---

The web assistant uses recipes to determine how to perform specific tasks. By default, three recipes are built in:

- **`nomad-spec.md`**: Explains how to create Nomad-based space templates.
- **`docker-spec.md`**: Explains how to create Docker-based space templates.
- **`podman-spec.md`**: Explains how to create Podman-based space templates.

These default recipes are generic and may need to be customized for your specific environment. For example, if you use GlusterFS instead of Ceph, adjustments will be required.

---

## Replacing Recipes

You can replace the default recipes by setting the `server.recipes_path` in the `knot.toml` configuration file. This allows you to specify a directory where custom recipe files can be added.

To replace the Nomad spec, create a file named `nomad-spec.md` in the specified recipe folder. The assistant will automatically start using the new file on the next request.

### Fetching Default Recipes

The current versions of the default recipe files can be retrieved using the `scaffold` subcommand. For example:

```bash
knot scaffold --nomad-spec
```

This command fetches the Nomad spec, which can then be used as a starting point for creating a more tailored version of the file.

---

## Creating Recipes

Recipe files are simple Markdown documents that instruct the LLM on how to perform a task. Each recipe should include front matter to describe its contents to the LLM.

For example, the front matter for a Podman recipe might look like this:

```markdown
---
title: knot Podman Job Template Specification for AI Assistants
---
```

This structure ensures the assistant understands the purpose and context of the recipe.
