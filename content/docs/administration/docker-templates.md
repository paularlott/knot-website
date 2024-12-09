---
title: Docker Templates
weight: 45
---

## Overview

Local spaces can be defined using Docker `Templates`, these templates are used to define the environment that a developer will work within and can have an optional volume definition.

When a developer creates an instance of the `Template`, a `Space`, and starts it, knot automatically creates any required volumes and launches the job in the local machine.

Local containers work with Docker or Podman running on the same machine as the knot server.

## Creating a Template

From the menu select `Templates` then `Create Template`, then check the Local Container (Docker / Podman) box.

Example docker template:

```yaml
container_name: ${{ .user.username }}-${{ .space.name }}
hostname: "${{ .space.name }}"
image: ${{.var.registry_url}}/knot-ubuntu:24.04
auth:
  username: "${{.var.registry_user}}"
  password: "${{.var.registry_pass}}"
ports:
  - 8080:80/tcp
volumes:
  - /home/example:/myhome
  - volume1:/volume1

#cap_add:
#  - CAP_AUDIT_WRITE

#command: [
#  "./knot",
#  "server"
#]

privileged: true
#network: host # or none

environment:
  - "TZ=${{.user.timezone}}"
  - "MARIADB_ROOT_PASSWORD=testing"
  - "KNOT_LOGLEVEL=debug"
  - "KNOT_SERVER=${{.server.url}}"
  - "KNOT_AGENT_ENDPOINT=${{.server.agent_endpoint}}"
  - "KNOT_SPACEID=${{.space.id}}"
  - "KNOT_SSH_PORT=22"
  - "KNOT_HTTP_PORT=80=Site"
  - "KNOT_SERVICE_PASSWORD=${{.user.service_password}}"
  - "KNOT_VNC_HTTP_PORT=5680"
  - "KNOT_CODE_SERVER_PORT=49374"
  - "KNOT_VSCODE_TUNNEL=vscodetunnel"
```

The ports section is not required if the ports will only be accessed via knot, they are only required if the ports are to be accessed directly.

Example volume definition:

```yaml
volumes:
  volume1:
```

## Deleting a Template

If a template is in use then it can't be deleted.
