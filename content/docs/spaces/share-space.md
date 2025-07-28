---
title: Sharing Spaces
weight: 80
---

Spaces can be shared between users on the same **knot** server, allowing both users to access and manage the space collaboratively. Shared spaces enable both users to:
- SSH into the space.
- Access its web interface.
- Use its web terminal.

---

## Key Details

- A space can only be shared with **one user at a time**.
- Both the original user and the shared user will have equal access to the space.

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

- Either user can cancel the sharing at any time by selecting the `Stop Sharing` menu item.
- Once cancelled:
  - The space will no longer be accessible to the user it was shared with.
  - SSH keys belonging to the shared user will be removed from the space.

---

## Important Notes

{{< tip >}}
Ensure the target user's name is clicked in the dropdown list to confirm the selection.
{{< /tip >}}
