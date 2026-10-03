# Same Script, No Tokens: Running knot Scripts with scriptling

*With knot and scriptling, a script is authored once in the knot web interface and runs unchanged from your desktop or inside any environment, and the credentials never touch the script itself.*

---

Every developer collects helper scripts. The one that checks which of your environments are still running. The one that resets the database in your dev space. The one that seeds test data before a QA pass. They end up in `~/bin`, or inside a space that got deleted last month, or half-documented in a Slack thread. And none of them can talk to the knot API without a token being pasted somewhere you'd rather it wasn't.

knot (a self-hosted cloud development environment orchestrator) and scriptling (a Python-like scripting language that ships as a single binary) take a different approach: **scripts live on the server, are written in the web interface, and run unchanged anywhere**, from your desktop, from inside any of your environments, or triggered by automation.

There are actually two ways to run a script in knot. The agent that runs inside every space embeds a scriptling runtime directly, which is what makes `knot space run-script <name>` work with nothing installed. That's the lightweight path. The other path is the full scriptling CLI, everything including the kitchen sink, using knot as a plugin to reach the same scripts you wrote in the knot UI, from your desktop or from inside a space. This article is about that second path: writing a script in the browser, running it from your laptop with `scriptling --plugin knot`, then running the same script inside a space.

## scriptling, in a glance

