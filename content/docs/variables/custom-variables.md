---
title: Custom Variables
description: Custom variables are defined in templates and set per-space using the .custom prefix when creating spaces.
type: Guide
tags: [variables, configuration]
weight: 30
---

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
