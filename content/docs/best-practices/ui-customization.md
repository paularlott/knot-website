---
title: UI Customization
weight: 50
---

Best practices for customizing the knot interface.

---

## Use SVG Format for Logos

SVG provides best results:
- Scalable to any size
- Small file size
- Sharp on all displays
- Easy to edit

Fallback to PNG if SVG not available.

---

## Test on Both Themes

Always test customizations on light and dark themes:
- View logo in both themes
- Check contrast and visibility
- Use `logo_invert` if needed
- Or provide separate logos for each theme

---

## Keep Logo File Size Small

Optimize logo files:
- Target < 50KB
- Compress images
- Remove unnecessary metadata
- Use simple designs

Smaller files load faster.

---

## Use Simple, Recognizable Logos

Effective logos are:
- Simple and clean
- Recognizable at small sizes
- Work in monochrome
- Represent your brand

Avoid complex, detailed logos.

---

## Provide Favicon

Include favicon for browser tabs:

```
/var/knot/public/favicon.ico
```

Configure in HTML or let browser auto-detect.

---

## Document Customization

Document your branding setup:
- Logo file locations
- Configuration settings
- Design guidelines
- Update procedures

Helps team maintain consistency.

---

## Version Control Branding Files

Store branding files in version control:
- Track changes over time
- Easy rollback if needed
- Share across team
- Document in README

Treat branding as code.

---

## Secure Public Files

Only serve public, non-sensitive files:
- Don't store configuration
- Don't store credentials
- Set appropriate file permissions
- Regular security reviews

Public files are accessible to all users.
