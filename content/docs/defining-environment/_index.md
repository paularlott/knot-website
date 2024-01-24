---
linkTitle: Defining an Environment
---

{{< cards >}}
  {{< card link="debian" title="Debian" icon="terminal" >}}
  {{< card link="ubuntu" title="Ubuntu" icon="terminal" >}}
  {{< card link="volumes" title="Volumes" icon="database" >}}
{{< /cards >}}

Each space is defined by a nomad job file and optionally a volume definition. When the developer creates and starts a space, knot creates any required volumes and launches the job within the nomad cluster.
