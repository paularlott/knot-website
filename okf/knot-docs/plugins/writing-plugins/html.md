---
description: The trusted html column - kp-* helper classes, theme awareness, and the globals available to plugin markup.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/plugins/writing-plugins/html/
sources:
    - resource: https://getknot.dev/docs/plugins/writing-plugins/html/
status: stable
tags:
    - plugins
    - pages
title: Raw HTML
type: Guide
---
# Raw HTML

An `html` column renders exactly what its handler returns, raw. This is the one place a plugin owns markup: plugins are installed by an administrator, so their html is trusted like knot's own templates. With that trust comes freedom - inline styles, `<style>` blocks, inline SVG, [Alpine](#alpine-and-chartjs) directives - and one rule about classes, below.

```python
def col_clock(request):
    now = time.now()
    return {"html": f"""
<div class="kp-card kp-flex">
  <svg width="20" height="20" style="color:#3b82f6; flex-shrink:0" xmlns="http://www.w3.org/2000/svg"
       fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"></svg>
  <div>
    <div class="kp-label">Server time</div>
    <div class="kp-title kp-mono">{now}</div>
  </div>
</div>
"""}
```

Scriptling strings are Python-like: triple-quoted for multi-line markup, `f` prefixes for interpolation (double literal braces as `{{` `}}`).

## Classes: kp-* only

knot's Tailwind build compiles utilities **on demand from scanned markup**. Plugin html is written at runtime and never passes the scanner, so Tailwind class names in plugin markup silently do nothing - neither today's set nor any future one is safe to use. knot's own component classes (`ui-*`, `pb-*`, `nav-item`, ...) are internal implementation, not API.

The `kp-*` classes are the plugin-facing vocabulary: plain CSS that ships in every build, adapts to the light/dark themes automatically, and changes additively only.

### Text colours

| Class | Use | Light / dark |
|---|---|---|
| `kp-text` | default body text | gray-900 / gray-100 |
| `kp-muted` | secondary text, captions | gray-500 / gray-400 |
| `kp-accent` | highlight | blue-600 / blue-400 |
| `kp-success` | positive | green-700 / green-300 |
| `kp-warning` | caution | amber-700 / amber-300 |
| `kp-danger` | negative | red-700 / red-300 |
| `kp-info` | informational | blue-700 / blue-300 |

### Typography

- `kp-title` - 1.125rem semibold heading text.
- `kp-label` - small uppercase tracking-wide label, muted.
- `kp-mono` - the monospace font (JetBrains Mono).

### Layout

- `kp-card` - bordered, rounded, tinted panel (the inner-card treatment).
- `kp-flex` - horizontal flex with centered items and `0.75rem` gap.
- `kp-grid` - responsive grid: `auto-fit` columns of at least `14rem`, `0.75rem` gaps.

## Theme awareness

knot toggles a `dark` class on the `<html>` element; every `kp-*` class (and the prose styling knot applies to markdown payloads) restyles itself from it. For your own CSS, follow the same pattern:

```html
<div class="kp-card">
  <div class="kp-label">Throughput</div>
  <div class="my-gauge kp-title kp-mono">1.2 GiB/s</div>
</div>
<style>
  .my-gauge { color: #1d4ed8; }
  .dark .my-gauge { color: #60a5fa; }
</style>
```

Inline SVGs inherit `currentColor`, so an icon wrapped in `kp-accent` recolours with the theme for free. Font families are available as CSS variables (`--font-nunito`, `--font-jbmono`) - `kp-mono` is the supported way to reach the mono face.

## Alpine and Chart.js

Plugin pages load knot's full web bundle, so `window.Alpine` and `window.Chart` (chart.js) are available to raw html. Alpine directives in injected markup initialise automatically - including after a refresh replaces the block - so a small self-contained widget works:

```html
<div class="kp-card" x-data="{ on: true }">
  <div class="kp-label">Toggle</div>
  <button class="kp-title" @click="on = !on" x-text="on ? 'enabled' : 'disabled'"></button>
</div>
```

## Calling your handlers

`pluginFetch(handler, options)` is the bridge for interactive html: it calls a plugin handler's URL with the same transport, auth, page gate and running-user identity as every column fetch, retrying transient failures and parsing the JSON for you.

- `pluginFetch('my_handler')` - GET your handler's JSON (the page path plus `/<handler>`). A handler no layout column references - a widget callback like this echo - must be declared in `[[tool.knot.handlers]]` to be callable.
- `pluginFetch('my_handler', { params: { word: 'hi' } })` - GET with query params (they arrive in the handler's `params`).
- `pluginFetch('my_handler', { method: 'POST', body: { name: 'x' } })` - POST the object form-encoded; the handler sees `request["method"] == "POST"` and the fields in `request["params"]`.
- `pluginFetch('their_handler', { plugin: 'other-plugin' })` - GET **another plugin's** handler (`/plugins/other-plugin/their_handler`). The handler must be declared in that plugin's metadata with `[[tool.knot.handlers]]` (that declaration is what makes it addressable at the plugin root), and its declared permission - empty means any logged-in user - is the gate. Handlers are ajax endpoints - any page may fetch any plugin's declared handlers.

It throws on a non-JSON response (an expired session or a down server), so widgets can surface their own error state. Combined with Alpine:

```html
<div class="kp-card" x-data="{ word: '', busy: false, reply: '' }">
  <div class="kp-label">Echo service</div>
  <div class="kp-flex" style="margin-top:0.5rem">
    <input class="kp-input" x-model="word" placeholder="type a word">
    <button class="kp-button" :disabled="busy"
            @click="busy = true; try { reply = (await pluginFetch('echo_word', { params: { word: word } })).reply } finally { busy = false }"
            x-text="busy ? '...' : 'Send'"></button>
  </div>
  <div class="kp-muted" style="margin-top:0.5rem" x-show="reply" x-text="reply"></div>
</div>
```

The handler is ordinary - it cannot tell a column fetch from a widget call:

```python
def echo_word(request):
    word = request["params"].get("word", "")
    if word == "":
        return {"reply": "type something first"}
    return {"reply": "echo: " + word.upper()}
```

POSTing from a widget follows the same envelope contract as forms and actions: return `{status, message, field_errors?, refresh?}` and let the page react, or return plain data and let the widget render it. Give interactive columns **no `refresh`** - a refresh replaces the markup and resets the widget (see [refresh semantics](#refresh-semantics)). The showcase's "Alpine calling the plugin" column is a live example.

## Refresh semantics

A column with `refresh` is re-fetched and its content **replaced** on every tick. Anything stateful in the markup (Alpine `x-data`, script-modified DOM) resets on refresh - treat refresh-capable html columns as render functions of their payload, and keep state server-side. The showcase's clock column is the pattern: the handler returns the time, the markup just displays it.

For charts, prefer a `chart` column (knot owns rendering, updates patch in place without animation). Reach for a Chart.js canvas in raw html only when you need behaviour the chart column cannot express.
