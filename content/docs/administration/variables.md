---
title: Variables
weight: 20
---

## User Defined Variables

User-defined variables can be created through the web interface. These variables are then made available for use in both job and volume templates.

To use a user-defined variable, for example `myvariable`, it must be prefixed with `.var.`. Therefore, the correct usage within a template would be `${{ .var.myvariable }}`.

When creating or editing a variable the `Protected` option can be selected. If a variable is marked as protected then when editing the variable the value isn't loaded back into the browser. Protected variables are stored encrypted in the database but are decrypted before being used in templates therefore their values my be exposed within the Nomad job definitions.

## System Variables

System variables are accessible for both job templates and volume templates.

To make use of a system variable it simply needs to specified, for example, `${{ .space.name }}`.

## Available Variables

| Group | Name | Description |
| --- | --- | --- |
| space | | |
| | space.id | The UUID of the space |
| | space.name | The name of the space |
| template | | |
| | template.id | The UUID of the template used to create the space |
| | template.name | The name of the template used to create the space |
| user | | |
| | user.id | The UUID of the user running the space |
| | user.timezone | The timzone of the user |
| | user.username | The username of the user running the space |
| | user.email | The users email address |
| | user.servicePassword | Service password for the user |
| server | | |
| | server.url | The URL of the knot server |
| | server.agent_url | The URL of the knot server that agents should use |
