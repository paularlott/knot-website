---
title: Creating a Space
weight: 50
---

Now that we have a usable template, we can create a space from it. You can create as many spaces as needed from a single template. If a template is updated, users with spaces created from that template will be prompted to restart their spaces to apply the updates.

---

### Step 1: Create a Space

1. From the `Templates` page, click the menu icon (three dots) next to the template you want to use, then select `Create Space`.

{{< picture src="../../local-containers/images/create-space.webp" caption="Create a Space" >}}

2. Fill out the form with the following details:
   - **Name**: Enter `phptest`.
   - **Description**: Enter `A test PHP space.`.
   - **Terminal**: Select the terminal you'd like to use.
   - **Icon**: Optionally, change the icon shown for the space.

3. Leave the `Start Space on Create` option checked, then click `Create Space`. You'll be returned to the `Spaces` page, where the new space will now be visible.

---

### Step 2: Monitor the Space Status

- While the space is starting, its **Status** will show as `Starting`.
- Once the space is running, the **Status** will change to `Running`, and icons will appear, allowing access to the space's features.

{{< picture src="../images/running-space.webp" caption="Running Space" >}}

Once the space is running the icons will show:

1. **Terminal**: Clicking the terminal icon opens a new window with a web terminal inside the space. The shell will match the one selected during space creation.
2. **Ports**: Clicking the ports icon opens a dropdown showing the list of ports the space exports. For this example, the first port is the web server. Clicking it will open a new window displaying the content served by the web server.

---

### Step 3: Add a PHP Script

1. Click the `Web` item in the `Ports` menu to open the web browser. At this point, the server will display an empty folder since no content has been added yet.
2. Click the `Terminal` icon to open a web terminal. Create a PHP file in the `public_html` directory that runs `phpinfo`:

```shell
echo "<?php phpinfo();" > public_html/index.php
```

{{< picture src="../../local-containers/images/terminal.webp" caption="Creating a phpinfo Script" >}}

---

### Step 4: View the PHP Script

1. Click the `Web (80)` item in the `Ports` menu. The web page will open, running the new script and displaying the PHP information.

{{< picture src="../../local-containers/images/phpinfo.webp" caption="PHP Information" >}}

---

### Step 5: Stop and Restart the Space

1. To stop the space, click the menu icon (three dots) next to the space, then select `Stop` from the menu.

{{< picture src="../images/stop-space.webp" caption="Stop Space" >}}

2. Since the template was created with a persistent volume, restarting the space from the menu will restore it to the state it was in when it was stopped.

---

## What's Next

- [Advanced Configuration](../../../configuration)
