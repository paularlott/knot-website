---
title: In Go
description: Ship a plugin as a Go peer - manifest and handlers served from the handshake, no companion main.py.
type: Guide
tags: [plugins, go, scripting]
weight: 20
---

A plugin folder carries **binary peers** - executables speaking scriptling's plugin protocol (JSON-RPC over stdio) - in its `bin/` folder. A peer is where you put what a script can't do: FFI, a proprietary SDK, a perf-critical loop. But a peer can also be the *whole plugin*: it serves both the plugin's declarations and its handlers from the handshake, and it can even serve the declared assets from its own fetcher (below) - so a folder with only `bin/` and **no `main.py` and no `assets/`** is a complete plugin: one binary, nothing else.

knot spawns and handshakes each peer at plugin load (bounded by a timeout - a broken binary can't stall boot), reads its manifest and version there, and exposes its functions to handlers as `plugin.<name>`. Peer health shows on the [admin plugins page](../../managing/).

The same pattern works for any language with JSON-RPC - C, PHP, even bash - using scriptling's [plugin SDKs](https://scriptling.dev/docs/plugins/); this page shows Go.

## Two ways to use a peer

- **Pure peer plugin (no `main.py`).** The peer returns the `[tool.knot]` manifest at handshake and exports every declared handler. `demo-go` is this shape with a Go binary; `demo-scriptlingcli2` is the same shape with a scriptling script the CLI runs ([scriptling peers](../scriptling/#scriptling-binary-peers)) — the model is language-agnostic. Covered below.
- **Scriptling handlers backed by a peer (`main.py` + `bin/`).** The plugin keeps a `main.py` whose scriptling handlers `import plugin.<name>` to drive the peer's compute — wrap the peer and extend it with page logic, presentation and gates. The manifest lives in `main.py`. `demo-scriptlingcli` is this shape. The peer side is identical; only where the manifest and handlers live differs.

## The manifest lives in the peer

A peer returns its `[tool.knot]` table as **static manifest data in the handshake** - `SetMetadata` with a `"tool.knot"` key. knot reads it (`Client.Metadata().Custom["tool.knot"]`) and parses it with exactly the same code a pure-script plugin's metadata block goes through. It is a **constant** the peer returns; it must not vary with runtime state, and no handler runs to produce it - so boot stays graceful and every cluster node computes the same result.

```go
// peer/main.go
package main

import (
	"runtime"

	"github.com/paularlott/scriptling/object"
	"github.com/paularlott/scriptling/plugin"
)

// manifest is the plugin's [tool.knot] table. Nested tables become maps and
// slices; knot parses it identically to a main.py metadata block.
func manifest() map[string]any {
	return map[string]any{
		"tool.knot": map[string]any{
			"version":     "1.0.0",
			"description": "Status page backed by a Go peer.",
			"permissions": []any{"view_status"},
			"logo_light":  "assets/logo-light.svg",
			"pages": []any{
				map[string]any{
					"path":       "/status",
					"handler":    "status_page",
					"label":      "Status",
					"menu_label": "Status",
					"permission": "view_status",
					"icon":       "assets/chip.svg",
				},
			},
			"handlers": []any{
				map[string]any{"handler": "peer_summary"},
			},
		},
	}
}

func main() {
	server := plugin.NewServer("demolib", "1.0.0", "Demo peer.")
	server.SetMetadata(manifest())
	// ... register handlers and composable exports (below) ...
	if err := server.Run(); err != nil {
		panic(err)
	}
}
```

`NewServer`'s first argument is the peer's handshake name - the namespace its handlers and exports live under (`plugin.demolib.*`) and the name a dependency constraint references. Requires scriptling **0.24.4+** (the release that added handshake custom metadata); a plugin can declare `requires_knot`/`requires-scriptling` bounds in the manifest just as a `main.py` would.

## Handlers are Go functions taking `request`

Every handler the manifest names is a registered function that takes the `request` dict knot passes to every handler - `{method, path, params, user}`. It returns the same shapes a scriptling handler returns (a page layout, a column payload, an action envelope). knot addresses them as `plugin.demolib.<fn>`.

```go
// The page handler named by [[tool.knot.pages]].handler.
server.RegisterFunc("status_page", object.NewFunctionBuilder().FunctionWithHelp(
	func(request map[string]any) map[string]any {
		return map[string]any{
			"rows": []any{
				map[string]any{"columns": []any{
					map[string]any{"id": "sum", "type": "text", "handler": "peer_summary"},
				}},
			},
		}
	}, "status_page(request) - the /status dashboard layout."))

// A [[tool.knot.handlers]] handler. request carries the caller's data.
server.RegisterFunc("peer_summary", object.NewFunctionBuilder().Function(
	func(request map[string]any) map[string]any {
		params := map[string]any{}
		if p, ok := request["params"].(map[string]any); ok {
			params = p
		}
		user := request["user"].(map[string]any) // inert data (see below)
		return map[string]any{
			"summary": "demolib on " + runtime.GOOS + "/" + runtime.GOARCH,
			"who":     user["name"],
			"filter":  params["q"],
		}
	}))
```

## Composable exports

A peer can also register a plain library surface - functions, classes, constants - that *other installed plugins* import as `plugin.demolib.*` for [in-process composition](../scriptling/#composition). This is the same registration; it just isn't named as a handler in the manifest. `demo-go` ships `status()`, `greeting(name)` and a stateful `Counter` class this way:

```go
server.RegisterFunc("greeting", object.NewFunctionBuilder().FunctionWithHelp(
	func(name string) string { return "hello " + name + ", from a Go peer inside knot" },
	"greeting(name) - return a greeting."))

// A class: construct, hold state, call methods, all over the protocol. The
// host auto-builds a stub from the handshake schema; the state lives in the
// peer process.
type counter struct{ step, n int }

server.RegisterClass(object.NewClassBuilder("Counter").
	Constructor(func(step int) *counter { return &counter{step: step} }).
	Method("next", func(self *counter) int { self.n += self.step; return self.n }).
	Method("value", func(self *counter) int { return self.n }))
```

Another plugin's handler then does `import plugin.demolib as demolib; demolib.greeting("knot")` - the state living in the peer process. Composition is trusted-plugin-to-trusted-plugin only: the plugin pool is not attached to user-created MCP tools, so a user tool cannot import a peer's surface - it reaches a plugin only through the gated loopback ([`knot.plugin.call`](../mcp-tools/#the-trust-boundary-import-vs-call)). See the [scriptling Go integration guide](https://scriptling.dev/docs/go-integration/plugins/) for the full builder surface.

## Building into `bin/`

```make
peer:
	cd peer && go build -o ../bin/demolib_$(GOOS)_$(GOARCH) .
```

## Single binary: assets from the peer

A peer can serve the plugin's declared assets from a **fetcher**, so the icon and logo live inside the binary - one file to ship, no `assets/` folder at all:

```go
//go:embed assets
var embeddedAssets embed.FS

type assetFetcher struct{}

func (assetFetcher) Read(ctx context.Context, source, path string) ([]byte, error) {
	data, err := embeddedAssets.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("%w: %s", plugin.ErrFetchNotFound, path)
	}
	return data, nil
}

func (assetFetcher) Glob(ctx context.Context, source, pattern string) ([]plugin.FetchEntry, error) { /* fs.Glob over the embed FS */ }

server.RegisterFetcher("demolib", assetFetcher{})
```

At load, knot reads each declared asset **peer-first** - the first peer advertising a fetcher, addressed at its scheme root with the declared path - and falls back to the plugin folder on disk for anything the fetcher misses (or when there is no peer). Peer-served bytes are fetched once and served from memory; disk assets stream from disk as before. The disk file remains the last word on existence: a sick peer can only degrade to disk, never invent an asset. The declared paths in the manifest (`"icon": "assets/chip.svg"`) are the same either way - only where the bytes come from differs. `demo-go` ships this shape: its icon and logo are embedded in the peer, and the plugin folder is `bin/` alone.

## Packaging shapes

Peers ship in one of three shapes - a package never mixes a bare binary with variants of the same peer:

| Shape | Files in `bin/` | knot loads |
|---|---|---|
| Single binary | `mypeer[.exe]` | the bare binary, unconditionally |
| Platform bundle (one OS, both arches) | `mypeer_arm64[.exe]`, `mypeer_amd64[.exe]` | this host's arch variant |
| Universal bundle (all OSes, both arches) | `mypeer_linux_arm64`, `mypeer_windows_amd64.exe`, … | this host's exact variant |

The universal bundle's `_goos_goarch` naming is goreleaser's default artifact name, so release builds drop in unrenamed. Cross-compile by setting `GOOS`/`GOARCH`.

## The requesting user: data across the wire

`request["user"]` is a plain **dict** - `id`, `name`, `is_admin`, `groups`, `permissions`, `plugin_permissions` - so it marshals across the plugin protocol natively and a peer handler reads it directly:

```go
server.RegisterFunc("report", object.NewFunctionBuilder().Function(
	func(request map[string]any) map[string]any {
		user := request["user"].(map[string]any)
		if !user["is_admin"].(bool) {
			return map[string]any{"error": "admins only"}
		}
		return map[string]any{"for": user["name"]}
	}))
```

This is *identity as data*: a snapshot for branching, carrying no authority. The plugin protocol only ever moves plain values (strings, numbers, bools, lists, dicts), so a capability object never leaves the host - the peer cannot act *as* the user. When a call genuinely needs to act with the user's authority, the authoritative surface is `knot.identity` / the `knot.*` libraries, which live host-side and round-trip over the gated loopback; a Go peer composes those by calling back through a scriptling handler, not by holding a credential. The metadata gates remain the enforcement boundary knot applies before any handler runs.

## Logging

A peer logs through the host, not to its own stderr: `plugin.Logger(ctx)` returns a proxy that forwards records over the protocol to knot's logger, where they appear under the `plugins` log group alongside knot's own plugin messages. The `ctx` is the one passed to the handler call, so records are attributed to the peer:

```go
import "github.com/paularlott/scriptling/plugin"

server.RegisterFunc("report", object.NewFunctionBuilder().Function(
	func(ctx context.Context, request map[string]any) map[string]any {
		plugin.Logger(ctx).Info("building report", "user", request["user"].(map[string]any)["name"])
		return map[string]any{"ok": true}
	}))
```

A handler that takes a leading `context.Context` receives the call context (the builders accept it as an optional first parameter); without it, use the context the SDK provides. Host logging needs the bidirectional stdio transport knot uses by default. Don't write to stdout - that channel carries the JSON-RPC protocol.

## Trust

Exports can also be written in scriptling - in-process from `libs/` ([Scriptling libs](../scriptling/#scriptling-libs)) or as a shebang script in `bin/` that the scriptling CLI serves, drivers included ([Scriptling binary peers](../scriptling/#scriptling-binary-peers)). Go peers are admin-installed binaries running outside the scriptling sandbox - the same trust class as the plugin folder itself. Installed = trusted: a peer extends what a plugin can compute, not what a user can reach, and knot enforces the declared gates before any handler runs.
