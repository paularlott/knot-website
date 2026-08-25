---
description: Custom variables are defined in templates and set per-space using the .custom prefix when creating spaces.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/variables/custom-variables/
sources:
    - resource: https://getknot.dev/docs/variables/custom-variables/
status: stable
tags:
    - variables
    - configuration
title: Custom Variables
type: Guide
---
# Custom Variables

Custom variables are defined within templates and can have values assigned to them when creating or editing a space. These variables allow for dynamic customization and are accessed using the `.custom` prefix. For example, if the variable is named `test`, it would be used in a template as `${{ .custom.test }}`.

---

### Adding Fields to a Template

Before custom variables can be created and used, fields must be added to the template:

#### Field Configuration Options

- **`Variable Name`**:
  The name of the variable.

- **`Field Label/Description`**:
  A description for the field, displayed when adding or editing a space.

---

### Setting a Custom Variable

When creating or editing a space, the fields added to the template will be displayed, allowing you to enter values for each custom variable. These values will be saved and applied to the space, enabling per-space customization based on the template's configuration.


---

## End-to-End Example

**1. Add the field to the template** — in the template form's **Custom Fields** section, add a field with variable name `branch` and a label such as `Git branch to checkout`.

**2. Use the variable in the container spec**:

```yaml
environment:
  - "CHECKOUT_BRANCH=${{ .custom.branch }}"
```

**3. Set the value when creating the space** — the field appears in the create-space form with your label; enter for example `main`.

The space's container now starts with `CHECKOUT_BRANCH=main`. Editing the space changes the value, and the space is restarted to apply it.
