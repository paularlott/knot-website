---
title: Changelog
description: Keep track of all changes, updates, and improvements to knot.
type: Changelog
tags: [changelog]
layout: "changelog"
draft: false
weight: 100
navSection: docs
---

## October 2026

{{< version "v0.37.0" >}}

{{< changelog-item "added" >}}
- **File storage**: buckets of files replicated to every server in the cluster. Enable it by setting `server.files.path` (`--files-path`); servers find each other over the existing cluster connection, gossip bucket and file records, reconcile every 30 seconds and pull missing content directly from a peer, so a server returning from an outage catches up on its own. See [File Storage](../docs/file-storage/).

- **Bucket ownership and sharing**: a bucket belongs to its creator and is private until shared with users, groups or everyone, read-only or read-write. Owners can transfer a bucket to another user. Deleting a user deletes the buckets they own.

- **Namespaced bucket names**: a bucket's full name is `<username>--<name>`. You choose a short name of up to 30 characters, refer to your own buckets by it and to buckets shared with you by their full name. Lists show yours by the short name and others' by the full name, so two users can each have a `configs` bucket. Transferring a bucket renames it into the new owner's namespace.

- **Files page**: browse buckets in the web interface — upload files and folders (drag and drop or pickers), download, view and edit text files with protection against overwriting someone else's change, create and delete files and folders, and share buckets with users, groups or everyone, read only or read & write. Keyboard and screen reader friendly, with nothing loaded from outside the server.

