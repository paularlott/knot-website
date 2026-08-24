---
description: Create and manage API tokens to access the knot API from external applications.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/api-tokens/
sources:
    - resource: https://getknot.dev/docs/api-tokens/
status: stable
tags:
    - security
    - authentication
    - api
title: API Tokens
type: Overview
---
# API Tokens

API tokens are automatically created when logging in with the Knot client. Additionally, tokens can be manually created and used to access the API from external applications.

---

## Creating a Token

1. From the menu, select **`API Tokens`**, then click **`New Token`**.
   

2. Complete the **`Name`** field to identify the token.
3. Click **`Create Token`** to generate a new token.
4. The list of available tokens will be displayed.

   - **Tip**: Clicking on a token will copy it to the clipboard for easy use.


Tokens expire after two weeks of inactivity. Any API call made with the token will reset its lifespan.


---

## Deleting a Token

Deleting a token immediately prevents further API calls from being made using that token.

1. From the **API Tokens** list, click **`Delete`** next to the token you want to remove.
2. Confirm the operation when prompted.
