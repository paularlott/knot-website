---
description: The base image catalog knot ships, as a visual grid of image families with their versions.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/templates/base-images/
sources:
    - resource: https://getknot.dev/docs/templates/base-images/
status: stable
tags:
    - templates
    - configuration
title: Base Images
type: Overview
---
# Base Images

knot ships a curated catalog of base images that the [template spec wizard](../configuration/spec-wizard.md) presents as a picker. Each is an ordinary OCI image built from [`knot-base-images`](https://github.com/paularlott/knot-base-images), preloaded with the knot entrypoint, an agent, and common dev tooling. You can also use any image (private or public) by typing its reference directly.

The catalog is versioned (`manifest_version`, format `yyyymmddbb`). Servers can [keep it up to date](#keeping-the-catalog-up-to-date) automatically from `https://getknot.dev/base-images.toml`.

<div class="not-prose my-6 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/ubuntu-linux-alt.svg" alt="Ubuntu" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">Ubuntu</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Base Ubuntu shell with code-server and dev tools.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">24.04</span>
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">26.04</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/ubuntu-linux-alt.svg" alt="Ubuntu Desktop" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">Ubuntu Desktop</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Ubuntu + XFCE desktop over web VNC.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">24.04</span>
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">26.04</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/alpine-linux.svg" alt="Alpine" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">Alpine</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Base Alpine shell with the knot toolchain and dev tools. Smaller footprint than Ubuntu.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">3.24</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/php.svg" alt="PHP" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">PHP</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Caddy + PHP-FPM, Composer, Node. Serves <code class="text-xs">~/public_html</code>.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">8.3</span>
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">8.4</span>
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">8.5</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/frankenphp.svg" alt="FrankenPHP" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">FrankenPHP</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Caddy + PHP in a single FrankenPHP process.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">8.4</span>
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">8.5</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/scriptling.svg" alt="FrankenScriptling" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">FrankenScriptling</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">FrankenPHP with the Scriptling scripting/agent extension.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">8.4</span>
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">8.5</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/go.svg" alt="Go" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">Go</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Ubuntu + the Go toolchain. Pure runtime image.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">1.26</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/python.svg" alt="Python" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">Python</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Ubuntu + Python, pip and uv. Pure runtime image.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">3.14</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/nodejs.svg" alt="Node.js" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">Node.js</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Ubuntu + Node.js, npm and corepack. Pure runtime image.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">24</span>
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">26</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/scriptling.svg" alt="Scriptling" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">Scriptling</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Ubuntu + the Scriptling interpreter and CLI. Pure runtime image.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">0.20</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/mariadb.svg" alt="MariaDB" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">MariaDB</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">MariaDB LTS releases with knot tooling.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">10.11</span>
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">11.4</span>
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">11.8</span>
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">12.3</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/mysql.svg" alt="MySQL" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">MySQL</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">MySQL Innovation releases with knot tooling.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">9.7</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/postgres.svg" alt="PostgreSQL" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">PostgreSQL</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">PostgreSQL with knot tooling.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">18</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/valkey.svg" alt="Valkey" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">Valkey</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Valkey — the Redis fork.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">9.0</span>
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">9.1</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/redis.svg" alt="Redis" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">Redis</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Redis with the knot entrypoint and syslog logging.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">8.10</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/adminer.svg" alt="Adminer" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">Adminer</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Database management UI for MySQL, MariaDB, PostgreSQL, Redis and SQLite.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">6.0</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/mailpit.svg" alt="Mailpit" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">Mailpit</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">SMTP mail catcher with a web UI for inspecting captured mail.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">1.30</span>
    </div>
  </div>

  <div class="flex flex-col items-center text-center rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 p-4">
    <img src="/icons/victorialogs.svg" alt="VictoriaLogs" class="h-12 w-12 mb-3" />
    <div class="font-semibold text-gray-900 dark:text-gray-100">VictoriaLogs</div>
    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 mb-3 flex-1">Cost-efficient log database with JSON / Loki / Elasticsearch / syslog ingest and LogsQL.</div>
    <div class="flex flex-wrap justify-center gap-1">
      <span class="text-xs px-2 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300">1.52</span>
    </div>
  </div>

</div>

All images are multi-arch (`linux/amd64`, `linux/arm64`). The versions above are image **tags**; older tags are kept in the catalog for compatibility, and the wizard marks the current default for new spaces as *recommended*.

---

## Volumes

Each image declares the mount point(s) it expects to survive a space restart. When you pick an image in the spec wizard, a storage row is added for each — you then choose the backing kind (managed named volume, managed path, or bind).

| Image family | Persistent path | What lives there |
|--------------|-----------------|-------------------|
| Ubuntu / Ubuntu Desktop | `/home` | User files, projects, shell config. |
| Alpine | `/home` | User files, projects, shell config. |
| PHP / FrankenPHP / FrankenScriptling | `/home` | As above; the web root is `~/public_html`. |
| Go / Python / Node.js / Scriptling | `/home` | Projects, `GOPATH`, virtualenvs, `node_modules`, scripts. |
| MariaDB | `/var/lib/mysql` | The database data directory. |
| MySQL | `/var/lib/mysql` | The database data directory. |
| PostgreSQL | `/var/lib/postgresql/data` | The database data directory (`PGDATA`). |
| Valkey / Redis | `/data` | RDB snapshots / AOF. |
| Mailpit | `/data` | SQLite database of captured mail. |
| VictoriaLogs | `/data` | Log storage directory. |

Web images (PHP, FrankenPHP, FrankenScriptling) also pre-fill a template port labelled **Web** on container port **80 (http)** — that's template routing metadata, not the raw network port in the spec.

---

## Keeping the catalog up to date

The catalog compiled into the binary is a snapshot taken at release time. knot can fetch a published catalog from `https://getknot.dev/base-images.toml` (the default), or a URL of your choosing. Updates are gated by a master flag, **off by default**:

```toml
[server.base_image]
update_enabled = true                          # master gate; off by default
update_url     = "https://your-mirror/base-images.toml"  # optional; defaults to getknot.dev
```

When the gate is on, the server fetches once on startup and on demand via the admin command — there's no periodic loop, so the catalog only changes on restart or an explicit refresh.

- **Gate off** → no remote fetch at all (not on startup, not via the admin command); the bundled or file catalog is used as-is.
- **No manifest file configured** → the server fetches from your `update_url` (or the default URL). A fetched catalog overlays the bundled one only when its `manifest_version` is newer.
- **Manifest file configured** → the file is used and **read from disk on every request**, so editing it takes effect immediately. The server only fetches a remote when an explicit `update_url` is also set; otherwise the file is authoritative. When a remote is fetched, it overlays the file only when newer — bump the file's version and it wins again straight away.
- **Every node fetches independently** (full members and leaves alike), so the fleet converges on identical content with no cluster coordination.

To update a running cluster without restarting, the admin command fans the refresh out to every server:

```bash
knot admin refresh-base-images --server https://knot.example.com --token <admin-token>
```

Each server must have `update_enabled` on; a server using a manifest file must also have `update_url` set, otherwise it reports a conflict and keeps its file. Pass `--local-only` to refresh just the connected server. See [Template Spec Wizard → Base image updates](../configuration/spec-wizard.md#base-image-updates) for the full rules.

---

## Source

All of these images are built from source in [`knot-base-images`](https://github.com/paularlott/knot-base-images). Each image's directory there has its own README covering bundled tools, entrypoint behaviour, and build instructions.
