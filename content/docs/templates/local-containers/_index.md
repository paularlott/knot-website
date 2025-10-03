---
title: Local Containers
weight: 30
---

Local spaces in **knot** can be defined using Local Container templates, which support Docker, Podman, and Apple Container runtimes. These templates specify the environment users will work within and can include optional volume definitions.

When a user creates an instance of a `Template` (a `Space`) and starts it, **knot** automatically provisions any required volumes and launches the container on the local machine.

---

### Runtime Selection

When creating a template, you can specify the container runtime:

- **Local Container** (default): Automatically selects an available runtime based on preference order
- **Docker**: Explicitly uses Docker
- **Podman**: Explicitly uses Podman
- **Apple Container**: Explicitly uses Apple Container (macOS only)

#### Automatic Runtime Selection

When set to **Local Container**, **knot** will attempt to use container runtimes in the following default order:

1. Docker
2. Podman
3. Apple Container

This order can be customized in the server configuration:

```toml
[server.local_containers]
runtime_pref = ["podman", "apple"]
```

The above example configures **knot** to prefer Podman first, then Apple Container.

---

### Container Specification

To create a Local Container template:

1. Navigate to `Templates` and select `New Template`.
2. Complete the form, selecting `Local Container` (or a specific runtime) under the `Platform` option.
3. Fill out the `Container Specification` field with the container configuration.

{{< picture src="../images/template-docker.webp" caption="Local Container Template" >}}

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

#### Runtime-Specific Considerations

**Docker and Podman**:
- Support all features shown in the example above
- Podman requires fully qualified image names (e.g., `registry-1.docker.io/image:tag`)

**Apple Container**:
- Does not support: `privileged`, `cap_add`, `cap_drop`, `devices`, `add_host`
- Does not support registry authentication (`auth`)
- Image names without a domain are automatically prefixed with `registry-1.docker.io`

#### Using Template Variables

Template variables can store sensitive information or information that may need to be updated in all templates, such as registry login credentials. For example:

```yaml
image: ${{.var.registry_url}}/knot-ubuntu:24.04
auth:
  username: "${{.var.registry_user}}"
  password: "${{.var.registry_pass}}"
```

#### Notes:

- **Ports**: The `ports` section is optional. It is only required if the ports need to be accessed directly, rather than through **knot**.
- **Environment Variables**: Environment variables can be used to pass dynamic information, such as user details, server URLs, and space-specific configurations.

---

### Volumes

Templates can define volumes to persist data for spaces. These volumes are created when the space is deployed and destroyed when the space is deleted. Starting and stopping the space does not affect the contents of the volumes unless the template is modified to remove a volume.

#### Example Volume Definition

```yaml
volumes:
  volume1:
```
