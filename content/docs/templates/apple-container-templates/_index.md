---
title: Apple Container
weight: 40
---

Local spaces in **knot** can be defined using Apple Container templates. These templates specify the environment users will work within and can include optional volume definitions.

When a user creates an instance of a `Template` (a `Space`) and starts it, **knot** automatically provisions any required volumes and launches the container on the local machine using the macOS container CLI. Apple containers operate with the macOS container CLI running on the same machine as the **knot** server.

---

### Container Specification

To create an Apple Container template:

1. Navigate to `Templates` and select `New Template`.
2. Complete the form, selecting `Apple Container` under the `Platform` option.
3. Fill out the `Container Specification` field with the container configuration.

#### Example Container Specification

```yaml
container_name: ${{ .user.username }}-${{ .space.name }}
hostname: "${{ .space.name }}"
image: registry-1.docker.io/knot-ubuntu:24.04
ports:
  - 8080:80/tcp
volumes:
  - /home/example:/myhome
  - ${{.space.id}}-volume1:/volume1
network: bridge
environment:
  - "TZ=${{.user.timezone}}"
  - "KNOT_USER=${{.user.username}}"
  - "KNOT_SERVER=${{.server.url}}"
  - "KNOT_AGENT_ENDPOINT=${{.server.agent_endpoint}}"
  - "KNOT_SPACEID=${{.space.id}}"
  - "KNOT_SSH_PORT=22"
  - "KNOT_HTTP_PORT=80=Site"
  - "KNOT_SERVICE_PASSWORD=${{.user.service_password}}"
  - "KNOT_VNC_HTTP_PORT=5680"
  - "KNOT_CODE_SERVER_PORT=49374"
  - "KNOT_VSCODE_TUNNEL=vscodetunnel"
dns:
  - 8.8.8.8
dns_search:
  - example.com
command: [
  "./knot",
  "server"
]
```

#### Apple Container Limitations

Apple containers use the macOS container CLI and have a simplified feature set compared to Docker/Podman:

- **No privileged mode support**: Advanced security features like privileged containers are not available
- **No capabilities management**: `cap_add` and `cap_drop` are not supported
- **No device mappings**: Direct device access through containers is not supported
- **No custom host entries**: `add_host` functionality is not available
- **No registry authentication**: Registry authentication is not currently supported by the Apple container CLI

#### Using Template Variables

Template variables can store sensitive information or information that may need to be updated in all templates. For example:

```yaml
image: ${{.var.registry_url}}/knot-ubuntu:24.04
```

#### Notes:

- **Image Registry**: If the container image doesn't include a domain name, it will be automatically prefixed with `registry-1.docker.io`
- **Ports**: The `ports` section is optional. It is only required if the ports need to be accessed directly, rather than through **knot**
- **Environment Variables**: Environment variables can be used to pass dynamic information, such as user details, server URLs, and space-specific configurations
- **Required Environment Variables**: Every Apple Container template must include the four mandatory KNOT_ environment variables: `KNOT_USER`, `KNOT_SERVER`, `KNOT_AGENT_ENDPOINT`, and `KNOT_SPACEID`

---

### Volumes

Templates can define volumes to persist data for spaces. These volumes are created when the space is deployed and destroyed when the space is deleted. Starting and stopping the space does not affect the contents of the volumes unless the template is modified to remove a volume.

#### Example Volume Definition

```yaml
volumes:
  ${{.space.id}}-volume1:
  ${{.space.id}}-data:
```

Volume names must follow the format `${{.space.id}}-<purpose>` to ensure uniqueness across spaces.