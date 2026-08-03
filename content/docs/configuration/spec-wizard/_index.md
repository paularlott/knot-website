---
title: Template Spec Wizard
description: Configure the base image registry and manifest that power the template spec wizard.
type: Overview
tags: [configuration, templates]
weight: 60
---

The **template spec wizard** is a UI-driven builder for template specs (Nomad HCL or local container YAML). Instead of writing HCL/YAML by hand, administrators pick a base image from a catalog, set resources, mounts, env vars, and ports — knot writes the spec for them.

The wizard is available from the template create/edit form via the wand icon next to the **Nomad Job (HCL)** / **Container Specification (YAML)** field. It only enables for specs it can safely round-trip (single-task Nomad jobs with a `docker` driver, or any well-formed container spec). Multi-task Nomad jobs and unparseable specs disable the wizard with an explanatory message.

{{< tip >}}
The **Name** field in the wizard (labelled **Job Name** for Nomad, **Container Name** for containers) is separate from **Hostname**. Name maps to the Nomad job's label (`job "<name>" { ... }`) or `container_name`; Hostname maps to the `hostname` field. Templates commonly set both to the same convention, e.g. `${{ .user.username }}-${{ .space.name }}` for Name and `${{ .space.name }}` for Hostname — but they're independent fields.
{{< /tip >}}

{{< tip >}}
The wizard doesn't replace hand-editing — it patches only the fields it controls. Anything outside that surface (Nomad constraints, meta stanzas, comments in non-patched ranges) is preserved byte-for-byte on Apply.
{{< /tip >}}

---

## Base Image Registry

The wizard's image picker shows a curated catalog of base images (Ubuntu, PHP, MariaDB, Valkey, etc.). See the [base images reference](../../base-images/) for the full grid of supplied images and their versions. Each catalog entry references the registry via the `${{ .server.base_image_registry }}` [system variable](../../variables/system-variables/), which resolves at deploy time to the configured value.

**Default:** `docker.io/paularlott`

```toml
[server.base_image]
# Prefix prepended to relative image references in specs and the bundled
# base image manifest. Exposed to templates as ${{ .server.base_image_registry }}.
registry_url = "docker.io/paularlott"
manifest = "/etc/knot/base-images.toml"
# Optional: when both are set, the wizard injects an auth block into specs
# when the user picks a base image from the catalog. Exposed as
# ${{ .server.base_image_registry_user }} and ${{ .server.base_image_registry_password }}.
registry_user = ""
registry_password = ""
```

Common overrides:

| Registry | Value |
|----------|-------|
| Docker Hub (upstream) | `docker.io/paularlott` (default) |
| Internal mirror      | `hub.example.com/library` |
| GHCR                 | `ghcr.io/yourorg` |
| Self-hosted Harbor   | `harbor.example.com/knot` |

Absolute image references in specs (e.g. `ghcr.io/foo/bar:1`) bypass the prefix entirely.

---

## Base Image Manifest

