---
title: Space Description
weight: 120
---

Spaces allow a description to be set when creating or editing them. The description is displayed on the `Spaces` page and can be used to provide information about the space, clicking the short form of the description opens a dialog showing the full description.

## From the Command Line

The description can also be set from within the space using the command line tool:

```shell
knot-agent agent set-description "My Space Description"
```

## Via the API

The description can also be set via the agents REST API by posting to `http://127.0.0.1:12201/api/space/description` endpoint.

```json
{
  "description": "My Space Description"
}
```
