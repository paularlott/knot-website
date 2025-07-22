---
title: Custom Variables
weight: 30
---

Custom variables are defined within templates and can have values assigned to them when creating or editing a space. These variables allow for dynamic customization and are accessed using the `.custom` prefix. For example, if the variable is named `test`, it would be used in a template as `${{ .custom.test }}`.

---

### Adding Fields to a Template

Before custom variables can be created and used, fields must be added to the template:

{{< picture src="../images/template-define-fields.webp" caption="Adding Fields to a Template" >}}

#### Field Configuration Options

- **`Variable Name`**:
  The name of the variable.

- **`Field Label/Description`**:
  A description for the field, displayed when adding or editing a space.

---

### Setting a Custom Variable

When creating or editing a space, the fields added to the template will be displayed, allowing you to enter values for each custom variable:

{{< picture src="../images/set-custom-variable.webp" caption="Setting the Value of a Custom Variable" >}}

Once the space is saved, the values for the custom variables will also be saved and applied.
