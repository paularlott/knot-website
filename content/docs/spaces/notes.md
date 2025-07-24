---
title: Space Notes
weight: 140
---

Spaces in **knot** allow for a description to be set during creation or editing, as well as a dynamic note that can be updated from within the space. Both the description and note are displayed on the **`Spaces`** page and can be used to provide important information about the space.

---

### Viewing and Editing Space Notes

1. On the **`Spaces`** page, the short form of the description is displayed.
   - Clicking the short description (#1) opens a dialog showing the full description and note.
   {{< picture src="../images/space-note.webp" caption="Space Note" >}}

2. The dialog provides a detailed view of the description and note.
   {{< picture src="../images/notes-detail.webp" caption="Note Detail" >}}

---

### Setting a Note Dynamically from Within the Space

The space note can be updated dynamically using the command line tool from within the space. Run the following command:

```shell
knot agent set-note "My Space Description"
```

- Replace `"My Space Description"` with the desired note text.
- The updated note will immediately appear on the **`Spaces`** page.
