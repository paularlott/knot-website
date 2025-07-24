---
title: API Tokens
weight: 90
---

API tokens are automatically created when logging in with the **knot** client. Additionally, tokens can be manually created and used to access the API from external applications.

---

## Creating a Token

1. From the menu, select **`API Tokens`**, then click **`New Token`**.
   {{< picture src="images/create-token.webp" caption="Create API Token" >}}

2. Complete the **`Name`** field to identify the token.
3. Click **`Create Token`** to generate a new token.
4. The list of available tokens will be displayed.

   - **Tip**: Clicking on a token will copy it to the clipboard for easy use.

{{< tip "warning" >}}
Tokens expire after two weeks of inactivity. Any API call made with the token will reset its lifespan.
{{< /tip >}}

---

## Deleting a Token

Deleting a token immediately prevents further API calls from being made using that token.

1. From the **API Tokens** list, click **`Delete`** next to the token you want to remove.
2. Confirm the operation when prompted.
