---
description: Template management functions for space configuration definitions.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/libraries/template/
sources:
    - resource: https://getknot.dev/reference/libraries/template/
status: stable
tags:
    - templates
    - api
    - scripting
title: knot.template
type: API Reference
---
# knot.template

The `knot.template` library provides template management functions. Templates define the configuration for creating spaces.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| Health check scripts | Not available. |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all templates |
| `get(template_id)` | Get template by ID or name |
| `validate(platform, job='', volumes='')` | Validate template job and volume specs without saving |
| `build_spec(platform, spec, original_job='', original_volumes='')` | Build native job/volume text from a unified spec (image, env, ports, storage, resources). The same conversion the [UI spec wizard](../../knot-docs/configuration/spec-wizard.md) uses. |
| `nodes(template_id)` | List available nodes for a local-container template |
| `create(name, ...)` | Create a new template |
| `update(template_id, ...)` | Update template properties |
| `delete(template_id)` | Delete a template |
| `get_icons()` | Get list of available icons |

---

## Usage

```python
import knot.template as template

# List all templates
templates = template.list()
for t in templates:
    print(f"{t['name']}: {t['platform']}")

# Get a template
t = template.get("ubuntu")
print(t['description'])

# Get available icons
icons = template.get_icons()
print(icons)

# Validate a template spec before saving
result = template.validate("docker", job="image: ubuntu:24.04")
print(result["valid"])

# Build a spec from a unified description, then create a template from it
built = template.build_spec("nomad", {
    "image": "nginx:latest",
    "environment": [{"key": "NGINX_HOST", "value": "${{ .space.name }}"}],
    "ports": [{"host_port": 8080, "container_port": 80, "protocol": "tcp"}],
    "memory": "512M",
    "cpus": "1",
    "cpu_type": "cores",
})
template.create("nginx", job=built["job"], volumes=built["volumes"], platform="nomad")
```

---

## Template Properties

`list()` returns summary objects containing:
- `id` - Template ID
- `name` - Template name
- `description` - Description
- `platform` - Platform (e.g., "linux/amd64")
- `active` - Whether the template is active
- `usage` - Current usage count
- `deployed` - Number of deployed spaces

`get()` returns the full template including all of the above plus:
- `job` - Job definition
- `volumes` - Volume definitions
- `is_managed` - Whether managed by the system
- `compute_units` - Compute units quota
- `storage_units` - Storage units quota
- `hash` - Template hash
- `with_terminal` - Terminal access enabled
- `with_vscode_tunnel` - VS Code tunnel enabled
- `with_code_server` - Code Server enabled
- `with_ssh` - SSH access enabled
- `with_run_command` - Run command enabled
- `allow_node_migration` - Whether stopped spaces created from this local-container template can be reassigned to another node. Combined with `health_check_auto_restart`, automatic failed-node recovery is available in Knot Pro 
- `schedule_enabled` - Schedule enabled
- `auto_start` - Auto-start enabled
- `max_uptime` - Maximum uptime value
- `max_uptime_unit` - Maximum uptime unit
- `icon_url` - Icon URL
- `groups` - List of group IDs
- `zones` - List of zone names
- `schedule` - List of schedule day dicts (`enabled`, `from`, `to`)
- `custom_fields` - List of custom field dicts (`name`, `description`)
- `health_check_type` - Health check type (`none`, `agent`, `tcp`, `http`, `program`, or `custom`)
- `health_check_config` - Health check target, command, or custom script depending on type
- `health_check_skip_ssl_verify` - Skip TLS verification for HTTP health checks
- `health_check_timeout` - Health check timeout in seconds
- `health_check_interval` - Health check interval in seconds
- `health_check_max_failures` - Number of consecutive failures before the space is considered unhealthy
- `health_check_auto_restart` - Automatically restart when the health check fails. For `agent`, this restarts local-container and Nomad spaces when the agent stops transmitting. Combined with `allow_node_migration`, automatic failed-node recovery is available in Knot Pro 
- `disable_user_activity` - Whether filesystem user activity collection is disabled for spaces created from this template 
- `ports` - List of port dicts (`name`, `port`, `protocol`) defining the web ports exposed by spaces created from this template. These are injected as `KNOT_HTTP_PORT`, `KNOT_HTTPS_PORT`, and `KNOT_TCP_PORT` environment variables.

`create()` and `update()` also accept `paths`, either as a string or list of strings. These are appended to the template volume definition as managed `paths` entries.

For `health_check_type="agent"`, no `health_check_config` value is required.

## Validation

`validate(platform, job='', volumes='')` returns:
- `valid` - Whether the specification is valid
- `errors` - List of validation errors with `field` and `message`

## Building Specs

`build_spec(platform, spec, original_job='', original_volumes='')` converts a runtime-agnostic **unified spec** into the platform's native job definition (Nomad HCL or container YAML) plus volume-definition text. It's the same conversion the [UI spec wizard](../../knot-docs/configuration/spec-wizard.md) applies — useful when you want to assemble a template programmatically without hand-writing HCL or YAML.

`spec` is a dict with any of these keys (only `image` is required):

| Key | Type | Description |
|-----|------|-------------|
| `image` | string | Container image to run. |
| `hostname` | string | Container hostname (template variables supported). |
| `name` | string | Container name (`container_name`) or the Nomad job label. Unrelated to `hostname`. |
| `command` | list\[string\] | Command used to start the container. |
| `environment` | list\[{key, value}\] | Environment variables. |
| `ports` | list\[{host_port, container_port, protocol, label}\] | Host-to-container port mappings. `protocol` defaults to `tcp`. |
| `storage` | list\[StorageEntry\] | Mounts — see the spec wizard docs; each entry expands to the bind mount, volume definition, and (Nomad only) the `volume {}` / `volume_mount {}` stanzas. |
| `devices` | list\[{host_path, container_path, cgroup_permissions}\] | Host device mappings. |
| `memory` | string | Memory limit, e.g. `512M`, `1G`. |
| `memory_max` | string | Max memory limit (Nomad only). |
| `cpus` | string | CPU allocation; interpret with `cpu_type`. |
| `cpu_type` | string | Nomad only: `"cores"` (whole cores) or `"mhz"` (default). Ignored by container platforms. |
| `cap_add` / `cap_drop` | list\[string\] | Linux capabilities, e.g. `["CAP_SYS_PTRACE"]`. |
| `network` | string | Network mode. |
| `privileged` | bool | Run privileged. |
| `auth` | {username, password} | Optional registry pull credentials. |
| `templates` | list\[NomadTemplate\] | Nomad `template {}` blocks (Nomad only). |

When `original_job` / `original_volumes` are provided, the server patches the unified spec into them field-by-field, preserving any hand-written content outside the wizard's surface (just like the UI wizard's "Apply"). Pass empty strings (the default) to build from scratch.

`build_spec()` returns:
- `job` - Native job definition text (HCL for Nomad, YAML for container platforms)
- `volumes` - Volume definition text (YAML)

## Nodes

`nodes(template_id)` returns available placement nodes for local-container templates. Non-local-container templates return an empty list.

Node entries contain:
- `node_id` - Node ID
- `hostname` - Node hostname
- `running_spaces` - Number of currently running spaces on the node
- `total_spaces` - Total spaces assigned to the node
