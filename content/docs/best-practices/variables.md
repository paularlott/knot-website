---
title: Variables
weight: 40
---

Best practices for using variables in templates.

---

## Use System Variables for Identity

Leverage `user.username` and `space.id` for unique naming and isolation:

```yaml
container_name: ${{ .user.username }}-${{ .space.name }}
hostname: ${{ .space.name }}
```

This ensures containers have unique, identifiable names.

---

## Store Secrets in User-Defined Variables

Use protected user-defined variables for credentials and API keys:

```hcl
auth {
  username = "${{ .var.registry_user }}"
  password = "${{ .var.registry_pass }}"
}
```

Mark variables as protected to encrypt them in the database.

---

## Provide Clear Custom Variable Descriptions

Help users understand what values to provide:

```
Variable Name: git_branch
Description: Git branch to checkout (e.g., main, develop, feature/new-api)
```

Clear descriptions reduce errors and support requests.

---

## Validate Variable Usage

Test templates with different variable values:
- Empty values
- Special characters
- Long values
- Different user timezones

Ensure templates work correctly in all cases.

---

## Document Required Variables

Clearly document which user-defined variables templates depend on:

```
This template requires:
- var.docker_registry: Docker registry URL
- var.registry_user: Registry username
- var.registry_pass: Registry password
```

Include this in template descriptions.

---

## Use Consistent Naming

Follow naming conventions:
- `snake_case` for variable names
- Descriptive names: `database_host` not `db_h`
- Prefix related variables: `aws_region`, `aws_key`, `aws_secret`
