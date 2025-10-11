---
title: User Interface
weight: 70
---

Customize the **knot** web interface with your organization's branding, including custom logos and Gravatar integration.

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
```

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
- Using separate light/dark logos
- Logo has complex colors

### Multiple Logo Files

For best results, provide separate logos for light and dark themes:

```toml
[server.ui]
logo_url = "/public-files/logo-light.svg"
logo_dark_url = "/public-files/logo-dark.svg"
```

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

The `public_files_path` serves static files for customization.

### Configuration

```toml
[server]
public_files_path = "/var/knot/public"
```

Files in this directory are accessible at `/public-files/` URL path.

### Use Cases

**Custom Logos**
```
/var/knot/public/logo.svg → /public-files/logo.svg
```

**Favicon**
```
/var/knot/public/favicon.ico → /public-files/favicon.ico
```

**Documentation**
```
/var/knot/public/docs/guide.pdf → /public-files/docs/guide.pdf
```

**Custom CSS** (if supported)
```
/var/knot/public/custom.css → /public-files/custom.css
```

### Security

- Only serve public, non-sensitive files
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
├── favicon.ico
└── docs/
    └── user-guide.pdf
```


