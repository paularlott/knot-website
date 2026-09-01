---
description: Ready-to-use knot space templates for Nomad, Docker, and Podman.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/tutorials/example-templates/
sources:
    - resource: https://getknot.dev/docs/tutorials/example-templates/
status: stable
tags:
    - templates
    - deployment
title: Example Templates
type: Overview
---
# Example Templates

This section provides an overview of example templates available for creating spaces. These templates support Nomad with both Docker and Podman, as well as local Knot servers running Docker or Podman.

- **[Ubuntu](example-templates/ubuntu.md)**: A simple Ubuntu environment for general use.
- **[Ubuntu Desktop](example-templates/ubuntu-desktop.md)**: An Ubuntu-based desktop environment running XFCE, ideal for lightweight graphical applications.
- **[Valkey](example-templates/valkey.md)**: A Valkey server template, accessible from the desktop via port forwarding.
- **[MariaDB](example-templates/mariadb.md)**: A template for running a MariaDB server within a space, suitable for database management and development.
- **[PHP with Caddy](example-templates/ubuntu-php.md)**: A template for running PHP with a Caddy server. The `public_html` folder is exposed via the Knot web interface, making it easy to serve web content.
