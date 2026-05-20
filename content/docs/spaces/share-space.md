---
title: Sharing Spaces
weight: 80
---

Spaces can be shared between users on the same **knot** server, allowing users to access and manage the space collaboratively. Shared spaces enable users to:
- SSH into the space.
- Access its web interface.
- Use its web terminal.

---

## Key Details

- **Core**: A space can be shared with **one user at a time**.
- **Pro**: A space can be shared with **multiple users** simultaneously.
- The original owner and all shared users have equal access to the space.

---

## How to Share a Space

1. Navigate to the **`Spaces`** page.
2. Select the space you want to share.
3. Click the **`Share`** menu item.
   {{< picture src="../images/share-space.webp" caption="Share Space" >}}

4. A dialog will appear, allowing you to select the target user from a dropdown list.
   - Click the target user's name in the dropdown to select them.

5. Click the **`Share Space with`** button to complete the sharing process.

---

## Cancelling a Shared Space

- The owner can cancel sharing at any time by selecting the `Stop Sharing` menu item.
- Shared users can leave a shared space from the same menu.
- Once cancelled:
  - The space will no longer be accessible to the removed user.
  - SSH keys belonging to the removed user will be removed from the space.

---

## Sharing via Scripting

Use the `knot.space` library to share and unshare spaces programmatically:

```python
import knot.space as space

# Share a space with a user (accepts user ID, username, or email)
space.share("my-space", "alice@example.com")

# Remove sharing for a specific user
space.unshare("my-space", user_id="alice@example.com")

# Stop all sharing (owner only)
space.unshare("my-space")
```

---

## Important Notes

{{< tip >}}
Ensure the target user's name is clicked in the dropdown list to confirm the selection.
{{< /tip >}}
