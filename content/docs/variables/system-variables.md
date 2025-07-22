---
title: System Variables
weight: 10
---

System variables are accessible in both job templates and volume templates. These variables are automatically provided by **knot** and can be used to dynamically reference information about spaces, templates, users, servers, and more.

To use a system variable, simply specify it in the format `${{ .<group>.<name> }}`. For example:
`${{ .space.name }}`

---

### Available System Variables

| **Group**    | **Name**               | **Description**                                                                 |
|--------------|------------------------|---------------------------------------------------------------------------------|
| **space**    | `space.id`             | The UUID of the space                                                          |
|              | `space.name`           | The name of the space                                                          |
|              | `space.first_boot`     | Flags if this is the first boot of the space                                   |
| **template** | `template.id`          | The UUID of the template used to create the space                              |
|              | `template.name`        | The name of the template used to create the space                              |
| **user**     | `user.id`              | The UUID of the user running the space                                         |
|              | `user.timezone`        | The timezone of the user                                                       |
|              | `user.username`        | The username of the user running the space                                     |
|              | `user.email`           | The user's email address                                                       |
|              | `user.service_password`| Service password for the user                                                  |
| **server**   | `server.url`           | The URL of the **knot** server                                                 |
|              | `server.agent_endpoint`| The endpoint agents should use to connect to the server                        |
|              | `server.wildcard_domain`| The wildcard domain without the leading `*`                                    |
|              | `server.zone`          | The server zone string                                                         |
|              | `server.timezone`      | The server timezone                                                            |
| **nomad**    | `nomad.dc`             | The Nomad datacenter the server is running in (from the `NOMAD_DC` environment variable) |
|              | `nomad.region`         | The Nomad region the server is running in (from the `NOMAD_REGION` environment variable) |

---

## What's Next

- [User Defined Variables](../user-defined-variables/)
