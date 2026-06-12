---
title: Script Examples
weight: 10
---

Practical examples of scripts using the `knot.*` and `scriptling.*` libraries.

---

## List All Spaces

```python
import knot.space as space

spaces = space.list()
for s in spaces:
    print(f"Space: {s['name']} ({'running' if s['is_running'] else 'stopped'})")
```

---

## Create and Start a Space

```python
import knot.space as space

space_id = space.create("my-space", "ubuntu", description="My dev environment")
space.start("my-space")
print(f"Created space with ID: {space_id}")
```

---

## Run a Command in a Space

```python
import knot.space as space

output = space.run("my-space", "ls", args=["-la", "/tmp"])
print(output)
```

---

## Read and Write Files

```python
import knot.space as space

# Read a file
content = space.read_file("my-space", "/etc/hostname")
print(content)

# Write a file
space.write_file("my-space", "/tmp/hello.txt", "Hello from knot!")
```

---

## Server-Side Secret Access {{< pro-badge >}}

`scriptling.secret` is available in Knot's server-side script environments automatically.

```python
import scriptling.secret as secret

db_password = secret.get("vault", "secret/data/prod/database", "password")
api_key = secret.get("op", "Engineering/API Service Key", "credential")
```

---

## MCP Tool: Create Space

```python
import scriptling.mcp.tool as tool
import knot.space as space

name = tool.get_string("name")
template = tool.get_string("template")
description = tool.get_string("description", "")

space_id = space.create(name, template, description=description)

tool.return_string(f"Space '{name}' created with ID: {space_id}")
```

With parameter schema in TOML:

```toml
description = "Create a new development space"
keywords = ["create", "space", "new", "environment"]

[[parameters]]
name = "name"
type = "string"
description = "Name of the space"
required = true

[[parameters]]
name = "template"
type = "string"
description = "Template to use"
required = true

[[parameters]]
name = "description"
type = "string"
description = "Optional description"
required = false
```

---

## MCP Tool: List and Filter Spaces

```python
import scriptling.mcp.tool as tool
import knot.space as space

running_only = tool.get_bool("running_only", False)

spaces = space.list()
if running_only:
    spaces = [s for s in spaces if s["is_running"]]

result = "\n".join(f"{s['name']} ({'running' if s['is_running'] else 'stopped'})" for s in spaces)
tool.return_string(result or "No spaces found")
```

---

## AI Completion

```python
import knot.ai as ai

client = ai.Client()

answer = client.ask("", "What is the capital of France?")
print(answer)
```

With streaming:

```python
import knot.ai as ai

client = ai.Client()

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

## MCP Tool Discovery

```python
import knot.mcp as mcp

tools = mcp.list_tools()
for t in tools:
    print(f"{t['name']}: {t['description']}")

results = mcp.tool_search("list spaces")
spaces = mcp.execute_tool("list_spaces", {})
```

---

## User and Permission Checks

```python
import knot.user as user
import knot.permission as perm

me = user.get_me()
print(f"Logged in as: {me['username']}")

if user.has_permission(me["id"], perm.MANAGE_SPACES):
    print("User can manage all spaces")

quota = user.get_quota(me["id"])
print(f"Spaces: {quota['number_spaces']}/{quota['max_spaces']}")
```

---

## Stack Creation

```python
import knot.stack as stack

result = stack.create("lamp", "myproject")
for name, space_id in result["spaces"].items():
    print(f"  {name}: {space_id}")

stack.start("myproject")
```

---

## File Provisioning

```python
import scriptling.provision.file as file

status = file.ensure("~/.bashrc", """export PATH="$HOME/bin:$PATH"
export EDITOR=vim
""")

if status == file.CREATED:
    print("Created .bashrc")
elif status == file.UPDATED:
    print("Updated .bashrc")

file.ensure_directory("~/projects", mode=0o755)
```

---

## Custom Health Check

```python
import knot.healthcheck as hc

ok = hc.http_head("http://localhost:8080/health") and hc.tcp_port(6379)
hc.check_result(ok)
```
