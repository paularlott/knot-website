---
title: Container Runtimes
weight: 50
---

**knot** supports Docker, Podman, and Apple Containers (on macOS) locally and simultaneously. This flexibility allows you to configure and use multiple container runtimes as needed. The socket used to communicate with each service can be specified in the **knot** configuration file.

---

## Supported Runtimes

### Docker
The most common container runtime, widely supported across different platforms.

### Podman
A daemonless container engine that is compatible with Docker but offers enhanced security features.

### Apple Containers (macOS only)
Native macOS container runtime available on Apple Silicon machines. This uses the built-in macOS containerization technology.

---

## Runtime Detection

**knot** automatically detects which container runtimes are available on your system:

1. **Docker**: Detected via `docker info`
2. **Podman**: Detected via `podman info`
3. **Apple Containers**: Detected via `container system status`

The detected runtimes are used for:
- **Node Selection**: Determining which servers can run a given space
- **Template Defaults**: Selecting the appropriate runtime when not specified
- **Cluster Operations**: Exposing runtime capabilities across the cluster

{{< tip "warning" >}}
**Important**: Container runtime daemons must be running for detection to work. If a runtime daemon is not running or is unresponsive, **knot** will not detect it as available.
{{< /tip >}}

---

## Configuration

### Docker Configuration

- **`server.docker.host`**: Specifies the Docker host to communicate with.

```toml {filename="knot.toml"}
[server.docker]
  host = "unix:///var/run/docker.sock"
```

### Podman Configuration

- **`server.podman.host`**: Specifies the Podman service to communicate with.

```toml {filename="knot.toml"}
[server.podman]
  host = "unix:///var/run/podman.sock"
```

### Apple Containers Configuration

Apple Containers use the native macOS container runtime and typically require no additional configuration. The runtime is automatically detected on Apple Silicon machines.

```toml {filename="knot.toml"}
[server.apple]
  # Apple Containers use native macOS container runtime
  # No additional configuration typically required
```

---

## Example Configuration

Below is an example of how to configure **knot** to support multiple container runtimes:

```toml {filename="knot.toml"}
[server]
  [server.docker]
    host = "unix:///Users/demo/.colima/default/docker.sock"

  [server.podman]
    host = "unix:///var/folders/4x/840000gn/T/podman/podman-machine-default-api.sock"

  [server.apple]
    # Apple Containers detected automatically on macOS
```

- Replace the paths with the appropriate socket paths for your environment
- Ensure the specified sockets are accessible and properly configured
- On macOS with Apple Silicon, Apple Containers are detected automatically

---

## Runtime Preference Order

When a template doesn't specify a container runtime, **knot** uses the following preference order:

1. **Docker**
2. **Podman**
3. **Apple Containers** (macOS only)

This preference is applied when automatically selecting a server for deployment. See [Node Selection](../node-selection/) for more details on how spaces are assigned to servers.

The system setting `server.local_containers.runtime_pref` can be used to adjust the preference order.

---

## Troubleshooting

### Runtime Not Detected

If a container runtime is not detected:
- Verify the runtime daemon is running (`docker info`, `podman info`, or `container system status`)
- Check that the socket path in `knot.toml` is correct
- Ensure the knot user has permissions to access the socket

### Multiple Runtimes Available

When multiple runtimes are available:
- Templates can specify which runtime to use
- If not specified, the preference order (Docker > Podman > Apple) is used unless set with `server.local_containers.runtime_pref`
- Only servers with the required runtime will be considered for space deployment
