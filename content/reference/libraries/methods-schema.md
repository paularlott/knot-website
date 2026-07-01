---
title: knot.methods.schema
weight: 26
---

Build JSON Schema fragments for method `params` and `result` definitions. Conventionally imported as `s`. Available wherever `knot.methods` is available.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Remote/space scripts (startup scripts), `knot methods register`, `knot run-script` | Available (same contexts as `knot.methods`). |
| MCP tool execution, event sink scripts, `knot run-script` server mode | Not available. |
| Health check scripts, external standalone | Not available. |

---

## Import

```python
from knot.methods import schema as s
```

---

## Builders

| Builder | Description |
|---------|-------------|
| `s.string(*, description, default, enum, format, min_length, max_length, pattern, extra)` | String schema |
| `s.integer(*, description, default, enum, minimum, maximum, extra)` | Integer schema |
| `s.number(*, description, default, enum, minimum, maximum, extra)` | Number (float) schema |
| `s.boolean(*, description, default, enum, extra)` | Boolean schema |
| `s.null(*, description, default, enum, extra)` | Null schema |
| `s.array(items, *, description, default, enum, min_items, max_items, extra)` | Array schema; `items` is a schema dict from another builder |
| `s.object(**properties, *, description, default, enum, additional_properties, extra)` | Object schema; kwargs become properties |
| `s.optional(schema, *, default=None)` | Mark a property as optional (excluded from `required`) |

---

## Conventions

- Constraint kwargs are snake_case and emitted as JSON Schema's camelCase equivalents (`min_length` → `minLength`, `additional_properties` → `additionalProperties`).
- Unknown kwargs raise an error. Use `extra={"keyword": value}` for JSON Schema keywords not in the curated list.
- Explicit kwargs win over keys in `extra` on conflict.
- Every property in `s.object(...)` is added to `required` unless wrapped in `s.optional(...)`.
- `additional_properties` defaults to `false`.
- The `required` array is sorted alphabetically for deterministic output.

---

## Example

```python
from knot.methods import schema as s

params = s.object(
    query=s.string(description="Search query", min_length=1),
    tag=s.string(enum=["alpha", "beta"]),
    limit=s.optional(s.integer(minimum=1), default=10),
)
```

Produces:

```json
{
  "type": "object",
  "required": ["query", "tag"],
  "properties": {
    "query": {"type": "string", "description": "Search query", "minLength": 1},
    "tag": {"type": "string", "enum": ["alpha", "beta"]},
    "limit": {"type": "integer", "minimum": 1, "default": 10}
  },
  "additionalProperties": false
}
```
