---
title: Managing a Space
weight: 10
---

This guide explains how to create, start, stop, update, edit, and delete spaces in **knot**.

---

### Creating a Space

1. Navigate to the `Templates` page, click the menu icon (three dots) next to the desired template, and select `Create Space`.
   {{< picture src="../../quick-start/standalone/images/create-space.webp" caption="Create Space" >}}

2. Complete the form for the new space:
   - **`Name`**: The name of the space.
   - **`Description`**: (Optional) A description for the space.
   - **`Icon`**: (Optional) An icon for the space. By default, the template's icon will be used if one is set.
   - **`Additional Space Names`**: Add additional names for the space by clicking the `+` icon. This is useful for accessing the space under multiple domain names when using the web proxy service.
   - **`Terminal Shell`**: The shell to use for the terminal. By default, the user's profile shell is used.
   - **`Custom Fields`**: If the template includes custom fields, they will appear here. Set values for each field as needed.
   - **`Start Space on Create`**: If checked, the space will start automatically after creation.

3. Click `Create Space` to finalize the process.

{{< tip >}}
Admins may see the `Create Space For` option, allowing them to create spaces on behalf of other users. Selecting this option will prompt for the user under whom the space will be created.
{{< /tip >}}

---

### Starting a Space

1. Navigate to the `Spaces` page.
2. Click the menu icon next to the space and select `Start`.
   {{< picture src="../images/start-space.webp" caption="Start Space" >}}

- The space's status will change to `Starting`, and once running, it will display as `Running`.
- Icons will appear in the services column, providing access to features such as the web terminal.

   {{< picture src="../images/running-space.webp" caption="Running Space" >}}

#### Service Icons:

1. **`VNC`**: Opens a new window connecting to a VNC server running within the space.
2. **`Code Server`**: Opens a new window running Code Server.
3. **`VSCode Tunnel`**: Displays a red icon if the VSCode tunnel is not configured. When functioning, it matches the other icons. Clicking it opens a web terminal connected to the VSCode tunnel service.
4. **`Web Terminal`**: Provides shell access to the space via a web-based terminal.
5. **`Ports`**: Displays a menu of web interfaces and exposed ports for the space.

{{< tip >}}
- Not all icons will be present. Their availability depends on the features enabled in the template and the user's permissions.
- Spaces created from manual templates do not have a `Start` option. They start automatically when their agent connects to the server.
{{< /tip >}}

---

### Stopping a Space

1. Click the menu icon next to the running space.
2. Select `Stop`.
   {{< picture src="../images/stop-space.webp" caption="Stopping a Space" >}}

- The `Stop` button is a split button:
  - **`Stop`**: Stops the space.
  - **`Restart`**: Stops and then restarts the space.

{{< tip "warning" >}}
Stopping a space will result in the loss of all data in memory that is not stored on a persistent volume. However, volumes used by the space will not be deleted.
{{< /tip >}}

---

### Updates

If the template used by a running space is updated, an `Update Available` badge will appear:
{{< picture src="../images/space-update.webp" caption="Pending Update" >}}

To apply the update:

1. Stop the space.
2. Start it again.

- Any volumes added to the template will be created when the space starts.
- Any volumes removed from the template will be deleted, along with their data.

---

### Editing a Space

1. Select `Edit` from the space's menu.
2. Update the space's details, such as its name, icon, or additional names.

- Additional URLs are supported immediately after the space is successfully saved.

---

### Deleting a Space

{{< tip "warning" >}}
Deleting a space will permanently delete its volumes and all associated data.
{{< /tip >}}

1. Ensure the space is stopped. Only stopped spaces can be deleted.
2. Select `Delete` from the space's menu.
3. Confirm the action in the dialog that appears.

- When a space is deleted, all resources are freed, and all volumes and their data are removed.
