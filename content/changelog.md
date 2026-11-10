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

## November 2026

{{< version "v0.43.0" >}}

{{< changelog-item "added" >}}
- Run provisioning steps in a space as root with `become=True`, through sudo, and install packages and run commands with `scriptling.provision.package` and `scriptling.provision.command` ([docs](../docs/spaces/provisioning/#running-as-root))
- Add `scriptling.mercure` to every scripting environment, to publish to and subscribe at Mercure hubs; subscriptions a script leaves open close when it ends ([docs](../docs/scripting/#library-availability))
{{< /changelog-item >}}

---

{{< version "v0.42.0" >}}

{{< changelog-item "fixed" >}}
- Closed dependabot security alerts
{{< /changelog-item >}}

---

{{< version "v0.42.0" >}}

{{< changelog-item "changed" >}}
- **Breaking:** refuse to register a `private` method that lists `groups`, which were ignored; a method that lists `groups` without a `scope` is now `shared` ([docs](../docs/spaces/methods/#visibility))
- **Breaking:** store file modes in the octal form rclone uses. After upgrading, run `knot admin file fsck --repair` once, on one server, to rewrite the modes stored before ([docs](../docs/file-storage/operations/))
- Make the caller of `POST /api/spaces/{id}/emit-event` the event's actor, not the space owner ([docs](../reference/events/webhook-sinks/#actor))
- Speed up authenticated API requests, and document parallel checkout for faster git over NFS ([docs](../docs/file-storage/nfs/#speed))
- Limit usernames of new users to 24 characters, so spaces' web addresses and tunnel addresses fit in DNS; existing usernames are kept ([docs](../docs/access-control/users/))
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- Deliver custom events to other users' shared methods that subscribe to them ([docs](../reference/events/json-rpc-sinks/#scope))
- Keep file modes, symbolic links and empty folders through `knot file copy -r` and `sync` ([docs](../docs/file-storage/using-files/))
- Make `knot file sync` much faster on large trees, resume interrupted uploads, and add `--hash-file` to choose where checksums are kept ([docs](../docs/file-storage/using-files/#large-directories))
- Encrypt file content in backups made with `--encrypt-key`, not only the records ([docs](../docs/best-practices/backup-restore/#encrypted-backups))
- Add `server.files.no_sync` to report file storage writes done without forcing them to disk, for drives without power-loss protection ([docs](../docs/file-storage/#enabling-file-storage))
- Report when each version of a file was saved, as `changed_at` and `X-Knot-Changed`, alongside its own modification time
- Add `knot file snapshot` and `POST /api/files/snapshot`, to copy a folder on the server as it was at one moment ([docs](../docs/file-storage/using-files/#working-with-files))
- Add sync projects, to keep folders in step with file storage from a template, a space or the desktop, so a space's code is still there after the space is deleted ([docs](../docs/file-storage/using-files/#sync-projects))
- Add `snapshot`, `move`, `stat` and `set_attrs` to the `knot.files` script library, and `knot.files.sync` to run sync projects from scripts in a space ([docs](../reference/libraries/files/))
- Add an optional `timeout` to `knot.apiclient` requests ([docs](../reference/libraries/apiclient/#functions))
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- Fix NFS mounts hanging or reporting "stale file handle", especially on macOS
- Fix `knot nfs-server` exiting when started while the knot server is unreachable, NFS writes failing with "permission denied" while a knot server restarts, and changes to a large file over NFS being dropped when another client had shortened it
- Fix file storage failing under heavy concurrent writes, and file modes being lost when files were replaced, restored or downloaded
- Fix `knot file sync` missing some edits and waiting indefinitely on stalled transfers
- Fix some script errors in MCP tools and event sinks giving only the HTTP status, not the server's reason
- Refuse a tunnel whose address would be too long for DNS, saying how long its name may be, rather than starting one that can't be reached
- Fix a space's agent logging only to the container's log, and startup and shutdown scripts' output being lost: both now reach the container's log and the space's log ([docs](../docs/spaces/logging/#the-agents-own-logs))
- Fix the web ports of spaces with long names not resolving: an address longer than DNS allows now has the space name shortened, with a hash ([docs](../docs/troubleshooting/dns/#a-space-with-a-long-name-doesnt-resolve))
- Fix operations in a busy space failing after 5 seconds
- Fix re-registering methods sometimes dropping a space's methods
- Fix shell history being lost when a web terminal is closed or an SSH connection drops
{{< /changelog-item >}}

---

{{< version "v0.41.1" >}}

{{< changelog-item "fixed" >}}
- Fixed URL validation
{{< /changelog-item >}}

---

## October 2026

{{< version "v0.41.0" >}}

{{< changelog-item "changed" >}}
- **Breaking:** require the knot command and the server to share major and minor version ([docs](../reference/cli/knot/))
- **Breaking:** tighten knot's cookies — `__Host-` prefix on HTTPS, kept off space web servers, code-server and tunnels — so everyone signs in again after upgrading an HTTPS server; web VNC signs in through a one-time handoff instead ([docs](../docs/configuration/#security-considerations))
- **Breaking:** sign in `knot connect` by approving a code in the web interface, so it works with two-factor authentication, sign-in providers and over SSH; `--username` and `--use-web-auth` are removed ([docs](../reference/cli/knot/#knot-connect))
- Receive API replies as msgpack in the knot command
- **Breaking:** `knot.secret.get()` takes only a complete `op://vault/item/field` reference; the `field` argument and `vault/item` shorthand are removed, and `knot.space.restrictions()` no longer returns `secrets_available` ([docs](../reference/libraries/secret/)) {{< pro-badge >}}
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- Add passkey sign-in, with passkeys added and removed from your profile ([docs](../docs/configuration/passkeys/))
- Add `knot nfs-server` to mount file storage buckets over NFSv4 and NFSv3 on macOS, Linux and as Docker, Podman or template volumes ([docs](../docs/file-storage/nfs/)) {{< experimental-badge >}}
- Add a Microsoft Entra ID sign-in provider ([docs](../docs/configuration/oauth/#microsoft-setup)) {{< pro-badge >}}
- Add PKCE to OAuth sign-in for every provider ([docs](../docs/configuration/oauth/#prerequisites)) {{< pro-badge >}}
- Add OpenID Connect back-channel logout ([docs](../docs/configuration/oauth/#back-channel-logout)) {{< pro-badge >}}
- Add `link_by_email` and `insecure_skip_tls` auth provider options ([docs](../docs/configuration/oauth/#full-configuration-reference)) {{< pro-badge >}}
- Assign roles and groups from an OIDC provider's claims with `sync_roles`, matching each role's and group's new Identity Provider Name ([docs](../docs/configuration/oauth/#roles-and-groups-from-the-provider)) {{< pro-badge >}}
- Add `require_sso`, so users linked to a provider must sign in through it ([docs](../docs/configuration/oauth/#requiring-single-sign-on)) {{< pro-badge >}}
- Add `oauth_server`, so MCP clients sign in through an OIDC provider instead of knot ([docs](../docs/configuration/oauth/#mcp-clients-signing-in-through-the-provider)) {{< pro-badge >}}
- Add `check_interval`, so knot checks sign-ins with their provider, ending the sessions of users it refuses and keeping roles and groups up to date ([docs](../docs/configuration/oauth/#checking-sign-ins-with-the-provider)) {{< pro-badge >}}
- Add secret path restrictions to `knot restrict` ([docs](../docs/spaces/restrictions/#limit-personal-secrets-by-path)) {{< pro-badge >}}
- Add downloading to `knot space mirror` ([docs](../reference/cli/knot/#mirroring-a-directory-tree))
- Add the `scriptling.oauth` library to space scripts, to sign in to an identity provider and verify access tokens
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- **Breaking:** verify generic OIDC ID tokens and require `issuer` and `jwks_uri` in discovery ([docs](../docs/configuration/oauth/#how-knot-verifies-a-sign-in)) {{< pro-badge >}}
- **Breaking:** require a verified email to match an OAuth sign-in to an account or `allowed_domains`, and never match one by email to an admin, a TOTP account or one linked to another identity ([docs](../docs/configuration/oauth/#user-experience)) {{< pro-badge >}}
- Start linking a sign-in provider with a POST, so another site can't link an identity to your account; refuse to link while switched to another user; show why a sign-in or account link failed {{< pro-badge >}}
- Stop requesting offline access or storing providers' access and refresh tokens unless `check_interval` is set, clear ones already stored, and time out and size-limit requests to OAuth providers {{< pro-badge >}}
- Only remove an unused, auto-created account when its identity is linked to another account, and clean usernames from sign-in providers to knot's rules, numbering them when taken {{< pro-badge >}}
- Fix logouts being undone by in-flight requests or cluster gossip
- Fix an open redirect after signing in
- Fix `knot space read-file` failing with "path is required", binary files coming back corrupted, and `knot space mirror` running from an empty or missing source
{{< /changelog-item >}}

---

## October 2026

{{< version "v0.40.0" >}}

{{< changelog-item "changed" >}}
- Show a space's CPU in cores as well as its share of what the space may use, and treat a space as busy for idle shutdown from a quarter of a core
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- Add space restrictions: a space can keep only chosen buckets, make file storage read-only, switch off personal secrets or lock its processes out of everything else, until lifted from outside, with `knot restrict` ([docs](../docs/spaces/restrictions/))
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- Fix a space's logs going missing when written before its agent connects to the server, or while it reconnects
- Fix space CPU, memory and disk usage, and CPU history, showing the host's figures rather than the space's own
- Fix `knot secret get` failing with an i/o timeout when 1Password takes more than a few seconds to answer, as it does for a mistyped reference {{< pro-badge >}}
- Fix the usage history chart showing disk at 0% for spaces without a disk limit: it now shows the space used, on its own axis
{{< /changelog-item >}}

---

{{< version "v0.39.0" >}}

{{< changelog-item "changed" >}}
- Keep each space's agent forwarding setting in `knot ssh-config update`, including changes made by hand; add `--reset` to apply the defaults again ([docs](../reference/cli/knot/#knot-ssh-config))
- Turn off agent forwarding for spaces shared with you in `knot ssh-config update`
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- Add personal secrets: users store their own 1Password token and read their secrets in their spaces {{< pro-badge >}} ([docs](../docs/variables/personal-secrets/))
- Add 1Password service account support to secret providers {{< pro-badge >}} ([docs](../docs/variables/secret-providers/#1password-service-account))
- Add a template option to disable file storage in its spaces ([docs](../docs/templates/managing/#custom-fields-and-features))
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- Fix scripts that check `knot.permission.USE_LOG_SINKS` failing on Knot Core
{{< /changelog-item >}}

---

{{< version "v0.38.2" >}}

{{< changelog-item "changed" >}}
- Tell MCP clients what knot is and how to find its on-demand tools, including through `knot mcp`
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- Fix `knot mcp` not connecting when the server address ends in `/mcp`
{{< /changelog-item >}}

---

{{< version "v0.38.1" >}}

{{< changelog-item "added" >}}
- Add knot to Claude as a custom connector, signing in with OAuth2 ([docs](../docs/ai/mcp/#claude))
{{< /changelog-item >}}

---

{{< version "v0.38.0" >}}

{{< changelog-item "changed" >}}
- **Breaking:** reject pool custom fields that are unknown, leave a required field without a value or template default, or give a select field a value outside its options ([docs](../docs/spaces/pools/#custom-fields))
- **Breaking:** pass each argument of `knot space run`, the `run_command` MCP tool and `knot.space.run()` to the command unchanged, without shell splitting or expansion; give pipes and redirection as one quoted command ([docs](../reference/cli/knot/#running-commands-and-scripts))
- **Breaking:** pass everything after the command in `knot space run` to it, flags included; give knot's own flags before the space name ([docs](../reference/cli/knot/#running-commands-and-scripts))
- Report a failed command: `knot space run` exits with its exit code (124 on timeout) and writes its stderr to stderr, and `run_command` returns `success`, `exit_code`, `error` and the output
- Start new pool members in the background, so creating or starting a pool returns straight away
- Make the pool MCP tools discoverable; `knot mcp --show-all` lists them ([docs](../docs/ai/mcp-tools/))
- Show template names in `knot pool list` and hide Masked values in `knot pool update`
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- Add `knot pool create`, with `--lease-time` and `--lease-extensions` for member leases ([docs](../docs/spaces/pools/#creating-a-pool))
- Add pool custom fields, given to each member when it is created or started; set them in the pool form, `knot pool create --custom-field`, `knot pool update`, the API, `knot.pool` and the `create_pool` MCP tool ([docs](../docs/spaces/pools/#custom-fields))
- Add the MCP tools `list_pools`, `acquire_pool_member`, `extend_pool_lease`, `release_pool_member` and `list_pool_leases` ([docs](../docs/ai/mcp-tools/))
- Add lease settings to the `create_pool` MCP tool and to `knot.pool.create()` and `update()` ([docs](../reference/libraries/pool/))
- Serve the server's skills through `knot mcp` ([docs](../reference/cli/knot/#knot-mcp))
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- Fix `knot mcp` not finding or running discoverable tools, and showing no tools instead of an error when the server's MCP endpoint is off
- Fix a command's own short flag being read as a global one, such as `-t` on `knot space run` as `--token`
- Fix `knot space mirror` succeeding when files failed to upload
- Fix importing a template YAML without a maximum uptime
{{< /changelog-item >}}

---

{{< version "v0.37.0" >}}

{{< changelog-item "changed" >}}
- **Breaking:** back up through the API into a folder, and restore into a running new server; backup files made by earlier versions can't be restored ([docs](../docs/best-practices/backup-restore/))
- Template export and import now require the Manage Templates permission and moved to `knot admin template export|import`; `knot template list` remains available to all users ([docs](../docs/templates/managing/))
- Start API tokens with `tk_`, so none can begin with `-`; existing tokens keep working
- Limit usernames of new users to 30 characters ending in a letter or digit
- Use the chat `provider` setting on its own, with `base_url` defaulting to the provider's API; `type` with `base_url` is for other OpenAI-compatible servers, and takes precedence ([docs](../docs/ai/ai-assistant/))
- Match custom field values case-insensitively, ignoring decoration around a pasted reference such as `#1234` or `[1234]`
- Improve accessibility and usability across the web interface, and tidy the login page
- Warn before the web session expires, with the option to stay signed in
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- Add file storage {{< experimental-badge >}}: buckets replicated across the cluster, with sharing, quotas, the Files page, `knot file` commands, the `knot.files` library and an API ([docs](../docs/file-storage/))
- Add S3 access to file storage at `<server>/s3` {{< pro-badge >}}{{< experimental-badge >}} ([docs](../docs/file-storage/s3/))
- Add the Backup Server permission and a `backup` API token scope; a new server creates a Backup User role and gives it, with Admin, to its first user
- Improve usage visualization for the Usage and Users pages
- Add the buckets each user can reach to the Users access overview {{< pro-badge >}}
- Add Grok (xAI) support: set the chat `provider` to `grok`, or use `provider=ai.GROK` with `scriptling.ai` in scripts ([docs](../docs/ai/ai-assistant/))
- Add PostgreSQL as a database; it stores sessions too, so they survive a restart without Redis / Valkey, which still takes the sessions when enabled ([docs](../docs/configuration/storage-systems/postgres/))
- Add two-way and continual sync between a directory and a bucket with `knot file sync --two-way` and `--watch` ([docs](../docs/file-storage/))
- Add `knot file move` (alias `mv`), and move files on the Files page by dragging them onto a folder
- Add the template custom field option Always Show When Creating a Space ([docs](../docs/templates/managing/))
- Cache API tokens and groups to cut database reads
- Suggest the closest commands, with their aliases, when the CLI is given an unknown command
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- Fix new installations failing to create their tables on MySQL 8 and later
- Fix tunnel clients reconnecting after a tunnel was deleted on a busy server
- Fix `knot admin` ignoring `server.redis.hosts`
- Fix creating templates through the API without an idle timeout unit
- Fix the Users page showing no users when one was created without roles or groups
- Fix the chat ignoring `provider` and never sending `reasoning_effort` to the model
- Fix a slow direct connection blocking a port forward from accepting further connections
- Fix syslog lines without a priority, such as web access logs, being logged as errors
- Fix space health checks ignoring the template's timeout and skip SSL verification settings
- Fix `knot.template.update()` turning off VNC on KVM templates
- Fix `knot.role.get()` leaving out plugin permissions, so `knot.role.update()` cleared them
- Fix `knot.stack.list()` reporting every space as not running
- Fix the OAuth provider `scopes` setting being ignored {{< pro-badge >}}
- Fix listing sessions through the API failing when authenticated with an API token
- Fix the chat `temperature` and `max_tokens` settings never reaching the model; with `temperature` unset, the provider's default now applies
- Fix the AI assistant refusing on-demand tools: every approved `execute_tool` or `tool_search` call failed with "not callable from this context"
- Fix a mistyped CLI subcommand running a different command, such as `knot file buket list` running `knot file list`
{{< /changelog-item >}}

---

{{< version "v0.36.2" >}}

{{< changelog-item "fixed" >}}
- **UI stacks**: stack name auto completion on the space form offered no suggestions to users without permission to set space dependencies.

- **UI port forwarding**: the target picker lists other users' spaces that share a port, narrowed to those sharing the remote port entered {{< pro-badge >}}.

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
