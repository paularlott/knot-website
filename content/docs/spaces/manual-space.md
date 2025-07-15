---
title: Manual Space
weight: 20
---

It's possible to run the agent manually on a virtual machine or even a physical server and connect to it from the knot web interface.

First a template needs to be created with the `Manually Created Space` option checked. The space can then be created from the template.

Manual spaces show the Space Id, this is required for the agent to connect to the knot server.

{{< picture src="../manual-space.webp" caption="Manual Space" >}}

On the machine where the agent will run create a `knot.yaml` file with the following content:

```yaml {filename=knot.yaml}
agent:
    endpoint: srv+knot-server-agent.service.consul
    space_id: 01940ddd-e8c2-776a-8bca-5e35d04bae65
```

This is the minimum required for the agent to be able to connect to the knot server. The `endpoint` value will need to be adjusted for the environment where the knot server is running.

Start the agent with: `knot agent -c knot.yaml`

Once the agent has started the web interface will update to show the space online and the services such as the web terminal will be available.
