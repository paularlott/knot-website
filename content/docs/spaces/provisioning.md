---
title: Provisioning
weight: 210
---

Provisioning ensures that files and directories are in the desired state when a space starts or on demand. Knot provides the `scriptling.provision.file` library for writing idempotent provisioning scripts that only make changes when needed.

---

## How Provisioning Works

A provisioning script uses `scriptling.provision.file` to declare the desired state of files and directories inside a space. The library is **idempotent** -- it compares the current state against the desired state and only writes when content or permissions differ.

There are three ways to run a provisioning script:

| Method | Scope | When It Runs |
|--------|-------|-------------|
| **Template startup script** | All spaces from the template | Automatically on space start |
| **User startup script** | Individual space | Automatically on space start (after template script) |
| **Manual execution** | Individual space | On demand via CLI |

---

## Writing a Provisioning Script

Provisioning scripts use the `scriptling.provision.file` library, available in the **Remote** and **External** environments:

```python
import scriptling.provision.file as file

file.ensure("~/.bashrc", """export PATH="$HOME/bin:$PATH"
export EDITOR=vim
alias ll='ls -la'
""")

file.ensure_directory("~/bin", mode=0o755)

file.ensure("~/bin/setup.sh", """#!/bin/bash
echo "Environment ready"
""", mode=0o755)
```

Each call to `ensure` returns a status constant (`file.CREATED`, `file.UPDATED`, or `file.UNCHANGED`) so you can log results:

```python
import scriptling.provision.file as file

status = file.ensure("~/.gitconfig", """[user]
    name = Jane Doe
    email = jane@example.com
""", mode=0o600)

if status == file.CREATED:
    print("Created .gitconfig")
elif status == file.UPDATED:
    print("Updated .gitconfig")
```

See the [scriptling.provision.file reference](../scripting/libraries/provision-file/) for the full API including `absent`, `ensure_directory`, and `absent_directory`.

---

## Running a Provisioning Script

### As a Template Startup Script

Setting a provisioning script as the **System Startup Script** in a template ensures every space created from that template is provisioned on start.

1. Create your provisioning script under **Scripts**
2. Edit the template and select the script as the **System Startup Script**

This runs first in the [execution order](../startup-scripts/#script-execution-order), before user startup scripts and file-based scripts.

### As a User Startup Script

Individual users can set a provisioning script for their own space:

```bash
knot space update myspace --startup-script my-provision
```

Or via the space settings in the web interface. This runs after the template startup script.

### On Demand

Run a provisioning script in a running space at any time:

```bash
knot space run-script myspace provision-environment
```

This is useful for re-applying configuration after manual changes, or for one-time setup tasks.

---

## Example: Development Environment

A provisioning script that sets up a complete development environment:

```python
import scriptling.provision.file as file

file.ensure("~/.bashrc", """# ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nano

alias ll='ls -alF'
alias gs='git status'
""")

file.ensure_directory("~/.config/git")

file.ensure("~/.config/git/ignore", """*.swp
*.swo
*~
.DS_Store
""")

file.ensure_directory("~/projects", mode=0o755)

file.ensure("~/projects/README.md", """# Projects

This directory contains project workspaces.
""")
```

---

## Example: Service Configuration

Provision configuration files for services running in the space:

```python
import scriptling.provision.file as file
import knot.vars as vars

db_host = vars.get("DB_HOST")
db_port = vars.get("DB_PORT")

file.ensure("/etc/myapp/config.yaml", f"""database:
  host: {db_host}
  port: {db_port}
  name: myapp

server:
  host: 0.0.0.0
  port: 8080
""", mode=0o640)

file.ensure_directory("/var/log/myapp", mode=0o755)

file.ensure("/etc/myapp/healthcheck.sh", """#!/bin/bash
curl -sf http://localhost:8080/health || exit 1
""", mode=0o755)
```

---

## Combining with Variables

Provisioning scripts can read [variables](../variables/) to adapt configuration per space or environment:

```python
import scriptling.provision.file as file
import knot.vars as vars

env = vars.get("ENVIRONMENT") or "development"

if env == "production":
    file.ensure("~/.config/app/settings.toml", """[server]
workers = 4
debug = false
""")
else:
    file.ensure("~/.config/app/settings.toml", """[server]
workers = 1
debug = true
""")
```

---

## Best Practices

1. **Keep scripts idempotent**: `scriptling.provision.file` is idempotent by design -- use it instead of shell commands for file operations
2. **Use template-level for shared config**: Set provisioning as the template startup script for configuration common to all spaces
3. **Use user-level for personalization**: Let users set their own provisioning script for individual customizations
4. **Log changes**: Check return values to log what was created or updated
5. **Use variables for per-space config**: Read variables to make provisioning scripts adapt to different environments

---

## What's Next

- [scriptling.provision.file Reference](../scripting/libraries/provision-file/) - Full API documentation
- [Startup & Shutdown Scripts](startup-scripts/) - Script execution lifecycle
- [Variables](../variables/) - Per-space and global configuration
- [Script Examples](../scripting/examples/) - More scriptling examples
