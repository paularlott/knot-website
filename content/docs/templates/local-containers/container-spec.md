---
title: Container Specification
weight: 20
---

Local Container templates use a single YAML container specification for `container`, `docker`, `podman`, and `apple` platforms. The same schema is used in the editor for all local runtimes, and runtimes ignore fields they do not support.

Below is the unified container specification:

```yaml
container_name: <container name>
hostname: <host name>
image: "<container image>"
auth:
  username: <username>
  password: <password>
ports:
  - <host port>:<container port>/<transport>
volumes:
  - <host path>:<container path>
command: [
  "<1>",
  "<2>"
]
privileged: <true | false>
network: <network mode>
environment:
  - "<variable>=<value>"
cap_add:
  - <cap>
cap_drop:
  - <cap>
devices:
  - <host path>:<container path>
dns:
  - <nameserver ip>
add_host:
  - <host name>:<ip>
dns_search:
  - <domain name>
memory: <memory>[G|M]
cpus: <number of cpus>
```

---

## Container Specification Details

### **container_name**
The unique name assigned to the container. Ensure it does not conflict with other containers on the host.

### **hostname**
The hostname to set inside the container.

### **image**
The container image to use. This can be pulled from public registries like Docker Hub or private registries.

**Note**: When using Podman or Apple Container with images from Docker Hub, use fully qualified names (e.g., `registry-1.docker.io/image:tag`).

### **auth**
Authentication credentials for private registries:
- **username**: The registry username.
- **password**: The registry password.

**Note**: Some runtimes may ignore this field when it is not supported.

### **ports**
Defines port mappings between the host and container in the format `<host port>:<container port>/<transport>`. The transport protocol (`tcp` or `udp`) is optional.

### **volumes**
Specifies volume mappings in the format `<host path>:<container path>`. This ensures data persists beyond the container's lifecycle.

### **command**
Overrides the default command specified in the container image. Provide commands as a list of strings.

### **privileged**
When set to `true`, grants the container extended privileges on the host. Use cautiously due to potential security risks.

**Note**: Some runtimes may ignore this field when it is not supported.

### **network**
Specifies the network mode for the container. Options include:
- `bridge`: Default network.
- `host`: Shares the host's network stack.
- `none`: Disables networking.
- `container:<name|id>`: Shares the network stack of another container.

### **environment**
Defines environment variables in the format `<variable>=<value>`.

### **cap_add / cap_drop**
Adds or removes Linux capabilities for the container, controlling privileged operations.

**Note**: Some runtimes may ignore this field when it is not supported.

### **devices**
Maps devices from the host to the container in the format `<host path>:<container path>`.

**Note**: Some runtimes may ignore this field when it is not supported.

### **dns**
Specifies custom DNS servers for the container.

### **add_host**
Adds custom host-to-IP mappings to the container's `/etc/hosts` file.

**Note**: Some runtimes may ignore this field when it is not supported.

### **dns_search**
Defines custom DNS search domains for the container.

### **memory**
Defines the amount of memory to allocate to the container with a M or G suffix.

### **cpus**
Defines the number of CPUs to allocate to the container.
