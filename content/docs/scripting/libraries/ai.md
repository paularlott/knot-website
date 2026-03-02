---
title: knot.ai
weight: 20
---

The `knot.ai` library provides access to the server's AI client for scripts. It returns a pre-configured client instance connected to the upstream AI provider.

---

## Functions

| Function | Description |
|----------|-------------|
| `Client()` | Get a pre-configured AI client instance |
| `get_default_model()` | Get the server-configured default model name |

---

## Usage

```python
import knot.ai as ai

# Get the AI client
client = ai.Client()
model = ai.get_default_model()

# Simple completion
response = client.completion(model, [
    {"role": "user", "content": "What is the capital of France?"}
])
print(response.choices[0].message.content)
```

---

## Function Details

### Client()

Returns a pre-configured AI client instance. The client connects to whichever LLM provider the server is configured to use (OpenAI, Claude, Gemini, Ollama, etc.).

**Returns:** `Client` - An AI client instance with the methods documented below.

---

### get_default_model()

Get the name of the server-configured default model.

**Returns:** `str` - The model name (e.g. `"gpt-4o"`, `"claude-sonnet-4-20250514"`), or an empty string if not configured.

---

## Client Object Methods

The client object returned by `ai.Client()` has the following methods:

### client.completion(model, messages, **kwargs)

Creates a chat completion.

**Parameters:**
- `model` (str): Model identifier (e.g., "gpt-4o", "claude-sonnet-4-20250514")
- `messages` (str or list): Either a string (user message) or a list of message dicts with "role" and "content" keys
- `system_prompt` (str, optional): System prompt to use when messages is a string
- `tools` (list, optional): List of tool schema dicts
- `temperature` (float, optional): Sampling temperature (0.0-2.0)
- `max_tokens` (int, optional): Maximum tokens to generate

**Returns:** `dict` - Response containing id, choices, usage, etc.

```python
# String shorthand
response = client.completion(model, "What is 2+2?")

# With system prompt
response = client.completion(model, "What is 2+2?", system_prompt="You are a math tutor")

# Full messages array
response = client.completion(model, [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "What is Python?"}
])
print(response.choices[0].message.content)
```

---

### client.completion_stream(model, messages, **kwargs)

Creates a streaming chat completion. Returns a ChatStream object.

**Parameters:** Same as `completion()`

**Returns:** `ChatStream` - A stream object with a `next()` method

```python
stream = client.completion_stream(model, "Count to 10")
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

### client.ask(model, messages, **kwargs)

Quick completion method that returns text directly, with thinking blocks automatically removed.

**Parameters:** Same as `completion()`

**Returns:** `str` - The response text with thinking blocks removed

```python
# Simple query
answer = client.ask(model, "What is 2+2?")
print(answer)  # "4"

# With system prompt
answer = client.ask(model, "Explain quantum physics", system_prompt="You are a physics professor")
```

---

### client.embedding(model, input)

Creates an embedding vector for the given input text(s).

**Parameters:**
- `model` (str): Model identifier (e.g., "text-embedding-3-small")
- `input` (str or list): Input text(s) to embed

**Returns:** `dict` - Response containing data (list of embeddings), model, and usage

```python
# Single text embedding
response = client.embedding("text-embedding-3-small", "Hello world")
print(response.data[0].embedding)

# Batch embedding
response = client.embedding("text-embedding-3-small", ["Hello", "World"])
for emb in response.data:
    print(emb.embedding)
```

---

## Multi-turn Conversation

```python
import knot.ai as ai

client = ai.Client()
model = ai.get_default_model()

messages = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "What is Python?"}
]

response = client.completion(model, messages)
print("AI:", response.choices[0].message.content)

# Continue the conversation
messages.append({"role": "assistant", "content": response.choices[0].message.content})
messages.append({"role": "user", "content": "What are its main use cases?"})

response = client.completion(model, messages)
print("AI:", response.choices[0].message.content)
```

---

## With Agent Framework

The primary use case is with the `scriptling.ai.agent` library for agentic workflows:

```python
import knot.ai as ai
import scriptling.ai as sai
import scriptling.ai.agent as agent

client = ai.Client()
model = ai.get_default_model()

# Create an agent with tools
tools = sai.ToolRegistry()
tools.add("greet", "Greet someone", {"name": "string"}, lambda args: f"Hello, {args['name']}!")

bot = agent.Agent(
    client=client,
    model=model,
    tools=tools,
    system_prompt="You are a helpful assistant."
)

response = bot.trigger("Please greet Paul", max_iterations=5)
print(response.content)
```

---

## Error Handling

If the AI client is not configured on the server, `Client()` will raise an error:

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
