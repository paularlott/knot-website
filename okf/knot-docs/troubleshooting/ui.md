---
description: Troubleshooting UI customization issues.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/troubleshooting/ui/
sources:
    - resource: https://getknot.dev/docs/troubleshooting/ui/
status: stable
tags:
    - troubleshooting
title: User Interface
type: Guide
---
# User Interface

Troubleshooting UI customization issues.

---

## Logo Not Displaying

**Symptom**: Custom logo doesn't appear in web interface.

**Solutions**:

1. **Check file exists**:
   ```shell
   ls -la /var/knot/public/logo.svg
   ```

2. **Verify permissions**:
   ```shell
   chmod 644 /var/knot/public/logo.svg
   ```

3. **Check configuration**:
   Ensure `public_files_path` and `logo_url` are correct in knot.toml

4. **Clear browser cache**:
   Force refresh (Ctrl+F5 or Cmd+Shift+R)

5. **Check server logs**:
   Look for file serving errors

---

## Logo Looks Wrong in Dark Theme

**Symptom**: Logo is invisible or hard to see in dark theme.

**Solutions**:

1. **Enable logo inversion**:
   ```toml
   [server.ui]
   logo_invert = true
   ```

2. **Use a logo that suits both themes**:
   There is no separate dark theme logo setting. If inverting doesn't suit the logo, use an image with a transparent background and colours that contrast with both the light and dark themes.

---

## Gravatar Not Loading

**Symptom**: User profile images don't appear.

**Solutions**:
- Check `enable_gravatar = true` in configuration
- Verify internet connectivity from server
- Check firewall allows connections to gravatar.com
- Ensure users have valid email addresses
- Verify users have Gravatar accounts
