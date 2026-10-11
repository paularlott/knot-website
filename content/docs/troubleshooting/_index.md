---
title: Troubleshooting
description: Common issues, the exact commands to diagnose them, and how to fix them.
type: Overview
tags: [troubleshooting]
weight: 90
---

Every section below lists the symptom, the command or file to check first, and the fix. Dedicated guides exist for [DNS](dns/), [UI customisation](ui/), and [template variables](variables/); backup and restore problems are covered in [Backup and Restore](/docs/best-practices/backup-restore/#troubleshooting).

---

## Server Issues

### Server Won't Start

**Check first** — the fatal line at the end of the server output:

```shell
knot server 2>&1 | tail -5
```

| Log line | Cause | Fix |
|---|---|---|
| `address already in use` | Port 3000 (or your `listen`) is taken | `lsof -i :3000` and stop the other process, or change `--listen` |
| `an encryption key is required` | No `server.encrypt` set | `knot genkey` and set it in the config |
| `connection refused` to MySQL/PostgreSQL/Redis | Database down or wrong credentials | See [Database Connection Errors](#database-connection-errors) |
| `license is invalid, missing, or expired` | Pro license missing, invalid, or past its 14-day grace period | Not fatal — the server keeps all Pro features with a built-in 2-user limit. Update `server.license.key` (see [Licensing](/docs/configuration/licensing/)) |
| `failed to initialize MySQL database` on a new MySQL 8+ database | Table creation failed on releases before 0.37.0 | Fixed in 0.37.0 — upgrade, then start the server against an empty database |

### Database Connection Errors

Test reachability before blaming Knot:

```shell
mysql -h <host> -u <user> -p -e "SELECT 1"        # MySQL / MariaDB
psql -h <host> -U <user> -d <database> -c "SELECT 1"  # PostgreSQL
redis-cli -h <host> -p 6379 ping                  # Redis / Valkey
```

Then confirm the credentials in `knot.toml` match, and that the database exists — each Knot instance needs its own database name or Redis DB number.

---

## Space Issues

### Space Won't Start

**Check first** — the space's logs from the Spaces page (**Logs** button), and the server log for image or volume errors. For local-container spaces, inspect the container directly:

```shell
docker ps -a | grep <username>-<spacename>   # is it crash-looping?
docker logs <username>-<spacename>           # entrypoint / agent errors
```

| Symptom in logs | Cause | Fix |
|---|---|---|
| `failed to fetch agent binary` | Container cannot reach the server URL | Use an address reachable from the container — see `${{ host_ip }}` in [Desktop Mode](/docs/quick-start/desktop-mode/) |
| `image ... not found` | Wrong image name or tag | Verify the tag exists; Podman needs fully qualified names |
| Volume errors | Bad volume YAML or missing storage | See [Volume Creation Fails](#volume-creation-fails) |

For Nomad spaces, `nomad job status <job>` and the Nomad UI show allocation failures.

### Space Stops Unexpectedly

Check the template's **Maximum Uptime** and **Schedule** settings first — they are the most common cause. Otherwise check the space logs for a crashed process, and the user's compute-unit quota if multiple spaces run.

### Cannot Connect to Space

1. Confirm the space shows **Running** with service icons.
2. Try the web terminal first — if it works, the space is fine and the problem is the client side.
3. For SSH: ensure your public key is in your [profile](/docs/spaces/ssh/).
4. For port forwarding: run `knot connect <server>` and check the local port is free.

---

## Authentication Issues

### Cannot Log In

- After 10 failed attempts within a minute, authentication blocks for 5 minutes by default (`server.auth_rate_limit_*`) — wait or adjust as admin.
- With 2FA enabled, a wrong clock on either side breaks TOTP codes — check the server's time synchronisation.
- Check the server log for the specific rejection (bad password vs blocked).

### Users Signed Out After a Server Restart

With BadgerDB or MySQL / MariaDB and no Redis / Valkey, sessions are held in memory, so a restart signs everyone out. Use [PostgreSQL](/docs/configuration/storage-systems/postgres/), or enable [Redis / Valkey](/docs/configuration/storage-systems/redis/) alongside the database for sessions. Turning Redis / Valkey on or off also signs everyone out once.

### Backup or Restore Returns 403

`knot admin backup` and `knot admin restore` need a user with the **Backup Server** permission — it isn't part of the Admin role; a new server gives its first user the **Backup User** role, which carries it. A server with no users refuses both, so on a new server create the first user and use its token. A scoped API token must also include the `backup` scope. See [Backup and Restore](/docs/best-practices/backup-restore/).

### Token Expired

Tokens expire after two weeks of inactivity; any API call resets the lifespan. For the CLI, just reconnect:

```shell
knot connect https://knot.internal:3000
```

---

## Network Issues

For wildcard-domain failures, see the dedicated [DNS Troubleshooting](dns/) guide. Quick check:

```shell
dig +short username--spacename--80.knot.internal   # should return the server IP
```

### Port Forwarding Not Working

```shell
knot connect https://knot.internal:3000   # re-authenticate the client
knot forward port 127.0.0.1:9010 spacename 80
lsof -i :9010                         # local port actually free?
```

If the forward command runs but the browser fails, the service inside the space may bind to localhost only — it needs to bind `0.0.0.0`.

### Tunnel Connection Fails

Confirm the server has `listen_tunnel` configured ([Tunnel Server](/docs/configuration/tunnel-server/)), that the wildcard DNS record for the tunnel domain points at the server, and that the tunnel name is unique among your tunnels.

---

## Template Issues

For variables rendering as literal text, see [Variables Troubleshooting](variables/).

### Volume Creation Fails

- Check the volume YAML against the [Volume Specification](/docs/templates/local-containers/volume-spec/).
- For Nomad: verify the CSI plugin is healthy (`nomad plugin status`) and the `plugin_id` in the volume definition matches.

---

## Performance Issues

### Slow Web Interface

```shell
curl -w "%{time_total}s\n" -o /dev/null -s https://knot.internal:3000/health
```

If this is fast but pages are slow, check database latency and server CPU. In clusters, gossip traffic between zones adds latency to every listing — prefer a server in the user's zone.

### High Latency to Spaces

Terminal and port-forward traffic relays through the server — deploy servers near users, or use [leaf mode](/docs/configuration/leaf-mode/) for local execution.

---

## Cluster Issues

### Nodes Not Connecting

All nodes must share the same cluster key (`server.cluster.key`), all nodes in a zone must share the same `server.encrypt` key, and each node's `advertise_addr` must be reachable from the others. Verify with the **Cluster Info** page (under **Admin**, needs the View Cluster Info permission) or by checking gossip join errors in each server's log. Firewalls must allow the gossip port between all members.

### Data Not Synchronising

Check that clocks are synchronised (NTP) on all nodes — bad clocks break conflict resolution. Then verify the nodes actually see each other (see above).

---

## Common Error Messages

**"Space quota exceeded"** — the user has reached their maximum number of spaces. Delete stopped spaces or raise the group's **Maximum Spaces** limit.

**"Compute units exceeded"** — stop another space or raise the group's **Compute Units Limit**.
