---
title: Startup Scripts
weight: 110
---

When using **knot**-supplied container images, startup scripts are executed automatically during container initialization. These scripts are run in the following order:

1. **System-Level Scripts**:
   Any scripts located in the `/etc/knot-startup.d/` directory are executed as `root`. These are ideal for configuring system-level settings or services.

2. **User-Specific Scripts**:
   After system-level scripts, any scripts found in the `.knot-startup.d/` directory within the user's home directory are executed as the user. These scripts are useful for user-specific configurations or tasks.

This dual-layer approach allows for both system-wide and user-specific customizations to be applied seamlessly when the container starts.
