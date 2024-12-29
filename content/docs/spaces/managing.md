---
title: Managing a Space
weight: 10
---

## Service Password

A service password can be set by going `My Profile` and entering the chosen password in the `Service Password` field, if not set the system will generate a random password.

This can then be used in templates as the variable `${{ .user.service_password }}`, e.g. for a MariaDB server it can be used as the root password by setting the `MARIADB_ROOT_PASSWORD` environment variable `MARIADB_ROOT_PASSWORD = "${{.user.service_password}}"`.

{{< callout type="info" >}}
  If the password is change the new password isn't immediately made available to the spaces, however it will be used on the next start of the space.
{{< /callout >}}

## Creating a Space

From the `Templates` page open the menu for the template to use and click `Create Space`:

{{< image src="../create-space.webp" alt="Create Space" >}}

{{< callout type="info" >}}
  Depending on the permissions the user has the option `Create Space For` maybe displayed, clicking this will prompt for the user under which the space is to be created. This allows an admin to create spaces for users.
{{< /callout >}}

The following form will be presented:

{{< image src="../create-space-form.webp" alt="Create Space Form" >}}

Enter a name for the space e.g. `mytest` and leave the `Terminal Shell` as `Bash`, once `Create Space` is clicked the space will be created within knot and the main spaces page loaded.

The space is created in a stopped state, no resources are used until the space is started.

The `Additional Space Names` section allows additional names to be entered against the space, this is useful when using the web proxy service and development needs to access the target software under multiple domain names.

## Starting a Space

From the `Spaces` page click the menu item next to the space to start, and then select `Start`, them menu will change to read "Starting" and after a few seconds `Running` will show next to `Status`.

{{< image src="../start-space.webp" alt="Start Space" >}}

Spaces created from manual templates don't have a `Start` option, they are started automatically when their agent connects to the server.

The environment will continue its boot process during which time additional icons will appear next to the space, e.g. `Terminal`.

{{< image src="../running-space.webp" alt="Running Space" >}}

Not all icons will appear for all spaces as they are dependant on the agent configuration within the space.

- **Desktop** Is shown if a running web based VNC server such as [KasmVNC](https://github.com/kasmtech/KasmVNC) is available within the container. Clicking it will open a new window displaying the graphical desktop.
- **Code Server** Is shown if a running instance of Code Server is found running within the space, clicking the icon opens a new tab or window showing the editor.
- **Visual Studio Code** Is shown if a running instance of Visual Studio Code tunnels is found running within the space, clicking the icon opens a new tab or window showing the editor. If the Visual Studio Code tunnel hasn't been created then a terminal is opened allowing the tunnel to be created.
- **Terminal** Is shown if a web based terminal can be opened into the space, clicking the icon opens a new window showing the terminal.
- **Ports** Is shown if there's ports exposed that can either be connected to via the web interface or via port forwarding on the command line. Clicking the icon drops down a list of the available ports, ports shown with a solid background can be connected to by clicking the button and will open in a new tab or window, while ports with an outline are available for use with port forwarding on the command line.
- **SSH Info** Is shown in the space menu when it's possible to create a SSH connection to the space, clicking the icon will show the command line information for connecting to the space.

## Stopping a Space

Clicking the menu item next to the running space will show the Stop button.

{{< image src="../stopping-a-space.webp" alt="Stopping a Space" >}}

{{< callout type="warning" >}}
  When stopping a space all data in memory and not on a persistent volume will be lost. However any volumes used by the space will not be deleted.
{{< /callout >}}

## Updating a Space

If the template that a running space is using is updated then an `Update Available` badge is displayed:

{{< image src="../update-pending.webp" alt="Update Pending" >}}

To update the space, stop it and then start it again.

Volumes that have been added to the template will be created when the space starts and any volumes that have been removed from the template will be deleted along with the data they contain.

A space can also be edited, this allows changing of the space name as well as updating any additional names for the space. Additional URLs are supported as soon as the space is successfully saved.

## Deleting a Space

{{< callout type="error" >}}
  Deleting a space will delete the volumes and any data they contain.
{{< /callout >}}

Only stopped spaces can be deleted.

From the menu next to the stopped space select the `Delete` item and confirm deletion. When the space is deleted all resources are freed and all volumes and their associated data are removed.