- **`knot file` commands**: `ls`, `put`, `get`, `cat`, `rm` and `usage` for files (recursive upload and download, stdin, modification times preserved), `sync up` / `sync down` to transfer only what changed (with `--delete` and `--dry-run`), and `knot file bucket` to create, delete, share, unshare, list permissions and transfer buckets. `ls`, `usage`, `bucket list`, `bucket info` and `bucket permissions` take `--json` for scripts. Built into the agent too: inside a space they discover the server and credentials, on the desktop `--alias` picks the server. See [`knot file`](../reference/cli/knot/#knot-file).

- **S3 endpoint** {{< pro-badge >}}: Knot Pro serves file storage over the S3 API at `<server>/s3` (path-style, signature version 4, multipart, ranges, server-side copy), with your username as the access key and an API token as the secret key — rclone, the AWS CLI and SDKs work unchanged.

- **Usage shown as bars**: the Usage page and the Users page usage view show each resource — spaces (running and stopped), compute, storage, tunnels, file storage and buckets — as a labelled bar against its limit, amber and marked "Near limit" from 80% and red at the limit; resources without a limit show their figure and "No limit".

- **Bucket access in the user access overview** {{< pro-badge >}}: the Users page access panel lists each bucket a user can reach, with their access and how it is granted (owner, direct share, group or all users), and their file storage usage against quota.

- **Files token scope**: a token scoped to **Files** reaches only file storage — the files API and, on Knot Pro, S3.

- **File storage quotas**: users and groups gain **File Storage (MB)** and **Maximum Buckets** limits, summed like the other quotas and charged to the bucket owner. With no limit set, users may own 3 buckets (`server.files.default_max_buckets`) and storage is unlimited (`server.files.default_quota_mb`). The Users page gains a Files column.

- **File storage permissions**: every user can use buckets shared with them or their groups. Four permissions cover owning buckets:
  - **Use File Storage**: create and delete your own buckets.
  - **Share Buckets**: share them.
  - **Transfer Buckets**: give them to another user.
  - **Manage File Storage**: full access to every bucket.

  The Admin role has all four.

  A transferred bucket can only go to a user with Use File Storage. Manage File Storage can transfer a bucket to themselves. The Files page appears only for users who can own buckets or have one shared with them.

- **Efficient replication**: changes are gossiped in batches, content is streamed directly between servers over the gossip port (never gossiped, resuming after a broken connection), and anti-entropy compares each bucket in 64 parts and exchanges only the records of parts that differ. Listings seek through sorted keys rather than sorting the bucket for every page.

- **File storage on leaf nodes**: a leaf keeps its buckets to itself, and files never replicate between a leaf and its origin. Every user on a leaf has full use of their own buckets.

- **File storage settings**: `server.files.enabled` turns file storage off without removing the path; `server.files.default_quota_mb` and `server.files.default_max_buckets` set the limits for users with no user or group limit. Unused content, abandoned temporary files and stale multipart uploads are swept from disk hourly.

- **S3 requests without database reads** {{< pro-badge >}}: each server caches users' API keys and the group list, so authenticating an S3 request and checking quota normally reads nothing from the database. A key created or revoked anywhere in the cluster takes effect with the next request, and requests with an unknown access key are answered without a lookup.

- **File storage in backups**: `knot admin backup` includes buckets, sharing and file details (`--files`, part of a full backup when the server has file storage), and `--files-dir` copies every file's content into a directory as `<bucket>/<key>`. `knot admin restore --files-dir` reads it back, checking every file's checksum, and `knot file sync up` from the export recovers files deleted or overwritten by mistake. The backup can be taken while the server runs; restore refuses to run while a server is using the storage directory. See [Backup and Restore](../docs/best-practices/backup-restore/#file-storage).
{{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **API tokens** now start with `tk_`, so they're easy to recognise and none can begin with `-`, which a command line would take for another flag. Existing tokens keep working.

- **Usernames for new users** are limited to 30 characters and must end with a letter or digit, so bucket names built from them stay within S3's limit. Existing usernames are unaffected.
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- **MySQL 8 and later**: a new installation failed to create its tables. MySQL reserves the name `groups`, rejects literal defaults on TEXT and JSON columns, and lacks `IF [NOT] EXISTS` for columns and indexes. All three are now handled, and MariaDB is unaffected.

- **Deleting a tunnel on a busy server**: the tunnel client could miss the close request, take it for a dropped connection and reconnect. The server now waits for the client to acknowledge the request before closing the connection.

- **`knot admin` with Redis**: admin commands ignored `server.redis.hosts`, so on a server using Redis they retried connecting forever. They now use `server.redis.hosts` (`--redis-hosts`, `KNOT_REDIS_HOSTS`) like the server.

- **Creating templates through the API without an idle timeout unit** failed validation; a missing unit now means disabled, as it did before idle timeouts existed.

- **The Users page showed no users** when any user had been created through the API without roles or groups.
{{< /changelog-item >}}

---

{{< version "v0.36.2" >}}

{{< changelog-item "fixed" >}}
- **UI stacks**: in some cases the auto completion of available stacks did not work.

- **UI improvements**: to port forwarding.

- **Apple Containers**: fixed an issue where it wasn't possible to delete the container.
{{< /changelog-item >}}

---

## September 2026

{{< version "v0.36.1" >}}

{{< changelog-item "fixed" >}}
- **The spaces page broke for users with only the share permission**: it requested the user list without being allowed it, and the resulting error stopped the page loading anything. The share permission now grants the user list read the share dialog needs, and the page keeps working if that request fails.

- **UI improvements**: the Clients page command block is readable in dark mode, and share/transfer dropdown avatars load only when opened instead of on every page view.
{{< /changelog-item >}}

---

{{< version "v0.36.0" >}}

{{< changelog-item "added" >}}
- **Outbound network restrictions for server-side scripts**: a new `server.script_net_policy` setting points MCP tool and event sink scripts at a network policy file — the network equivalent of `server.script_fs_allowed_paths`. See [Network Policy](../docs/scripting/network-policy/).

- **MCP over stdio (`knot mcp`)**: run knot as a local MCP server — the command proxies the remote server's `/mcp` endpoint over stdio, authenticating from the stored connection (`--alias`) or `--server`/`--token`, never from the host's config. Also built into the agent binary, so inside a space `knot mcp` connects through the agent socket with no configuration. See [`knot mcp`](../reference/cli/knot/#knot-mcp).

- **MCP Apps in the AI chat**: a tool call linked to a `ui://` resource (the MCP Apps extension) now renders its app view inline in the conversation instead of staying buried in the tool-call disclosure. Remote MCP servers' tools and resources are exposed to the chat too, and the MCP servers management page badges app tools and shows their icons.

- **Skills served over the MCP skills extension**: knot's skills are now exposed the standard way on `/mcp`: `skills/list` and `skills/get`, with each `SKILL.md` readable as a `skill://` resource, scoped to the requesting user's access. The web assistant and the OpenAI-compatible endpoints list available skills in the system prompt — including skills from attached remote MCP servers — and pull the full content on demand. See [Skills](../docs/ai/skills/).

- **Exclusive pool member leases**: `knot pool acquire` checks out one healthy pool member for a caller's exclusive use — shared routing skips it while held, and the holder works with it by its space name, the same way they would ssh to it. The default is the simple allocate → use → release with no timeout; optional lease limits and extension caps cover shared pools and CI, and `release --destroy` swaps the member for a fresh one so the next acquire starts clean. See [Space Pools](../docs/spaces/pools/).

- **Scriptling: `knot.pool` leases**: `acquire(name, time=None, wait=None)`, `extend(space, time=None)`, `release(space, destroy=False)`, `leases(name)` and a `leased()` context manager; extend and release take the member's space name or id, durations accept `"5m"`-style strings or `"none"`. See [knot.pool](../reference/libraries/pool/).

- **Idle auto-stop for spaces**: a new template idle timeout stops a running space after it has had no user activity, an open terminal, SSH or web-port session (even idle), method calls, sustained CPU, and on Pro filesystem writes — for the configured time. Held pool leases are exempt. Set it next to Maximum Uptime in the template form, the API (`idle_timeout`, `idle_timeout_unit`), template export/import, and `knot.template.create`/`update`. See [Managing Templates](../docs/templates/managing/#runtime-limits).

- **Shared ports and cross-user forwarding**: template ports gain a **shared** type (alongside http, https and tcp), not published anywhere but reachable by every user in the same zone through port forwards, addressed as `user--space`. `knot space port forward client 5432 paul--shared-pg 5432`. Forward targets resolve as your own space, your own pool (round-robin across healthy members, leased members excluded), or another user's space/pool on shared ports; access is re-checked on every connection. Templates, pool membership and users are now cached in memory on each node, invalidated on every write. See [Space Forwarding](../docs/spaces/space-space-port-forwarding/).

- **Template port forward wiring** {{< pro-badge >}}: templates can carry port forwards seeded into every new space. Client spaces connect to their services (or a pool) automatically on start. Edited in the Pro template form; available through the API, export/import and `knot.template` everywhere.
{{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **The `/mcp` endpoint serves knot's own tools only**: remote MCP servers are no longer federated through the public endpoint, so its tool list describes knot alone and doesn't churn when a remote server is added, removed or changes. The web chat, the OpenAI-compatible endpoints and `knot.mcp` in scripts still list and call remote tools under their namespace prefix; external MCP clients that want a remote server's tools should connect to that server directly. See [Remote MCP Servers](../docs/ai/mcp-remote/).

- **The `get_skill` MCP tool is removed**: skills are no longer exposed as a tool on any surface. External MCP clients use the skills extension instead (`skills/list`, `skills/get`, `resources/read` on the `skill://` URI). The CLI, the `knot.skill` scripting library and the skills API are unchanged.
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- **`knot.mcp` works again**: the scriptling library's `list_tools()`, `call_tool()`, `tool_search()` and `execute_tool()` called API routes that were removed when chat moved to the OpenAI endpoints in February, so every call failed. The routes are back, resolving tools exactly like the web chat: knot's own tools plus remote MCP servers under their namespace prefix. See [knot.mcp](../reference/libraries/mcp/).

- **CSI volume deletes survive an in-flight operation**: Nomad rejects a concurrent delete with `Aborted — an operation with the given Volume ID already exists`; knot now retries for up to five minutes until the earlier operation clears, and if it stays wedged says so — with the remedy — instead of failing with the raw error.

- **The template form could never enable Maximum Uptime**: the unit was submitted as `disabled` for every platform, so the setting silently did nothing regardless of what was chosen.

- **Persistent forwards created on a stopped space never came up**: they stored the target as a space ID, which the proxy rejected, so the forward sat dead after the space started. Targets are now stored by name (`user--space` for other users' targets) and the proxy accepts names, qualified names and IDs.

- **Non-admins got an empty space list from the CLI**: `knot space list` and every other client that calls the spaces API without a `user_id` filter received nothing back, because the endpoint only allowed admins an unfiltered list. An omitted `user_id` now means the requester's own spaces; asking for another user's id still returns nothing without the manage-spaces permission.
{{< /changelog-item >}}

---

{{< version "v0.35.0" >}}

{{< changelog-item "added" >}}
- **KVM virtual machines**: a new template platform that runs spaces as full VMs on KVM-capable nodes — their own kernel and systemd, booted from a cloud-init image, with everything interactive (terminal, VS Code, SSH, scripts, jobs) working as with containers. Bridged or NAT networking per template, persistent stop/start, device passthrough, serial and graphical consoles in the browser, and full spec-wizard support. Nodes advertise the `kvm` runtime automatically. See [KVM Nodes](../docs/configuration/kvm/) and the [VM Specification](../docs/templates/kvm-templates/vm-spec/).
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- **Scriptling**: `knot.space` gains KVM IP support — `create()` and `update()` accept `ip_address`, new `get_ip_address()`/`set_ip_address()` helpers, and every space dict carries `ip_address`; `knot.template` responses expose the KVM network fields.
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- **Tunnel domain everywhere the wildcard domain is**: new `server.tunnel_domain` spec/stack variable with editor autocomplete; the server-info API and `knot.server.info()` now return `tunnel_domain` alongside `wildcard_domain`.
{{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **Spaces list**: the log window action is hidden for KVM spaces — a VM has no container runtime to stream logs from.
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- **Tunnels now survive a knot server restart**: instead of giving up after a few seconds, tunnel clients (daemon-mode web tunnels especially) retry with backoff indefinitely and reform the tunnel, same URL, once the server is back.
{{< /changelog-item >}}
