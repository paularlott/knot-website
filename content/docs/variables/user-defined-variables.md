---
title: User Defined Variables
weight: 20
---

User-defined variables can be created through the **knot** web interface and are available for use in both job and volume templates. These variables provide flexibility and customization for your templates.

To use a user-defined variable, prefix its name with `.var.`. For example, if the variable is named `myvariable`, it should be used in a template as `${{ .var.myvariable }}`.

---

## Protected Variables

When creating or editing a variable, the `Protected` option can be selected. Protected variables are stored encrypted in the database. However, they are decrypted before being used in templates, meaning their values may be exposed within job definitions.

{{< tip "warning" >}}
Protected variables are secure in storage but may be visible in job definitions when used in templates.
{{< /tip >}}

---

## Creating a Variable

To create a new variable:

1. Log in to the **knot** web interface.
2. Click `Variables` and then select `New Variable`.
   {{< picture src="../images/variable-form.webp" caption="Create Variable Form" >}}

### Variable Configuration Options

- **`Name`**:
  The name of the variable.

- **`Value`**:
  The text value to assign to the variable.

- **`Limit to Zones`**:
  A list of zones where the variable can be used. If a zone name is prefixed with `!`, the variable will be available in all zones except the specified one.

- **`Protected`**:
  If checked, the variable's value is stored encrypted. When editing the variable, the value will not be displayed.

- **`Restricted`**:
  If checked, the variable is only shared between servers within a cluster and is never shared with a leaf node.

- **`Local Variable`**:
  If checked, the variable is only available on the **knot** server where it was created.

3. Once the form is completed, click `Create Variable`.

---

## Deleting a Variable

To delete a variable:

1. Click the menu item next to the variable.
2. Select `Delete`.
3. Confirm the action when prompted.
   {{< picture src="../images/delete-variable.webp" caption="Delete Variable" >}}

---

## Editing a Variable

To edit a variable:

1. Click the menu item next to the variable.
2. Select `Edit`.
3. The variable edit form will be displayed, pre-filled with the existing data. For `Protected` variables, the value field will be blank.

---

## What's Next

- [Custom Variables](../custom-variables/)
