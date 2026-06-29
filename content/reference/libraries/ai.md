---
title: knot.ai
weight: 20
---

The `knot.ai` library provides access to an AI client for scripts. In embedded contexts (MCP, remote, local scripts) it returns a pre-configured client connected to the server's AI provider. For standalone use outside knot, configure `knot.apiclient` with AI connection details.

---

## Functions

| Function | Description |
|----------|-------------|
| `get_default_model()` | Returns the configured default model name, or `""` |
| `Client()` | Get an AI client instance |

---

## Embedded Usage

```python
import knot.ai as ai

client = ai.Client()

# Pass "" as model - server uses its configured default
answer = client.ask("", "What is the capital of France?")
print(answer)
```

---

## Standalone Usage

Configure `knot.apiclient` with AI kwargs or set environment variables:

```python
import knot.apiclient
import knot.ai as ai

knot.apiclient.configure(
    "https://knot.example.com", "your-token",
    ai_model="gpt-4o",
    ai_provider="openai",
    # ai_url defaults to url + "/v1"
    # ai_token defaults to token
)

client = ai.Client()
model = ai.get_default_model()  # returns "gpt-4o"

answer = client.ask(model, "What is the capital of France?")
print(answer)
```

Or via environment variables (read on first use):

```
KNOT_URL=https://knot.example.com
KNOT_TOKEN=your-token
KNOT_AI_MODEL=gpt-4o
KNOT_AI_PROVIDER=openai
KNOT_AI_URL=https://knot.example.com/v1   # optional
KNOT_AI_TOKEN=your-ai-token               # optional, defaults to KNOT_TOKEN
```

---

## Function Details

### get_default_model()

Returns the `ai_model` from `knot.apiclient` config. Always returns `""` in embedded contexts — passing `""` to any client method causes the server to use its configured default.

**Returns:** `str` - The model name, or `""`

---

### Client()

Returns an AI client instance. In embedded contexts returns the pre-configured server client. In standalone use creates a `scriptling.ai` client using the AI connection details from `knot.apiclient`.

**Returns:** `Client` - An AI client instance

---

## Client Object Methods

The client object returned by `ai.Client()` has the following methods:

### client.completion(model, messages, **kwargs)

Creates a chat completion.

**Parameters:**
- `model` (str): Model identifier, or `""` to use the server's configured default
- `messages` (str or list): Either a string (user message) or a list of message dicts with "role" and "content" keys
- `system_prompt` (str, optional): System prompt to use when messages is a string
- `tools` (list, optional): List of tool schema dicts
- `temperature` (float, optional): Sampling temperature (0.0-2.0)
- `max_tokens` (int, optional): Maximum tokens to generate

**Returns:** `dict` - Response containing id, choices, usage, etc.

```python
# String shorthand - "" uses server default model
response = client.completion("", "What is 2+2?")

# With system prompt
response = client.completion("", "What is 2+2?", system_prompt="You are a math tutor")

# Full messages array
response = client.completion("", [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "What is Python?"}
])
print(response.choices[0].message.content)
```

---

### client.ask(model, messages, **kwargs)

Quick completion that returns text directly, with thinking blocks automatically removed.

**Parameters:** Same as `completion()`

**Returns:** `str` - The response text

```python
answer = client.ask("", "What is 2+2?")
print(answer)  # "4"
```

---

### client.completion_stream(model, messages, **kwargs)

Creates a streaming chat completion.

**Parameters:** Same as `completion()`

**Returns:** `ChatStream` - A stream object with a `next()` method

```python
stream = client.completion_stream("", "Count to 10")
while True:
    chunk = stream.next()
    if chunk is None:
        break
    if chunk.choices and len(chunk.choices) > 0:
        delta = chunk.choices[0].delta
        if delta.content:
            print(delta.content, end="")
```

---

### client.embedding(model, input)

Creates an embedding vector for the given input text(s).

**Parameters:**
- `model` (str): Model identifier
- `input` (str or list): Input text(s) to embed

**Returns:** `dict` - Response containing data (list of embeddings), model, and usage

---

## With Agent Framework

```python
import knot.ai as ai
import scriptling.ai.agent as agent

client = ai.Client()

bot = agent.Agent(
    client=client,
    model="",
    system_prompt="You are a helpful assistant."
)

response = bot.trigger("Please greet Paul", max_iterations=5)
print(response.content)
```

---

## Error Handling

```python
import knot.ai as ai

try:
    client = ai.Client()
except Exception as e:
    print(f"AI not available: {e}")
```

---

## Server Configuration

The AI provider is configured server-side in `.knot.toml`:

```toml
[server.chat]
enabled = true
openai_api_key = "your-api-key"
openai_base_url = "https://api.openai.com/v1"
model = "gpt-4o"
system_prompt = "You are a helpful assistant."
```
