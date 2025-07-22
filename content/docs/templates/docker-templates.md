---
title: Docker / Podman
weight: 30
---

Local spaces in **knot** can be defined using Docker or Podman templates. These templates specify the environment users will work within and can include optional volume definitions.

When a user creates an instance of a `Template` (a `Space`) and starts it, **knot** automatically provisions any required volumes and launches the container on the local machine. Local containers operate with Docker or Podman running on the same machine as the **knot** server.

---

### Container Specification

To create a Docker or Podman template:

1. Navigate to `Templates` and select `New Template`.
2. Complete the form, selecting `Docker` or `Podman` under the `Platform` option.
3. Fill out the `Container Specification` field with the container configuration.

{{< picture src="../images/template-docker.webp" caption="Docker Template" >}}

#### Example Container Specification

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

#cap_drop:
#  - CAP_MKNOD

#devices:
#  - "/dev/ttyUSB0:/dev/ttyUSB0"

#command: [
#  "./knot",
#  "server"
#]

privileged: true
#network: host # or none

environment:
  - "TZ=${{.user.timezone}}"
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
  - "KNOT_USER=${{.user.username}}"
```

#### Notes:

- **Ports**:
  The `ports` section is optional. It is only required if the ports need to be accessed directly, rather than through **knot**.

- **Environment Variables**:
  Environment variables can be used to pass dynamic information, such as user details, server URLs, and space-specific configurations.

---

### Volumes

Templates can define volumes to persist data for spaces. These volumes are created when the space is deployed and destroyed when the space is deleted. Starting and stopping the space does not affect the contents of the volumes unless the template is modified to remove a volume.

#### Example Volume Definition

```yaml
volumes:
  volume1:
```
