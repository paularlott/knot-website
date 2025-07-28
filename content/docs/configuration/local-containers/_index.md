---
title: Docker & Podman
weight: 50
---

**knot** supports both Docker and Podman locally and simultaneously. This flexibility allows users to configure and use both services as needed. The socket used to communicate with each service can be specified in the **knot** configuration file.

---

## Configuration

To enable communication with Docker and Podman, the following configuration options are available:

- **`server.docker.host`**: Specifies the Docker host to communicate with.
- **`server.podman.host`**: Specifies the Podman service to communicate with.

### Example Configuration

Below is an example of how to configure the **knot** server to support both Docker and Podman:

```toml {filename="knot.toml"}
[server]
  [server.docker]
    host = "unix:///Users/demo/.colima/default/docker.sock"

  [server.podman]
    host = "unix:///var/folders/4x/840000gn/T/podman/podman-machine-default-api.sock"
```

- Replace the paths with the appropriate socket paths for your environment.
- Ensure the specified sockets are accessible and properly configured for Docker and Podman.
