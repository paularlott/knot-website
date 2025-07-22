---
title: Managing Template
weight: 10
---

## Creating a Template

To create a new template:

1. Navigate to the `Templates` menu and select `New Template`.
2. Fill out the form presented:

### Template Information

{{< picture src="../images/template-info.webp" caption="Template Info" >}}

- **`Name`**:
  The name of the template, used to identify it in the system.

- **`Description`**:
  A description of the template, used to provide details about its purpose.

- **`Template Icon`**:
  Select an icon to represent the template and spaces created from it. This can be a built-in icon or a user-added icon.

---

### Platform and Job Description

{{< picture src="../images/template-platform.webp" caption="Template Platform" >}}

- **`Platform`**:
  Choose the platform to run the template: Docker, Podman, Nomad, or Manual.
  - **Manual templates**: Require the **knot** agent to be started manually on the remote server.

- **`Nomad Job (HCL)`** or **`Container Specification (YAML)`**:
  Provide the job description in either Nomad HCL or YAML format, depending on the selected platform. This field is not shown for `Manual` templates.

---

### Volume Definition

{{< picture src="../images/template-volumedef.webp" caption="Template Volume Definition" >}}

- **`Volume Definition (YAML)`**:
  Optionally define a list of volumes to be created for the space. This field is unavailable for `Manual` templates.

---

### Resource Allocation

{{< picture src="../images/template-resources.webp" caption="Template Resources" >}}

- **`Compute Units`**:
  The number of compute units the space will use. This is used to calculate the cost of running the space. Set to `0` for no cost.

- **`Storage Units`**:
  The number of storage units the space will use. This is used to calculate the cost of creating the space. Set to `0` for no cost.

- **`Maximum Uptime`**:
  The maximum time a space can run. Specify the time in minutes, hours, or days.

---

### Scheduling

{{< picture src="../images/template-schedule.webp" caption="Template Schedule" >}}

- **`Schedule`**:
  Define the days and times the space is allowed to run. Spaces running outside the schedule will be automatically stopped.
  - **`Auto Start`**: Automatically start a stopped space when its scheduled start time is reached.

---

### Zones and Access Control

{{< picture src="../images/template-zones.webp" caption="Template Zones" >}}

- **`Limit to Zones`**:
  Specify the zones where the template is available. Prefix a zone name with `!` to make the template available in all zones except the specified one.

---

### Custom Fields and Features

{{< picture src="../images/template-fields-features.webp" caption="Custom Fields and Features" >}}

- **`Custom Fields`**:
  Add optional fields to pass additional information into a space.
  - **`Variable Name`**: The name of the variable for the field.
  - **`Field Label / Description`**: A description of the field, displayed in the space creation and edit forms.

- **`Features`**:
  Define the features available to the space (e.g., Visual Studio Code Tunnels). Users require the appropriate role permissions to access these features.

- **`Restrict to Groups`**:
  Specify the groups that can access the template. Only users in these groups can see the template and create spaces from it.

- **`Active`**:
  If unchecked, disables the template, preventing new spaces from being created from it.

---

## Deleting a Template

To delete a template:

1. Select the menu item next to the template.
2. Click `Delete` to open a confirmation dialog.
3. Confirm the action to remove the template.

{{< picture src="../images/template-delete.webp" caption="Delete Template" >}}

{{< tip >}}
Templates with existing spaces cannot be deleted.
{{< /tip >}}

---

## Editing a Template

Editing a template is similar to creating one:

1. Select the `Edit` option from the template menu.
2. Update the template details as needed.

---

## What's Next

- [Nomad Templates](../nomad-templates/)
- [Docker / Podman Templates](../docker-templates/)
