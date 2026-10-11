---
description: Customize the knot web interface with custom logos and Gravatar integration.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/configuration/ui/
sources:
    - resource: https://getknot.dev/docs/configuration/ui/
status: stable
tags:
    - configuration
title: User Interface
type: Overview
---
# User Interface

Customize the Knot web interface with your organization's branding, including custom logos and Gravatar integration.

---

## White-Label Support

White-labeling allows you to brand knot with your organization's identity. This is useful for:
- Internal deployments matching corporate branding
- Service providers offering knot to clients
- Organizations wanting consistent visual identity

---

## Configuration

```toml {filename=knot.toml}
[server]
public_files_path = "/var/knot/public"

[server.ui]
enable_gravatar = true
logo_invert = true
logo_url = "/public-files/logo.svg"
hide_support_links = false
hide_api_tokens = false
enable_builtin_icons = true
# icons = ["/var/knot/public/extra-icons.json"]
```

---

## Interface options

| Key | Default | Description |
| --- | ------- | ----------- |
| `hide_support_links` | `false` | Hide the support and documentation links from the web UI |
| `hide_api_tokens` | `false` | Hide the API Tokens menu entry (and its search result) for all users; tokens keep working through the CLI and API |
| `enable_builtin_icons` | `true` | Serve the built-in icon set used when picking icons for templates |
| `icons` | | Extra icon definition files to load (repeatable list of file paths) |

---

## Custom Logo

### Setting Up a Custom Logo

1. **Create public files directory**:
   ```shell
   mkdir -p /var/knot/public
   ```

2. **Add your logo file**:
   ```shell
   cp your-logo.svg /var/knot/public/logo.svg
   ```

3. **Configure knot**:
   ```toml
   [server]
   public_files_path = "/var/knot/public"
   
   [server.ui]
   logo_url = "/public-files/logo.svg"
   ```

4. **Restart knot server**

### Logo Requirements

**Format**: SVG recommended for scalability. PNG and JPG also supported.

**Size**: Optimal dimensions are 200x50 pixels or similar aspect ratio.

**Colors**: Use colors that work on both light and dark backgrounds, or use `logo_invert`.

### Logo Inversion

The `logo_invert` option inverts logo colors for dark theme:

```toml
[server.ui]
logo_invert = true
```

**When to use**:
- Logo has dark colors on transparent background
- Logo needs to be visible on dark theme
- Single logo file for both themes

**When not to use**:
- Logo already works on both themes
- Logo has complex colors

A single logo file serves both themes: set `logo_url`, and enable `logo_invert` when the logo needs inverting for the dark theme. Separate light/dark logo files are not supported.

---

## Gravatar Support

Gravatar displays user profile images based on email addresses.

### Enable Gravatar

```toml
[server.ui]
enable_gravatar = true
```

Users with Gravatar accounts will see their profile images in:
- User lists
- Space sharing dialogs
- Profile pages
- Audit logs

### Disable Gravatar

```toml
[server.ui]
enable_gravatar = false
```

Disable for:
- Privacy requirements
- Air-gapped environments
- Organizations not using Gravatar

---

## Static Files

Knot can serve two directories of static files:

- **`public_files_path`** (`--public-files-path` / `KNOT_PUBLIC_FILES_PATH`): served at `/public-files/` to anyone, without logging in. Use it for the logo and anything else the login page needs.
- **`private_files_path`** (`--private-files-path` / `KNOT_PRIVATE_FILES_PATH`): served at `/private-files/` to logged-in users only. Use it for internal documents you want to link to from templates or descriptions.

Both are unset by default, which disables the path.

### Configuration

```toml
[server]
public_files_path = "/var/knot/public"
private_files_path = "/var/knot/private"
```

### Use Cases

**Custom Logos**
```
/var/knot/public/logo.svg → /public-files/logo.svg
```

**Documentation**
```
/var/knot/public/docs/guide.pdf → /public-files/docs/guide.pdf
/var/knot/private/runbook.pdf → /private-files/runbook.pdf
```

Files placed here are only served; Knot doesn't pick up a favicon or stylesheet from these directories.

### Security

- Only serve public, non-sensitive files from `public_files_path`; anything for signed-in users belongs in `private_files_path`
- Don't store configuration or credentials
- Set appropriate file permissions
- Regularly review served files

---

## Complete Example

```toml {filename=knot.toml}
[server]
listen = "0.0.0.0:3000"
url = "https://dev.company.com"
public_files_path = "/opt/knot/branding"

[server.ui]
enable_gravatar = true
logo_url = "/public-files/company-logo.svg"
logo_invert = false
```

Directory structure:
```
/opt/knot/branding/
├── company-logo.svg
└── docs/
    └── user-guide.pdf
```
