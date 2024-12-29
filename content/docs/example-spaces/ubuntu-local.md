---
title: Ubuntu Local Container
weight: 80
---

The following defines a simple Ubuntu 24.04 space with a volume attached to the home directory. The space deploys to the local server using Docker or Podman rather than Nomad.

When creating the template check the `Local Container` option.

```yaml {filename=Container-Specification}
container_name: ${{ .user.username }}-${{ .space.name }}
hostname: "${{ .space.name }}"
image: paularlott/knot-ubuntu:24.04
#ports:
#  - 8080:80/tcp
volumes:
  - ubuntu_${{.space.id}}_home:/home/

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
  - "KNOT_LOGLEVEL=info"
  - "KNOT_SERVER=${{.server.url}}"
  - "KNOT_AGENT_ENDPOINT=${{.server.agent_endpoint}}"
  - "KNOT_SPACEID=${{.space.id}}"
  - "KNOT_USER=${{.user.username}}"
  - "KNOT_HTTP_PORT=80=Site"
  - "KNOT_SERVICE_PASSWORD=${{.user.service_password}}"
```

```yaml {filename=Volume-Definition}
volumes:
  ubuntu_${{.space.id}}_home:
```

## Startup Scripts

During the startup of the container any scripts found in the `/etc/knot-startup.d/` directory are executed as root, then any scripts in the `.knot-startup.d/` directory within the users home directory are executed as the user.

This allows for both system level and user specific scripts to be started.
