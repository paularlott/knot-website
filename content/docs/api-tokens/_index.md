---
title: API Tokens
weight: 60
---

API tokens are created automatically when logging in with the knot client. Tokens can also be created manually and used to access the API from external applications.

## Creating a Token

From the menu select `API Tokens`, then click `New Token`.

![Create API Token](create-api-token.webp)

Complete the `Name` field and click `Create Token`, a new token is generated and the list of available tokens is displayed.

{{< tip "warning" >}}
  Tokens expire after a week of inactivity, any API call will reset the lifespan of the tokens.
{{< /tip >}}

## Deleting a Token

Deleting a token instantly stops further API calls being made using the token.

From the API token list click `Delete` next to the token to delete, and confirm the operation when prompted.

![List of API Tokens](list-api-tokens.webp)
