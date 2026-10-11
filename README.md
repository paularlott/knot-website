# knot website

Source for [getknot.dev](https://getknot.dev), the knot documentation site. It is built with [Hugo](https://gohugo.io/) (extended, 0.150.0 or later) and Tailwind CSS. Pages live in `content/`, layouts and shortcodes in `layouts/`.

## Local development

Install the Node dependencies (Tailwind, Mermaid, Redoc, FlexSearch) once, then run the Hugo dev server:

```sh
npm install
hugo server --buildDrafts --disableFastRender
```

The site is served at <http://localhost:1313/>.

## Building

```sh
task build
```

This runs `hugo` and writes the site to `public/`. Extra Hugo flags can be passed with `HUGO_ARGS`, for example `HUGO_ARGS="--destination /tmp/site" task build`.

## OKF knowledge bundles

The docs are also published as OKF knowledge bundles at `/okf/`. The bundles are generated into `okf/` by a [scriptling](https://scriptling.dev/) script and committed, since the hosted build runs Hugo only.

| Command | What it does |
|---|---|
| `make okf` | Regenerate the bundles in `okf/` (run after changing `content/`, then commit) |
| `make mcp-server` | Run the knot KB MCP server locally on `:8765` |
| `make pack` | Build `dist/knot-kb.zip`: the KB MCP server plus the bundles |
| `make bundle-pack` | Build `dist/knot-okf-bundles.zip`: the bundles only |
| `make release` | Regenerate and commit the bundles, push, then tag and publish a GitHub release with both zips, versioned from `../knot` |
| `make api-spec` | Copy the OpenAPI spec from `../knot-pro-src` into `static/api-reference/` |

Run `make` on its own to list the targets.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Contributions require accepting the [Contributor License Agreement](CONTRIBUTOR_LICENSE_AGREEMENT.md).
