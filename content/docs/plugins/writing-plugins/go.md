---
title: In Go
description: Ship Go components as scriptling plugin-protocol peers in the plugin's bin/ folder.
type: Guide
tags: [plugins, go, scripting]
weight: 20
---

Some things a script can't do: FFI, a proprietary SDK, a perf-critical loop. For those, a plugin folder carries **binary peers** - executables speaking scriptling's plugin protocol (JSON-RPC over stdio) - in its `bin/` folder.

A peer is a *component of the plugin*, never a plugin by itself: **the declarations still live in `main.py`** - permissions, menus, pages, logos - and the peer is only reachable through the plugin's handlers as `import plugin.<name>`. knot spawns and handshakes each peer at plugin load (bounded by a timeout - a broken binary can't stall boot), and its declared name and version verify the metadata dependency. Peer health shows on the [admin plugins page](../../managing/).

The same pattern works for any language with JSON-RPC - C, PHP, even bash - using scriptling's [plugin SDKs](https://scriptling.dev/docs/plugins/); this page shows Go.

## Declaring the dependency

The metadata block's existing dependency keys cover peers - no new syntax. A plugin whose logic is mostly Go still has a small `main.py`:

```python
# /// script
# requires-scriptling = ">=0.24"
# dependencies = [
#   "plugin.demolib via demolib >= 1.0.0",
# ]
#
# [tool.knot]
# version = "1.0.0"
# description = "Status page backed by a Go peer."
# permissions = ["view_status"]
#
# [[tool.knot.pages]]
# path = "/status"
# handler = "status"
# permission = "view_status"
# menu_label = "Status"
# icon = "assets/chip.svg"
# ///

def status():
    import plugin.demolib as demolib
    return demolib.status()
```

If the binary is missing or too old, the plugin fails its requirements at load and is listed as failed with the reason.

## The peer

```go
// peer/main.go
package main

import (
	"runtime"

	"github.com/paularlott/scriptling/object"
	"github.com/paularlott/scriptling/plugin"
)

func main() {
	server := plugin.NewServer("demolib", "1.0.0", "Demo peer.")
	server.RegisterFunc("status", object.NewFunctionBuilder().FunctionWithHelp(func() map[string]any {
		return map[string]any{"os": runtime.GOOS, "arch": runtime.GOARCH}
	}, "status() - report the peer's build."))
	server.RegisterFunc("greeting", object.NewFunctionBuilder().FunctionWithHelp(func(name string) string {
		return "hello " + name + ", from a Go peer inside knot"
	}, "greeting(name) - return a greeting."))
	if err := server.Run(); err != nil {
		panic(err)
	}
}
```

Classes work the same way - construct, hold state, call methods, all over the plugin protocol (this is demo-go's `Counter`, exercised by its `peer_class` handler):

```go
type counter struct {
	step int
	n    int
}

server.RegisterClass(object.NewClassBuilder("Counter").
	Constructor(func(step int) *counter {
		return &counter{step: step}
	}).
	Method("next", func(self *counter) int {
		self.n += self.step
		return self.n
	}).
	Method("value", func(self *counter) int {
		return self.n
	}))
```

`NewServer`'s first argument is the name scripts import (`plugin.demolib`) and the name the metadata dependency references; the second is the version the `>= 1.0.0` constraint checks. Register functions, classes, and constants with the server builders - see the [scriptling Go integration guide](https://scriptling.dev/docs/go-integration/plugins/) for the full surface.

Build it into `bin/` (a sibling `Makefile` keeps this one line):

```make
peer:
	cd peer && go build -o ../bin/demolib_$(GOOS)_$(GOARCH) .
```

## Packaging shapes

Peers ship in one of three shapes - a package never mixes a bare binary with variants of the same peer:

| Shape | Files in `bin/` | knot loads |
|---|---|---|
| Single binary | `mypeer[.exe]` | the bare binary, unconditionally |
| Platform bundle (one OS, both arches) | `mypeer_arm64[.exe]`, `mypeer_amd64[.exe]` | this host's arch variant |
| Universal bundle (all OSes, both arches) | `mypeer_linux_arm64`, `mypeer_windows_amd64.exe`, … | this host's exact variant |

The universal bundle's `_goos_goarch` naming is goreleaser's default artifact name, so release builds drop in unrenamed. Cross-compile by setting `GOOS`/`GOARCH`.

## Trust

Peers are admin-installed binaries running outside the scriptling sandbox - the same trust class as the plugin folder itself. The script environment holds the user identity and performs every `knot.*` call; the peer receives data, never credentials. Permissions are checked before any handler runs: **a binary extends what a plugin can compute, not what a user can reach.**
