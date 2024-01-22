---
title: System Variables
weight: 10
---

System variable are made available to job templates as well as volume templates.

To use a variable simply specify the variable e.g. `${{ .space.name }}`.

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
| | user.username | The username of the user running the space |
| server | | |
| | server.url | The URL of the knot server |