The catalog itself comes from a TOML manifest. By default knot uses a manifest compiled into the binary (covering the [knot-base-images](https://github.com/paularlott/knot-base-images) catalog). To replace it — for example to add private images, use different icons, or restrict the picker to a curated subset — point at an external file:

```toml
[server.base_image]
registry_url = "docker.io/paularlott"
manifest = "/etc/knot/base-images.toml"
```

### Manifest format

```toml
version = 1
description = "My catalog"

[[image]]
name            = "ubuntu-26.04"
display_name    = "Ubuntu 26.04"
description     = "Base Ubuntu 26.04 image with dev tools."
image           = "${{ .server.base_image_registry }}/knot-ubuntu:26.04"
icon            = "/icons/ubuntu-linux-alt.svg"
category        = "base"
default_memory  = "2G"
default_cpus    = "1"
recommended     = true

# Optional: mount points the image expects to be persistent. The wizard
# pre-fills one storage row per entry when the image is picked.
[[image.volume]]
path        = "/home"
description = "Persistent home directory."

[[image]]
name            = "custom-app"
display_name    = "Internal App"
description     = "Pre-built image of our internal app."
image           = "registry.internal/app:latest"   # absolute, no var
icon            = "https://internal.example.com/app-icon.svg"
category        = "internal"
```

| Field | Required | Description |
|-------|----------|-------------|
| `version` | yes | Manifest schema version (currently 1). Bumped only on structural changes. |
| `manifest_version` | no* | Catalog revision in `yyyymmddbb` form (date + same-day build counter). Used to decide whether a fetched manifest is newer than the bundled one — omit only for custom file-based catalogs that are never fetched. |
| `description` | no | Free-form description of the catalog. |
| `name` | yes | Stable identifier used as the picker key. |
| `display_name` | yes | Shown in the picker. |
| `description` | yes | One-line description shown under the name. |
| `image` | yes | Image reference; may use `${{ .server.base_image_registry }}` or be absolute. |
| `icon` | no | Icon URL. The bundled catalog uses knot-served paths like `/icons/ubuntu-linux-alt.svg` (see [internal/service/icons.go](https://github.com/paularlott/knot/blob/main/internal/service/icons.go) for the full set). Absolute URLs (`https://...`) also work — useful for private icons in custom manifests. |
| `category` | no | Free-form label rendered as a badge (e.g. `base`, `datastore`). Defaults to `general`. |
| `default_memory` | no | Pre-filled in the wizard when the user picks this image (only if the field is empty). |
| `default_cpus` | no | Nomad: reserved MHz (`cpu = N`). Containers: CPU shares (`--cpu-shares`, default 1024). Pre-filled only when the CPUs field is empty. |
| `default_cores` | no | Nomad: whole CPU cores to reserve (`cores = N`). Containers: number of CPUs (`--cpus`). Pre-filled only when the CPUs field is empty. |
| `recommended` | no | Renders a "recommended" badge in the picker. |
| `tags` | no | List of strings, reserved for future filtering. |
| `default_env` | no | List of `KEY=value` env vars pre-filled when picking this image (only if the key doesn't already exist). e.g. `["KNOT_VNC_HTTP_PORT=5680"]` for desktop images. |
| `default_port` | no | Array of template-level ports pre-filled when picking this image (if the port doesn't already exist). Each entry has `name`, `port`, and `protocol`. e.g. `[[image.default_port]]` with `name = "Web"`, `port = 80`, `protocol = "http"` for PHP images. These are template port metadata used for routing, not the Nomad/Docker network ports in the spec. |
| `volume` | no | Array of mount points the image expects to be persistent (`[[image.volume]]`). Each entry has a `path` (the in-container mount point, e.g. `/home`, `/data`, `/var/lib/mysql`) and an optional `description`. The wizard pre-fills one storage row per entry when the image is picked; the backing kind (named volume / managed path / bind) is chosen in the wizard. |

### Building a manifest from the knot-base-images repo

The default manifest's metadata mirrors the OCI labels in [`docker-bake.hcl`](https://github.com/paularlott/knot-base-images/blob/main/docker-bake.hcl). If you maintain a fork that adds images, copy the corresponding `org.opencontainers.image.*` labels into `[[image]]` entries and reload with `server.base_image.manifest` pointing at your file. The bundled manifest is regenerated on each knot release.

---

## Auto-update

The catalog compiled into the binary is a snapshot taken at release time. To pick up new images and versions, knot can fetch a published manifest (`https://getknot.dev/base-images.toml` by default, which mirrors the [bundled catalog](https://getknot.dev/base-images.toml)). There is no periodic loop — the fetch happens once on startup, and on demand via the admin command — so the catalog only ever changes on restart or an explicit refresh.

Two flags control it:

```toml
[server.base_image]
auto_update = true                       # off by default; gates the STARTUP fetch
update_url  = "https://your_mirror/base-images.toml"  # optional; defaults to getknot.dev
```

Whether a fetch happens depends on whether a `manifest` file is configured (M), `auto_update` is on (A), and an explicit `update_url` is set (U):

| Configured file (M) | Startup fetch | Manual refresh (`knot admin refresh-base-images`) |
|---|---|---|
| **No file** | only if `auto_update` is on; fetches from `update_url`, or the default URL if none is set | always; fetches from `update_url`, or the default URL if none is set |
| **File set** | only if `auto_update` is on **and** an explicit `update_url` is set; fetches from `update_url` | only if `auto_update` is on **and** an explicit `update_url` is set; fetches from `update_url` |

In short: without a file you always get a fetch (default URL is fine); with a file, the file is used unless you've explicitly opted into remote updates with both `auto_update` and `update_url`.

In every case where a fetch happens, the fetched manifest **overlays the baseline only when its `manifest_version` (yyyymmddbb) is strictly newer** — so the baseline is never silently downgraded, and bumping a file's version keeps it ahead of the remote. If the fetch fails, the server falls back to the baseline and logs a warning.

While a configured file is the active catalog it is **read from disk on every request**, so editing it takes effect immediately (no restart). Every node (full members and leaves) fetches independently from the same URL, so the fleet converges on identical content with no cluster coordination.

### Manual refresh (cluster-wide)

To update a running fleet without restarting, run the admin command — it fans the refresh out to every server in the cluster and reports each one:

```bash
knot admin refresh-base-images --server https://knot.example.com --token <token>
```

Each server applies the "Manual refresh" row above: a server with no manifest file always fetches; a server with a manifest file fetches only if both `auto_update` and `update_url` are set (otherwise it reports a conflict and keeps using its file). Pass `--local-only` to refresh just the connected server. Leaf nodes aren't gossip members and won't be reached by the fan-out — refresh them individually (they also fetch on their own startup).

Or via the API — `POST /api/base-images/refresh` (requires the `manage-templates` permission) refreshes a single server.

---

## CLI flags

All options are available as CLI flags or environment variables:

| Flag | Env var | Config path | Default |
|------|---------|-------------|---------|
| `--base-image-registry` | `KNOT_BASE_IMAGE_REGISTRY` | `server.base_image.registry_url` | `docker.io/paularlott` |
| `--base-images-manifest` | `KNOT_BASE_IMAGES_MANIFEST` | `server.base_image.manifest` | (bundled) |
| `--base-images-auto-update` | `KNOT_BASE_IMAGES_AUTO_UPDATE` | `server.base_image.auto_update` | `false` |
| `--base-images-update-url` | `KNOT_BASE_IMAGES_UPDATE_URL` | `server.base_image.update_url` | `https://getknot.dev/base-images.toml` (only used when no manifest file is set) |
| `--base-image-registry-user` | `KNOT_BASE_IMAGE_REGISTRY_USER` | `server.base_image.registry_user` | (none) |
| `--base-image-registry-password` | `KNOT_BASE_IMAGE_REGISTRY_PASSWORD` | `server.base_image.registry_password` | (none) |

When both `registry_user` and `registry_password` are set, the wizard injects an auth block into the spec when the user picks a base image from the catalog — using `${{ .server.base_image_registry_user }}` and `${{ .server.base_image_registry_password }}` so credentials resolve at deploy time. If the spec already has an auth block, it's left untouched.

## Storage

The wizard's **Storage** section replaces the previous separate "Volumes" list and "Volume Definition" text area. Each storage row declares:

| Kind | What it does |
|------|-------------|
| **Bind** | Mounts an existing host path (or the name of a volume created outside the wizard) directly into the container. No Volume Definition entry is created. |
| **Volume** | A managed named volume that knot creates with the space and destroys when the space is deleted. For containers this is a `volumes:` entry with an optional `size`; for Nomad it's a full CSI or host volume with `plugin_id`, capacity, capabilities, secrets and parameters. The wizard creates both the Volume Definition entry AND the mount in the job spec. |
| **Path** | A managed directory knot creates before the job starts (and removes with the space). Appears in the Volume Definition `paths:` list. |

Every kind carries a **Container Path** (where it mounts inside the container) and a **Read-Only** toggle.

For Nomad **Volume** entries the wizard exposes a **type** dropdown (`host` / `csi: single` / `csi: multi`) that controls the volume type and access mode:

| Type | HCL emitted | Volume Definition |
|------|-------------|-------------------|
| **host** | `type = "host"`, no `access_mode`/`attachment_mode` | host volume (plugin defaults to `mkdir`) |
| **csi: single** | `type = "csi"`, `access_mode = "single-node-writer"` | CSI volume with default capabilities |
| **csi: multi** | `type = "csi"`, `access_mode = "multi-node-multi-writer"` | CSI volume with multi-node capabilities |

`attachment_mode` is always `file-system` and is injected automatically — it's not editable in the wizard. Additional CSI fields (`plugin_id`, `capacity_min/max`, `secrets`, `parameters`, mount options) are available via the gear icon on each volume row; `access_mode` and `attachment_mode` are hidden from that panel since they're managed by the dropdown.

---

## Wizardability and Advanced mode

The spec wizard can display any spec it can parse, but not every spec is **fully representable** — some contain constructs outside the wizard's field set (Nomad `template {}`, `constraint {}`, `artifact {}` blocks; container YAML fields like `shell`). These are never lost on Apply (the patcher preserves them), but they're invisible in wizard mode.

The parse response includes `fully_representable` (boolean) and `advanced_reason` (listing what was detected). The template form uses these to determine whether to default to Advanced (raw editor) mode or allow wizard mode. When `fully_representable` is false, the Wizard button still works — but the UI signals that the spec has content the wizard can't show, and defaults to the raw editors.

---

Capabilities granted to the container (`cap_add`) are edited with a searchable picker: click **+** next to **Capabilities**, then search by capability name (`net_admin`) or by what it does ("raw sockets", "clock"). Selected capabilities appear as pills; the **x** on a pill removes it. Capabilities the picker marks *common* are listed first.

The catalog covers the capabilities dev spaces usually need rather than the full kernel list. Anything missing can still be typed into the search box and added with **Enter**, and hand-written capabilities already in a spec are kept as-is even when they aren't in the catalog.

Dropping capabilities (`cap_drop`) is rare enough that the wizard doesn't offer a control for it — edit that in the spec directly. Any `cap_drop` already in the spec is read by the wizard and written back unchanged on Apply.

Names are stored canonically (`CAP_NET_ADMIN`) and written in the form each runtime expects:

| Platform | Emitted as |
|----------|-----------|
| Docker / Podman | `cap_add: [CAP_NET_ADMIN]` |
| Nomad | `cap_add = ["net_admin"]`, the form the [docker task driver documents](https://developer.hashicorp.com/nomad/docs/job-declare/task-driver/docker). If the job already uses the `CAP_`-prefixed form, that style is kept. |

The picker is available for every platform the wizard supports. Bear in mind that some runtimes ignore capabilities, Apple Containers, for example, exactly as they do when the field is written by hand.

{{< tip >}}
Nomad clients restrict which capabilities a job may request via the docker plugin's `allow_caps` setting. A capability the wizard writes is only granted if the client allows it.
{{< /tip >}}

---

## How the wizard modifies specs

- **Container specs (Docker/Podman/Apple):** the YAML is patched in place. Comments on fields the wizard doesn't rewrite survive, as do fields outside the wizard's schema. Comments *inside* a list the wizard replaces (ports, volumes, environment, capabilities) are lost, because the whole list is re-emitted.
- **Nomad specs:** the wizard's fields are patched into the existing HCL via constrained text surgery on the first task block. Comments, heredoc templates, and any HCL outside wizard-controlled blocks (constraints, services, meta) survive untouched. If the original HCL is empty, a complete default job is emitted using `${{ .space.name }}` / `${{ .user.username }}` placeholders.
- The wizard never invents values it can't see: a `network` block with no `mode`, or a spec with no `privileged` flag, stays that way after Apply.

### When the wizard refuses

The wand icon disables itself rather than risk rewriting a spec it doesn't fully understand:

| Situation | Why |
|-----------|-----|
| Multi-task or multi-group Nomad job | The wizard models a single task. |
| Nomad task driver other than `docker` | Config layout differs per driver. |
| Unparseable HCL or YAML | Nothing reliable to read or patch. |
| Nomad not configured on the server | HCL parsing needs a Nomad endpoint. |
| Container YAML with multiple documents (`---`) | Only the first document could be patched. |
| Container YAML using anchors or aliases (`&base`, `*base`, `<<:`) | Re-emitting expands them and changes the file's meaning. |
| Nomad group volume where the label differs from `source` | The wizard can't round-trip the label→source mapping. |

{{< tip >}}
Knot template directives like `${{ if .X }}` / `${{ end }}` that appear as standalone lines between HCL blocks are handled automatically — they're commented out before the HCL reaches Nomad's parser, so the wizard can parse the surrounding job. If commenting out the directives produces broken HCL (e.g. an `${{ else }}` that makes both branches visible with duplicate fields), the parse fails and the wizard shows the error.
{{< /tip >}}

In each case the wizard shows the reason and you edit the spec directly.

---

## Icon flow

When the user picks a base image from the picker:

1. The image string is written to the visible image field.
2. The image's manifest icon URL is captured into a hidden wizard field.
3. On Apply, if the hidden field is set, it's written to the template's `icon_url`; if the user typed an image manually (no picker), the template's `icon_url` is left untouched, so any custom icon set via the existing icon control is preserved.

On every wizard open, the hidden icon field is cleared — so updating an image via the picker always updates the template icon, but editing other wizard fields without touching the image leaves the icon alone.
