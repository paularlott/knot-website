---
title: Templates
weight: 30
---

Templates are used to define both Nomad and Docker / Podman based environments. As part of the definition one or more volumes can be defined.

When a space is first started all the volumes that are defined in the template are created, starting and stopping a space will not destroy the volumes only deleting the space will remove the volumes. The exception to this rule is that if the volumes are removed from the template then when the space is started again the removed volumes will be deleted.

When defining Nomad based templates the volumes are allocated using storage systems provided by CSI plugins. When defining Docker / Podman based templates the volumes are allocated using the storage system provided by Docker / Podman.