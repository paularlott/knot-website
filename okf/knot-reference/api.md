---
description: HTTP API reference — the REST API used by the CLI, web interface, and third-party integrations.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/api/
sources:
    - resource: https://getknot.dev/reference/api/
status: stable
tags:
    - api
title: API
type: Overview
---
# API

The HTTP API reference ships with the knot executable and is served by every knot server at `/api-docs` (for example `https://knot.internal:3000/api-docs`), so it always matches the version you are running. It covers the REST API used by the CLI, the web interface and third-party integrations; authentication is with a bearer token passed in the `Authorization` header.
