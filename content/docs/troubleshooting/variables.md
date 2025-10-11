---
title: Variables
weight: 40
---

Troubleshooting variable issues in templates.

---

## Variables Show as Literal Text

**Symptom**: Variables appear as `${{ .user.username }}` instead of actual values.

**Solutions**:
- Check syntax: `${{ .group.name }}` not `{{ .group.name }}`
- Ensure double curly braces with space
- Verify variable name is correct

---

## Variable Not Found

**Symptom**: Error about undefined variable.

**Solutions**:
- Verify variable exists in system, user-defined, or custom variables
- Check variable is accessible in the current zone
- For user-defined variables, ensure they're created in web interface
- For custom variables, ensure they're defined in template

---

## Protected Variable Empty

**Symptom**: Protected variable shows empty when editing.

**Explanation**: This is expected behavior. Protected variables don't display values when editing for security.

**Solution**: Re-enter value if you need to change it.

---

## Variable Works in One Zone But Not Another

**Symptom**: User-defined variable works in some zones but not others.

**Solutions**:
- Check variable zone restrictions
- Ensure variable is not limited to specific zones
- Create zone-specific variables if needed