[scriptling](https://scriptling.dev/) is a Python-inspired scripting language, implemented in Go, that ships as a single binary. The syntax is deliberately ordinary Python: indentation blocks, `import`, familiar standard libraries (`json`, `re`, `time`, `math`) loaded on demand. It's sandboxed by design, a script only reaches the filesystem, the network, or the OS through libraries the host chooses to expose. knot is one such host: the agent embeds the scriptling runtime directly, which is the lightweight path mentioned above.

scriptling is also embeddable in your own Go applications (`go get github.com/paularlott/scriptling`), with direct type mapping between the language and Go, but that's a separate story.

Install it the usual way:

```bash
brew install paularlott/tap/scriptling
```

If you can write Python, you can write scriptling. That's all the language background this article needs.

## Step 1: write the script in the knot web interface

In knot's web UI, open **Scripts → New Script**. You get a name, a description, the content, an active flag, and a **type**, which is the interesting field:

- **`script`**: a standard executable script
- **`lib`**: a library module, importable by other scripts (`import mylib`)
- **`tool`**: an MCP tool, exposed to AI assistants (a story for another article)

Scripts are stored on the knot server and available throughout the cluster. Global scripts serve everyone; your user scripts shadow same-named globals, so you can override team behaviour without touching the shared version.

The `knot.*` libraries give scripts the platform surface: `knot.space` for creating, listing, starting and stopping spaces and running commands in them, `knot.user` and `knot.group` for identity, `knot.template` for templates, `knot.vars` for variables, `knot.volume` for volumes, `knot.event` for emitting events, twenty-odd modules in all. The interesting part is what isn't there: no base URL, no auth code, no HTTP client setup. The platform is just there.

So let's say we write `deploy_check`, a script that uses knot's own `knot.space` library to look at the state of our spaces:

```python
import knot.space as space

for s in space.list():
    print(f"{s['name']}: {'running' if s['is_running'] else 'stopped'}")
```

Nothing in it is desktop-specific or space-specific. That's the point: where it *runs* is decided later, and the answer can be different every day.

## Step 2: the knot plugin, `scriptling --plugin knot`

Here's the piece that glues the two projects together. The scriptling CLI can load plugins: external binaries that speak JSON-RPC over stdio and, through that one channel, provide libraries, API access, and even custom URL schemes. As of knot 0.33.0, **the knot binary doubles as a scriptling plugin**.

```bash
scriptling --plugin knot knot://deploy_check
```

That's it: that's running a script stored on the knot server, from your laptop. Notice what scriptling itself was never given: no server URL, no token, no knot configuration of any kind. Everything crosses the plugin channel. Three things, specifically:

1. **The plugin owns the `knot://` scheme.** Scripts stored on the server resolve as `knot://name` sources, fetched by the plugin. They're always re-fetched before running, the host never caches what a plugin serves, so you never execute a stale copy of a script you just edited.
2. **`knot.*` libraries come from the plugin.** `import knot.space` and friends load from copies embedded inside the knot binary. No packages to download, nothing installed beyond the two binaries you already have.
3. **API calls travel through the plugin process.** When `knot.space.list()` talks to the server, the library doesn't open a connection itself: it asks the plugin over the same JSON-RPC channel, and the plugin makes the HTTP call using credentials it manages. Your API token never appears in a script, an environment file, or a command line, scriptling never sees it at all.

That third point is the design decision worth pausing on. Rather than hand a script a token and wish it luck, the credentials stay in the knot process the whole time: scripts call `knot.*`, the plugin does the talking. There's exactly one place a connection is ever configured, and it's the place you already manage, `knot connect` on your desktop, the agent in a space.

`--plugin knot` works the same shape whether the target is a script stored on the server, a local file, or code typed straight into the command:

```bash
# A local script that imports the knot libraries:
scriptling --plugin knot myscript.py

# Inline code, no file at all:
scriptling --plugin knot -c 'import knot.space; print(knot.space.list())'

# Import a library script you wrote in the web UI (type: lib):
scriptling --plugin knot -c 'import mylib; mylib.do_something()'
```

If you manage more than one knot server, the plugin also understands aliases: `scriptling --plugin knot --plugin-arg=--alias=work knot://deploy_check` runs against whichever server you connected to as `work` via `knot connect --alias`. The script and the invocation don't change, only which server it talks to.

Bare `--plugin knot` works because scriptling resolves plugin names through `PATH`. The knot binary also detects when scriptling has spawned it (scriptling sets a `SCRIPTLING_PLUGIN_PEER` environment variable carrying its version) and diverts into plugin mode without needing a subcommand. A full path works too: `--plugin /usr/local/bin/knot`. The two peers check versions at handshake, knot needs scriptling 0.24.0 or later, so an environment with an older CLI baked in is the one case to watch for.

## The same command, two worlds

The detail I like most: `scriptling --plugin knot` **works in a space or on the desktop**, and the connection takes care of itself.

- **On the desktop**, the plugin uses the credentials saved by `knot connect`: by default the `default` alias, or whichever alias you pass via `--plugin-arg=--alias --plugin-arg=<name>`.
- **Inside a space**, the connection comes from the agent: the script runs with the space's own context, and the alias flag is ignored because there's nothing to choose.

Same script, same invocation, no branching on where you happen to be.

## Running inside a space

A space built on a [Scriptling base image](https://getknot.dev/docs/templates/base-images/) (`paularlott/knot-scriptling`) has the full scriptling CLI preinstalled, so from a terminal inside the space the same command works:

```bash
scriptling --plugin knot knot://deploy_check
```

The neat part is that the plugin binary is already there too. Every space runs a knot agent, and the agent *is* the knot binary: the space's entrypoint installs it to `/usr/local/bin/knot` when the space boots. So `--plugin knot` resolves on `PATH`, the plugin notices it's inside a space, and it takes its connection from the agent, no URLs, no tokens, no setup. Your scripts and `lib` libraries arrive exactly the way they did on the desktop: fetched from the server by the plugin.

There's a second way to get the libraries, worth knowing about even outside the version-compatibility case: the agent also serves the knot.* libraries and your lib scripts as zip packages on its local port, cached and refreshed automatically. This was the original method, predating the plugin, and it's still there for when you want the libraries without pulling in the full plugin. It's also what covers you on images older than scriptling 0.24.0, where the plugin can't load. Same destination, different road, [the docs](https://getknot.dev/docs/scripting/using-libraries/) cover both.

And a space doesn't even need the CLI for most of this. The agent embeds the scriptling runtime, so startup scripts, health checks and `knot space run-script` run your scripts with nothing extra installed. The CLI is there for the interactive parts: the terminal, the REPL, ad-hoc runs while you develop.

## Wrapping up

The result of all this is a scripting setup with no glue code and no scattered credentials, and one that can be shared with other developers: a shared script just works for them, with their own connection supplying their own credentials.

- Scripts are **authored in the web interface**.
- They **run anywhere**: `scriptling --plugin knot` on your desktop or in a space, same command, same scripts.
- They **share with the team**: mark a script global and any developer on the server can run it. Each person's plugin connection carries their own credentials, so there's nothing to hand out and nothing to rotate when someone joins or leaves.
- Libraries and API access **come through the plugin**, so tokens stay out of scripts and revoking access is a server-side operation.

If you want to go deeper:

- Scripting in knot: https://getknot.dev/docs/scripting/
- The knot plugin and libraries: https://getknot.dev/docs/scripting/using-libraries/
- scriptling language and CLI: https://scriptling.dev/
