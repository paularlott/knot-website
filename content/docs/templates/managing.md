---
title: Managing Templates
description: Create, edit, and delete templates, including platform, volume, resource, and access control settings.
type: Guide
tags: [templates]
weight: 10
---

## Creating a Template

To create a new template:

1. Navigate to the `Templates` page via the `Administration` menu and select `+ Template`.
2. Fill out the form presented:

{{< zoom-picture src="/docs/quick-start/local-containers/images/template-general.webp" caption="Template General Section" >}}

### Template Information

- **`Name`**:
  The name of the template, used to identify it in the system.

- **`Description`**:
  A description of the template, used to provide details about its purpose.

- **`Template Icon`**:
  Select an icon to represent the template and spaces created from it. This can be a built-in icon or a user-added icon.

---

### Platform and Job Description

- **`Platform`**:
  Choose the platform to run the template: Docker, Podman, Nomad, or Manual.
  - **Manual templates**: Require the Knot agent to be started manually on the remote server.

- **`Nomad Job (HCL)`** or **`Container Specification (YAML)`**:
  Provide the job description in either Nomad HCL or YAML format, depending on the selected platform. This field is not shown for `Manual` templates.

  Next to the label is a wand icon that opens the **template spec wizard** — a UI-driven builder that picks a base image from the [catalog](../configuration/spec-wizard/), sets memory/CPU, ports, environment variables, and bind mounts, then writes the spec for you. The wizard only enables for specs it can safely round-trip (single-task Nomad `docker` jobs, or any well-formed container spec); multi-task Nomad jobs disable the wizard with an explanatory tooltip.

---

{{< zoom-picture src="/docs/quick-start/local-containers/images/template-spec.webp" caption="Container Spec, Volumes and Ports" >}}

### Volume Definition

- **`Volume Definition (YAML)`**:
  Optionally define volumes or managed host paths to be created for the space. This field is unavailable for `Manual` templates. In `paths`, `~` resolves to the server user's home directory, absolute paths start with `/`, and relative paths are resolved from the agent working directory.

---

### Resource Allocation & Scripts

- **`System Startup Script`**:
  An optional script to run when the space starts. This field is unavailable for `Manual` templates. The script must be one defined under scripts.

- **`System Shutdown Script`**:
  An optional script to run when the space stops. This field is unavailable for `Manual` templates. The script must be one defined under scripts.

- **`Allow stopped spaces to be migrated between nodes`**:
  Available only for local-container templates (`Local Container`, `Docker`, `Podman`, and `Apple`). When enabled, a stopped space created from the template can be reassigned to a different live node from the edit space form. In Knot Pro {{< pro-badge >}}, combining node migration with auto-restart on failure enables automatic recovery from failed nodes.

- **`Compute Units`**:
  The number of compute units the space will use. This is used to calculate the cost of running the space. Set to `0` for no cost.

- **`Storage Units`**:
  The number of storage units the space will use. This is used to calculate the cost of creating the space. Set to `0` for no cost.

- **`Maximum Uptime`**:
  The maximum time a space can run. Specify the time in minutes, hours, or days.

---

### Scheduling

- **`Schedule`**:
  Define the days and times the space is allowed to run. Spaces running outside the schedule will be automatically stopped.
  - **`Auto Start`**: Automatically start a stopped space when its scheduled start time is reached.

---

### Zones and Access Control

- **`Limit to Zones`**:
  Specify the zones where the template is available. Prefix a zone name with `!` to make the template available in all zones except the specified one.

  A reserved zone name **`<leaf-node>`** is available for controlling template availability on leaf node servers:
  - **`<leaf-node>`**: The template is only shown on leaf node servers
  - **`!<leaf-node>`**: The template is excluded from leaf node servers (available only on the cluster)

---

### Custom Fields and Features

- **`Custom Fields`**:
  Add optional fields to pass additional information into a space.
  - **`Variable Name`**: The name of the variable for the field.
  - **`Field Label / Description`**: A description of the field, displayed in the space creation and edit forms.

- **`Jobs`**:
  Define scheduled or manual jobs that are copied into spaces created from the template, where each space can edit or remove its own copy. Each job has a name, a shell command and an optional 5-field cron schedule; see [Space Jobs](../spaces/jobs/).

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

{{< tip >}}
Templates with existing spaces cannot be deleted.
{{< /tip >}}

---

## Editing a Template

Editing a template is similar to creating one:

1. Select the `Edit` option from the template menu.
2. Update the template details as needed.

---

## Exporting and Importing Templates

Templates can be exported to a portable YAML format for version control, backup, or transfer between knot instances.

### Export

```bash
knot template export "Ubuntu Desktop" > ubuntu.yaml
```

The YAML file contains the full template definition: metadata, job spec (HCL/YAML), volume definitions, schedule, custom fields, feature flags, health check configuration, and space jobs (including port definitions). Template variables (`${{ .X }}`) are preserved verbatim. Scripts are referenced by name (not UUID) for portability.

### Import

```bash
# From a file
knot template import --file ubuntu.yaml

# From stdin
cat ubuntu.yaml | knot template import

# With a name override
knot template import --file ubuntu.yaml --name "Ubuntu Dev"
```

The import creates a new template on the server. Script names are resolved to IDs automatically — if a script doesn't exist on the target server, it's skipped with a warning.

### YAML format

```yaml
name: Ubuntu Desktop
description: Base Ubuntu 26.04 with dev tools
platform: nomad
icon_url: /icons/ubuntu-linux-alt.svg
active: true
compute_units: 1
features:
  with_terminal: true
  with_ssh: true
groups:
  - developers
zones:
  - zone1
max_uptime: 8
max_uptime_unit: h
startup_script: install-tools.sh
jobs:
  - name: backup
    command: knot run-script backup
    schedule: "0 2 * * *"
    enabled: true
job: |
  job "${{.space.name}}" {
    ...
  }
volumes: |
  volumes:
    - name: data
      type: csi
```

---

## What's Next

- [Nomad Templates](../nomad-templates/)
- [Local Container Templates](local-containers/)
