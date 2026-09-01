---
description: Technical reference for knot — architecture, CLI, scripting libraries, events, API tokens, and glossary.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/
sources:
    - resource: https://getknot.dev/reference/
status: stable
tags:
    - api
    - architecture
    - scripting
title: Reference
type: Overview
---
# Reference

Technical reference documentation for Knot.

## [CLI Reference](cli.md)

The main `knot` command run from your machine, and the in-space `knot agent` — spaces, stacks, templates, scripts, forwarding, the server, lifecycle, events, and methods.

## [Architecture](architecture.md)

knot's architecture, deployment modes, network design, and scaling strategies.

## [Library Reference](libraries.md)

The `knot.*` scripting libraries exposed to Scriptling — space, template, user, volume, stack, and more — plus the bundled `scriptling.*` helpers available in knot's execution environments.

## [Events](events.md)

The events system: webhook sinks, script sinks, and JSON-RPC sinks for reacting to space lifecycle and custom events.

## [API](api.md)

The HTTP API used by the CLI, the web interface, and third-party integrations — rendered from the same OpenAPI spec that powers the in-product `/api-docs` page.

## [Glossary](glossary.md)

Definitions of terms and concepts used throughout knot documentation.
