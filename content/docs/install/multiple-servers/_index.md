---
title: Multiple Servers
weight: 35
---

Multiple servers can be used to solve two common problems, the first is to allow the placement of servers close to developers to minimize latency while allowing management of users and templates from a central location, the origin server. The second is to allow scaling of the system to support more developers.

In a multi-server deployment, there are three types of servers:

1. **[Origin Server](origin-server)** - The origin server is the central server which manages all the users, templates and other resources.
2. **[Leaf Server](leaf-server)** - Leaf servers are trusted servers which are connected to the origin server through the use of a shared secret and have access to all the data within the origin server.
3. **[Restricted Server](restricted-server)** - Restricted servers are leaf servers which are connected to the origin server using a personal API key, in this mode they run in a restricted mode and have limited access to variables and other elements hosted within the origin server.

This structure ensures both efficient management and scalable performance across different roles and requirements.
