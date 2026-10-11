# Knot OKF Bundles

OKF 0.2 knowledge bundles generated from the [Knot documentation](https://getknot.dev/docs/). Fetch these URLs directly; every document is plain markdown with YAML frontmatter and relative links.

## Bundles

- [knot-docs](knot-docs/index.md) — Guides: quick start, configuration, spaces, templates, scripting, AI integration, and tutorials.
- [knot-reference](knot-reference/index.md) — Technical reference: architecture, CLI, events, scripting libraries, API tokens, and glossary.

## Use with an MCP server

To give an AI agent browse and search tools over these bundles, serve them with [OKF Server](https://github.com/paularlott/okf-server). Download [`knot-okf-bundles.zip`](https://github.com/paularlott/knot-website/releases/latest/download/knot-okf-bundles.zip) from the latest release and unzip it into the server's bundle directory:

```sh
unzip knot-okf-bundles.zip -d /path/to/bundles
scriptling --package /path/to/okf-server -- --bundles /path/to/bundles
```
