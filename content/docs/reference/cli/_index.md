---
title: CLI Reference
weight: 10
---

The **knot** command-line interface provides tools for managing servers, connecting to spaces, and automating workflows.

---

## Server Commands

### `knot server`

Start the knot server.

```shell
knot server --config knot.toml
```

**Options**:
- `--config`: Path to configuration file
- `--validate`: Validate configuration without starting server

---

### `knot scaffold`

Generate configuration file templates.

```shell
# Generate server configuration
knot scaffold --server > knot.toml

# Generate agent configuration
knot scaffold --agent > agent.toml
```

---

### `knot genkey`

Generate encryption key for configuration.

```shell
knot genkey
```

Use the output in the `server.encrypt` or `server.cluster.key` configuration fields.

---

## Client Commands

### `knot connect`

Connect to a knot server and authenticate.

```shell
knot connect https://knot.example.com:3000
```

Credentials are stored in `~/.config/knot/knot.yml` for subsequent commands.

**Options**:
- `--server-name`: Name for this server connection (for managing multiple servers)

---

### `knot forward`

Forward connections between local machine and spaces.

#### SSH Forwarding

```shell
knot forward ssh SPACE_NAME
```

Use with SSH ProxyCommand:
```shell
ssh -o ProxyCommand='knot forward ssh %h' user@spacename
```

#### Port Forwarding

```shell
knot forward port LOCAL_ADDR SPACE_NAME REMOTE_PORT
```

Example:
```shell
knot forward port 127.0.0.1:8080 myspace 80
```

---

### `knot tunnel`

Create tunnels to expose services publicly.

```shell
knot tunnel PROTOCOL PORT TUNNEL_NAME
```

**Protocols**: `http`, `https`

Example:
```shell
knot tunnel http 8080 myapp
```

Creates tunnel at `username-myapp.tunnel.example.com`.

---

### `knot ssh-config`

Manage SSH configuration entries for spaces.

```shell
# Add entries for all spaces
knot ssh-config update

# Remove all entries
knot ssh-config remove
```

Automatically updates `~/.ssh/config` with ProxyCommand entries.

---

### `knot run`

Execute commands in a space.

```shell
knot run SPACE_NAME COMMAND [ARGS...]
```

Example:
```shell
knot run myspace ls -la /home
```

---

### `knot cp`

Copy files between local machine, spaces, and between spaces.

```shell
# Copy to space
knot cp LOCAL_FILE SPACE_NAME:REMOTE_PATH

# Copy from space
knot cp SPACE_NAME:REMOTE_PATH LOCAL_FILE

# Copy between spaces
knot cp SOURCE_SPACE:SOURCE_PATH DEST_SPACE:DEST_PATH
```

Examples:
```shell
# Local to space
knot cp config.json myspace:/etc/app/

# Space to local
knot cp myspace:/var/log/app.log ./logs/

# Space to space
knot cp frontend:/app/build backend:/var/www/html
```

**Options**:
- `--workdir`, `-w`: Working directory for relative paths in space

---

## Agent Commands

These commands run inside a space.

### `knot agent`

Start the knot agent inside a container.

```shell
knot agent --config agent.toml
```

Usually started automatically by container entrypoint.

---

### `knot agent shutdown`

Request space shutdown from inside the space.

```shell
knot agent shutdown
```

---

### `knot agent restart`

Request space restart from inside the space.

```shell
knot agent restart
```

---

### `knot agent set-note`

Set space note from inside the space.

```shell
knot agent set-note "Deployment completed"
```

---

### `knot port`

Agent port management for forwarding ports between spaces.

#### Forward Port

Forward a local port in the current space to a port in another space.

```shell
knot port forward LOCAL_PORT SPACE_NAME REMOTE_PORT
```

Example:
```shell
knot port forward 8080 backend-api 3000
```

**Requirements**:
- Both spaces must be running with active agents
- Spaces must be in the same zone
- Spaces must be owned by the same user

#### List Active Port Forwards

View all active port forwards from the current space.

```shell
knot port list
```

#### Stop Port Forward

Stop an active port forward.

```shell
knot port stop LOCAL_PORT
```

Example:
```shell
knot port stop 8080
```

---

## Space Management

### List Spaces

```shell
knot space list
```

### Start Space

```shell
knot space start SPACE_NAME
```

### Stop Space

```shell
knot space stop SPACE_NAME
```

### Restart Space

```shell
knot space restart SPACE_NAME
```

### Delete Space

```shell
knot space delete SPACE_NAME
```

### Create Space

```shell
knot space create SPACE_NAME TEMPLATE_NAME
```

### Get Space Logs

```shell
knot space logs SPACE_NAME
```

### Run Command in Space

```shell
knot space run SPACE_NAME COMMAND [ARGS...]
```

### Run Script in Space

```shell
knot space run-script SPACE_NAME SCRIPT_NAME [ARGS...]
```

---

## Space File Operations

### Read File from Space

Read file contents from a running space.

```shell
knot space read-file SPACE_NAME FILE_PATH
```

Examples:
```shell
# Read a file
knot space read-file myspace /etc/hostname

# Redirect to local file
knot space read-file myspace /var/log/app.log > local.log
```

### Write File to Space

Write content to a file in a running space.

```shell
# Write content directly
knot space write-file SPACE_NAME FILE_PATH --content "CONTENT"

# Read from stdin
echo "Hello World" | knot space write-file SPACE_NAME FILE_PATH --content -
```

Examples:
```shell
# Write text directly
knot space write-file myspace /tmp/hello.txt --content "Hello World"

# Pipe from local file
cat config.json | knot space write-file myspace /etc/app/config.json --content -
```

**Options**:
- `--content`, `-d`: Content to write (use `-` to read from stdin)

---

## Space Field Operations

### Get Custom Field

```shell
knot space get-field SPACE_NAME FIELD_NAME
```

### Set Custom Field

```shell
knot space set-field SPACE_NAME FIELD_NAME VALUE
```

---

## Space Tunnel Port

Create a tunnel from a space port to a local port.

```shell
knot space tunnel-port SPACE_NAME REMOTE_PORT LOCAL_PORT
```

---

## Script Management

### List Scripts

List all available scripts (user and global).

```shell
knot script list
```

Shows script name, description, active status, type, and discoverability.

### Show Script Details

Display detailed information about a script including its content.

```shell
knot script show SCRIPT_NAME
```

### Delete Script

Delete a script by name.

```shell
knot script delete SCRIPT_NAME
```

---

## Global Options

Available for most commands:

- `--help`: Show command help
- `--version`: Show version information
- `--server-name`: Select server connection (when managing multiple servers)

---

## Configuration File

Client configuration is stored in `~/.config/knot/knot.yml`:

```yaml
servers:
  default:
    url: https://knot.example.com:3000
    token: <auth-token>
  production:
    url: https://knot-prod.example.com:3000
    token: <auth-token>
```

Switch between servers using `--server-name` flag.

---

## Environment Variables

- `KNOT_SERVER`: Override server URL
- `KNOT_TOKEN`: Override authentication token
- `KNOT_CONFIG`: Override config file path

---

## Exit Codes

- `0`: Success
- `1`: General error
- `2`: Authentication error
- `3`: Connection error
- `4`: Not found error
