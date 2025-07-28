---
title: User Interface
weight: 70
---

**knot** allows customization of the user interface, including enabling or disabling **Gravatar** support (enabled by default) and setting a custom logo.

---

### Configuration Example

Below is an example configuration for customizing the user interface in the `knot.toml` file:

```toml {filename="knot.toml"}
[server]
public_files_path = "/files/public"

[server.ui]
enable_gravatar = true
logo_invert = true
logo_url = "/public-files/custom-logo.svg"
```

---

### Explanation of Configuration

1. **Static Files**
   - The `public_files_path` option specifies the directory from which **knot** serves static files.
   - In this example, static files are served from `/files/public` and will be accessible under the URL `/public-files/`.

2. **Gravatar Support**
   - The `enable_gravatar` option enables or disables **Gravatar** support for user profiles.
   - Set to `true` to enable Gravatar (default) or `false` to disable it.

3. **Custom Logo**
   - The `logo_url` option specifies the path to the custom logo file.
   - In this example, the custom logo is set to `custom-logo.svg`, which should be stored in `/files/public/custom-logo.svg`.

4. **Logo Inversion**
   - The `logo_invert` option, when set to `true`, inverts the logo colors for the dark theme.
   - This ensures the logo appears correctly in both light and dark modes.
