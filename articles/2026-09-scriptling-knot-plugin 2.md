# Write Scripts in the Browser, Run Them Anywhere

*With knot and scriptling, a script is authored once in the knot web interface and runs unchanged from your desktop or inside any environment. One binary makes it work.*

---

Every developer collects helper scripts. The one that checks which of your environments are still running. The one that resets the database in your dev space. The one that seeds test data before a QA pass. They end up in `~/bin`, or inside a space that got deleted last month, or half-documented in a Slack thread. And none of them can talk to the knot API without a token being pasted somewhere you'd rather it wasn't.

knot (a self-hosted cloud development environment orchestrator) and scriptling (a Python-like scripting language that ships as a single binary) take a different approach: **scripts live on the server, are written in the web interface, and run unchanged anywhere**, from your desktop, from inside any of your environments, or triggered by automation.

This article walks the whole path: write a script in the browser, run it from your laptop with `scriptling --plugin knot`, then run the same script inside a space.

## scriptling in one minute

If you haven't met it: [scriptling](https://scriptling.dev/) is a Python-inspired scripting language implemented in Go. The syntax is deliberately ordinary Python: indentation blocks, `import`, familiar standard libraries (`json`, `regex`, `time`, `requests`) loaded on demand. It's sandboxed (no filesystem or network access unless explicitly granted), it runs from a single binary, and it was designed both for humans and for LLM agents to write.

One capability belongs on the headline list: scriptling is embeddable in Go applications. The interpreter ships as a Go library (`go get github.com/paularlott/scriptling`), with direct type mapping between the language and Go, so your own apps can host a sandboxed scripting engine and expose exactly the libraries you choose. knot itself is the proof: the agent embeds the scriptling runtime, which is why a space can run scripts with nothing extra installed.

Install it the usual way:

```bash
brew install paularlott/tap/scriptling
```

If you can write Python, you can write scriptling. That's all the language background this article needs.

## Step 1: write the script in the knot web interface

In knot's web UI, open **Scripts → New Script**. You get a name, a description, the code, an active flag, and a **type**, which is the interesting field:

- **`script`**: a standard executable script
- **`lib`**: a library module, importable by other scripts (`import mylib`)

Scripts are stored on the knot server. Global scripts serve everyone; your personal scripts shadow globals with the same name, so you can override team behaviour without touching the shared version, the same override model templates and variables use.

The `knot.*` libraries give scripts the platform surface: `knot.space` for creating, listing, starting and stopping spaces and running commands in them, `knot.user` and `knot.group` for identity, `knot.template` for templates, `knot.vars` for variables, `knot.volume` for volumes, `knot.event` for emitting events. The interesting part is what isn't there: no base URL, no auth code, no HTTP client setup. The platform is just there.

So let's say we write `deploy_check`, a script that uses knot's own `knot.space` library to look at the state of our spaces:

```python
import knot.space as space

for s in space.list():
    print(f"{s['name']}: {'running' if s['is_running'] else 'stopped'}")
```

Nothing in it is desktop-specific or space-specific. That's the point: where it *runs* is decided later, and the answer can be different every day.

## Step 2: the knot plugin, `scriptling --plugin knot`

Here's the piece that glues the two projects together. The scriptling CLI can load plugins: external binaries that provide libraries, API access, and even custom URL schemes over JSON-RPC. As of knot 0.33, **the knot binary doubles as a scriptling plugin**.

```bash
scriptling --plugin knot knot://deploy_check
```

That's it: that's running a script stored on the knot server, from your laptop. Three things are happening under the hood:

1. **The plugin owns the `knot://` scheme.** Scripts stored on the server resolve as `knot://name` sources. They're always re-fetched before running, so you never execute a stale copy of a script you just edited.
2. **`knot.*` libraries come from the plugin.** `import knot.space`, `knot.user`, `knot.template` and friends load from embedded copies inside the knot binary: no packages to download, no `--package` flags.
3. **API calls route through the plugin process.** When `knot.space.list()` talks to the server, it goes through the plugin's transport, using credentials the plugin manages. Your API token never appears in a script, an environment file, or a command line.

A few more shapes the plugin takes:

```bash
# A local script that imports the knot libraries:
scriptling --plugin knot myscript.py

# Inline code, no file at all:
scriptling --plugin knot -c 'import knot.space; print(knot.space.list())'

# Import a library script you wrote in the web UI (type: lib):
scriptling --plugin knot -c 'import mylib; mylib.do_something()'

# Talk to a different server (see `knot connect --alias`):
scriptling --plugin knot --plugin-arg --alias work knot://deploy_check
```

Bare `--plugin knot` works because scriptling resolves plugin names through `PATH`. The knot binary also detects when scriptling has spawned it (scriptling sets a `SCRIPTLING_PLUGIN_PEER` environment variable carrying its version) and diverts into plugin mode without needing a subcommand. A full path works too: `--plugin /usr/local/bin/knot`.

## The same command, two worlds

The detail I like most: `scriptling --plugin knot` **works in a space or on the desktop**, and the connection takes care of itself.

- **On the desktop**, the plugin uses the credentials saved by `knot connect`: by default the `default` alias, or whichever alias you pass via `--plugin-arg=--alias --plugin-arg=<name>`.
- **Inside a space**, the connection comes from the agent: the script runs with the space's own context, and the alias flag is ignored because there's nothing to choose.

Same script, same invocation, no branching on where you happen to be.

## Running inside a space

Spaces built on a [Scriptling base image](https://getknot.dev/docs/templates/base-images/) (`paularlott/knot-scriptling`) have the full scriptling CLI preinstalled, and from a terminal inside the space, `scriptling --plugin knot` works exactly as on your desktop:

```bash
scriptling --plugin knot knot://deploy_check
```

The agent serves the knot libraries and your `lib` scripts to the binary as packages, cached and refreshed automatically when they change, and auto-configures `knot.apiclient` so the script acts with the space's own identity: no URLs, no tokens, no setup.

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
