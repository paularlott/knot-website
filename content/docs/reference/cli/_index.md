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

Copy files between local machine and space.

```shell
# Copy to space
knot cp LOCAL_FILE SPACE_NAME:REMOTE_PATH

# Copy from space
knot cp SPACE_NAME:REMOTE_PATH LOCAL_FILE
```

Examples:
```shell
knot cp config.json myspace:/etc/app/
knot cp myspace:/var/log/app.log ./logs/
```

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

## Space Management

### List Spaces

```shell
knot spaces list
```

### Start Space

```shell
knot spaces start SPACE_NAME
```

### Stop Space

```shell
knot spaces stop SPACE_NAME
```

### Delete Space

```shell
knot spaces delete SPACE_NAME
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
