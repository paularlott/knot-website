---
title: Startup & Shutdown Scripts
weight: 200
---

Knot provides multiple ways to run scripts when spaces start or stop. These scripts can automate configuration, initialization, and cleanup tasks.

---

## Script Types

### Container Scripts (File-Based)

When using **knot**-supplied container images, startup scripts are executed automatically during container initialization:

1. **System-Level Scripts**: Scripts in `/etc/knot-startup.d/` are executed as `root`. Ideal for configuring system-level settings or services.

2. **User-Specific Scripts**: Scripts in `.knot-startup.d/` within the user's home directory are executed as the user. Useful for user-specific configurations.

### Template Startup/Shutdown Scripts

Templates can define scripts that run when spaces are created from them:

- **Startup Script**: Runs when a space starts
- **Shutdown Script**: Runs when a space stops

These are configured in the template settings and stored in the knot database. They execute using the scriptling runtime.

### User Startup Scripts

Individual spaces can have a user-defined startup script that runs on space start. This allows users to customize their space initialization without modifying the template.

---

## Configuring Template Scripts

### Via Web Interface

1. Navigate to the template editor
2. Select the "Startup/Shutdown" section
3. Add your startup and/or shutdown scripts

### Via API

```bash
curl -X PUT https://knot.example.com/api/templates/my-template \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "startup_script_id": "script-uuid",
    "shutdown_script_id": "script-uuid"
  }'
```

---

## User Startup Scripts

Users can set a custom startup script for their space:

### Via Web Interface

1. Navigate to the space settings
2. Select "Startup Script"
3. Choose or create a script to run on startup

### Via CLI

```bash
# Set a user startup script
knot space update myspace --startup-script my-init-script
```

---

## Script Execution Order

When a space starts, scripts run in this order:

1. Template startup script (if configured)
2. User startup script (if configured)
3. Container file-based scripts in `/etc/knot-startup.d/`
4. Container file-based scripts in `~/.knot-startup.d/`

When a space stops:

1. Template shutdown script (if configured)

---

## Script Examples

### Startup Script

```python
import knot.space as space
import knot.vars as vars

# Get configuration
api_key = vars.get("API_KEY")

# Initialize the space
print("Initializing space...")

# Set up environment
space.run_script("setup-environment", api_key["value"])
```

### Shutdown Script

```python
import knot.space as space

# Clean up before shutdown
print("Cleaning up...")

# Save any pending data
space.run("myspace", "sync")
```

---

## Available Libraries

Startup and shutdown scripts run in the **Remote** environment with access to:

- All `knot.*` libraries (space, ai, mcp, etc.)
- Standard scriptling libraries
- Extended libraries (os, pathlib, subprocess, etc.)

See [Scripting Environments](../scripting/environments/) for complete library availability.

---

## Best Practices

1. **Keep scripts idempotent**: Scripts should handle being run multiple times safely
2. **Handle errors gracefully**: Use try/except to catch and log errors
3. **Log progress**: Print statements are captured in space logs
4. **Use variables**: Store configuration in variables rather than hardcoding
5. **Test thoroughly**: Test scripts manually before configuring them as startup/shutdown scripts
