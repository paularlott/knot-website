---
title: Webhook Sinks
weight: 10
---

Webhook sinks POST an HTTP request to a configured URL when a matching event fires. The request body is rendered through a Go template giving you full control over the payload structure.

---

## Configuration

| Field | Description |
|-------|-------------|
| **URL** | Target URL to POST to. Must accept `application/json`. |
| **Secret** | HMAC-SHA256 signing key. Auto-generated on creation. Masked in list view; click the eye icon to reveal in the edit form. |
| **Headers** | Custom HTTP headers appended to every request. |
| **Body Template** | Go template rendered into the JSON request body. Leave empty to use the default template. |

---

## Request Format

### Headers

Every webhook request includes these headers:

| Header | Description |
|--------|-------------|
| `Content-Type` | `application/json` |
| `X-Knot-Event-Id` | UUIDv7 event identifier |
| `X-Knot-Event-Type` | Event type string (e.g. `space.started`) |
| `X-Knot-Event-Ts` | HLC timestamp (RFC 3339) |
| `X-Knot-Signature` | `sha256=<hex HMAC-SHA256 of body using secret>` |

Any custom headers from the sink configuration are appended.

### Signature Verification

To verify the request is from knot, compute the HMAC-SHA256 of the raw body and compare:

```python
import hmac, hashlib

def verify(body, signature, secret):
    expected = "sha256=" + hmac.new(
        secret.encode(), body, hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected, signature)

# usage
# verify(request.body, request.headers["X-Knot-Signature"], "your-secret")
```

### Success Criteria

HTTP 2xx within the 10-second timeout is success. Any other status code or network error triggers a retry (3 attempts, 5s / 15s backoff).

---

## Template Variables

The body template uses Go template syntax with `${{ }}` delimiters. The following variables are available:

### `.event`

The firing event.

| Variable | Description |
|----------|-------------|
| `${{ .event.id }}` | UUIDv7 event identifier |
| `${{ .event.type }}` | Event type string |
| `${{ .event.ts }}` | HLC timestamp string |
| `${{ .event.data }}` | Event payload as a map (use `${{ json .event.data }}` to embed as JSON) |

### `.space`

The source space.

| Variable | Description |
|----------|-------------|
| `${{ .space.id }}` | Space UUID |
| `${{ .space.name }}` | Space name |
| `${{ json .space.urls }}` | All port URLs as a JSON object, keyed by port name |

Each entry in `.space.urls` is built from the template's port definitions: `https://<username>--<spacename>--<port>.<domain>`. For example, if the template defines ports `web` (80) and `web2` (8080):

```json
"urls": {
  "web": "https://alice--myspace--80.knot.example.com",
  "web2": "https://alice--myspace--8080.knot.example.com"
}
```

### `.actor`

Who or what triggered the event.

| Variable | Description |
|----------|-------------|
| `${{ .actor.id }}` | Actor ID (user ID, or empty for system) |
| `${{ .actor.username }}` | Actor username |
| `${{ .actor.kind }}` | `User`, `System`, or `MCP` |

### `.custom`

Custom fields defined on the source space's template and entered at space-creation time. Each field is accessible by its name:

| Variable | Description |
|----------|-------------|
| `${{ .custom.MY_FIELD }}` | Value of a custom field named `MY_FIELD` |

For example, if your template defines custom fields `GITHUB_REPO` and `DEPLOY_ENV`, you can include them:

```json
{
  "repo": "${{ .custom.GITHUB_REPO }}",
  "env":  "${{ .custom.DEPLOY_ENV }}"
}
```

Fields that are defined on the template but not set on the space render as empty strings. See [Custom Variables](/docs/variables/custom-variables/) for how to define custom fields on templates.

---

## Template Functions

| Function | Description | Example |
|----------|-------------|---------|
| `json` | Marshal a value to JSON | `${{ json .space.urls }}` |
| `quote` | Escape double quotes in a string | `${{ quote .space.name }}` |
| `toUpper` | Convert to uppercase | `${{ toUpper .actor.kind }}` |
| `toLower` | Convert to lowercase | `${{ toLower .event.type }}` |
| `map` | Build a map from key-value pairs | `${{ map "k" "v" "k2" "v2" }}` |

---

## Default Template

When the body template is left empty, knot uses this default:

```json
{
  "event_id":   "${{ .event.id }}",
  "event_type": "${{ .event.type }}",
  "event_ts":   "${{ .event.ts }}",
  "data": ${{ json .event.data }}
}
```

The `.space` and `.actor` scopes are omitted from the default — space info is included directly in the `data` block for `space.*` events (see below). Use a custom template if you need actor or port URLs in the webhook body.

---

## System Event Payloads

The `data` block for system events. Space lifecycle events include `space_name` and `space_id` directly in `data`; `space.created` and `space.started` also include `space_urls`:

| Event | `data` fields |
|-------|---------------|
| `space.created` | `space_name`, `space_id`, `space_urls`, `template_id`, `startup_script_id` |
| `space.started` | `space_name`, `space_id`, `space_urls`, `node_id`, `started_at` |
| `space.stopped` | `space_name`, `space_id`, `stopped_at` |
| `space.deleted` | `space_name`, `space_id`, `deleted_at` |
| `space.healthy` | `space_name`, `space_id`, `previous`, `current`, `checked_at` |
| `space.unhealthy` | `space_name`, `space_id`, `previous`, `current`, `consecutive_failures`, `checked_at` |

For custom events, `data` is whatever was passed to `knot event` / `POST /event` / `knot.event.emit()`.
