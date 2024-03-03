---
title: Managing a Space
weight: 10
---

## Example Template

This section assumes a template name `mytest` has been defined as follows:

```hcl {filename=Nomad-Job}
job "${{.space.name}}-${{.user.username}}" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert = false
  }

  group "debian" {
    count = 1

    network {
      port "knot_port" {
        to = 3000
      }
    }

    volume "home_volume" {
      type   = "csi"
      source = "debian_${{.space.id}}_home"
      read_only = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "debian" {
      driver = "docker"
      config {
        image = "paularlott/knot-debian:12"

        ports = ["knot_port"]
      }

      env {
        # Define environment variables for agent
        KNOT_SERVER = "${{ .server.url }}"
        KNOT_SPACEID = "${{ .space.id }}"
        KNOT_SSH_PORT = "22"
        KNOT_TCP_PORT = "80"
        KNOT_HTTP_PORT = "80"
        KNOT_CODE_SERVER_PORT = "49374"
        KNOT_LOGLEVEL = "debug"
        KNOT_USER = "${{ .user.username }}"

        TZ = "${{ .user.timezone }}"
      }

      volume_mount {
        volume      = "home_volume"
        destination = "/home"
      }

      resources {
        cpu = 300
        memory = 512
      }

      # Knot Agent Port
      service {
        name = "knot-${{ .space.id }}"
        port = "knot_port"

        check {
          name            = "alive"
          type            = "http"
          protocol        = "https"
          tls_skip_verify = true
          path            = "/ping"
          interval        = "10s"
          timeout         = "2s"
        }
      }
    }
  }
}
```

```yaml {filename=Volume-Definition}
volumes:
  - id: "debian_${{.space.id}}_home"
    name: "debian_${{.space.id}}_home"
    plugin_id: "cephrbd"
    capacity_min: 10G
    capacity_max: 10G
    mount_options:
      fs_type: "ext4"
      mount_flags:
        - rw
        - noatime
    capabilities:
      - access_mode: "single-node-writer"
        attachment_mode: "file-system"
    secrets:
      userID: "admin"
      userKey: "FWef0320r23rmvseE+oke2CXEwiifWODSaoqp4=="
    parameters:
      clusterID: "3abdeec0-ae9c-477b-ab36-d4e3c20e86d0"
      pool: "rbd"
      imageFeatures: "deep-flatten,exclusive-lock,fast-diff,layering,object-map"
```

## Service Password

A service password can be set by going `My Profile` and entering the chosen password in the `Service Password` field, if not set the system will generate a random password.

This can then be used in templates as the variable `${{ .user.service_password }}`, e.g. for a MariaDB server it can be used as the root password by setting the `MARIADB_ROOT_PASSWORD` environment variable `MARIADB_ROOT_PASSWORD = "${{.user.service_password}}"`.

{{< callout type="info" >}}
  If the password is change the new password isn't immediately made available to the spaces, however it will be used on the next start of the space.
{{< /callout >}}

## Creating a Space

From the `Templates` page open the menu next to the template to use and click `Create Space`:

![](/docs/working-with-spaces/create-space.webp)

{{< callout type="info" >}}
  Depending on the permissions the user has the option `Create Space For` maybe displayed, clicking this will prompt for the user under which the space is to be created. This allows an admin to create spaces for users.
{{< /callout >}}

The fllowing form will be presented:

![](/docs/working-with-spaces/create-space-form.webp)

Enter a name for the space e.g. `mytest` and leave the `Terminal Shell` as `Bash`, once `Create Space` is clicked the space will be created within knot and the main spaces page loaded.

The space is created in a stopped state, no resources are used within the Nomad cluster at this point.

The `Additional Space Names` section allows additional names to be entered against the space, this is useful when using the web proxy service and development needs to access the target software under multiple domain names.

### Manual Spaces

It's possible to run the agent manually on a virtual machine or even a physical server and connect to it from the knot web interface.

Select the `Manual-Configuration` template, then fill out the URL of the agent e.g. `http://192.168.0.1:3000` if the address can be found via a DNS SRV lookup then the URL can be given in the form `srv+http://vm.service.consul`.

## Starting a Space

From the `Spaces` page click the menu item next to the space to start, and then select `Start`, them menu will change to read "Starting" and after a few seconds the `Running` will show in the `Status` column.

![](/docs/working-with-spaces/start-space.webp)

The environment will continue its boot process during which time additional icons will appear next to the space, e.g. `Terminal`.

![](/docs/working-with-spaces/running-space.webp)

Not all icons will appear for all spaces as they are dependant on the agent configuration within the space.

- **SSH** Is shown when it's possible to create a SSH connection to the space, clicking the icon will show the command line information for connecting to the space.
- **Code Server** Is shown if a running instance of Visual Studio Code is found running within the space, clicking the icon opens a new tab or window showing the editor.
- **Terminal** Is shown if a web based terminal can be opened into the space, clicking the icon opens a new window showing the terminal.
- **Ports** Is shown if there's ports exposed that can either be connected to via the web interface or via port forwarding on the command line. Clicking the icon drops down a list of the available ports, ports shown with a solid background can be connected to by clicking the button and will open in a new tab or window, while ports with an outline are available for use with port forwarding on the command line.
- **Desktop** Is show if a running web based VNC server such as [KasmVNC](https://github.com/kasmtech/KasmVNC) is available within the container. Clicking it will open a new window displaying the graphical desktop.

## Stopping a Space

Clicking the menu item next to the running space will show the Stop button.

![](/docs/working-with-spaces/stopping-space.webp)

{{< callout type="warning" >}}
  When stopping a space all data in memory and not on a persistent volume will be lost. However any volumes used by the space will not be deleted.
{{< /callout >}}

## Updating a Space

If the template that a running space is using is updated then an `Update Available` badge is displayed:

![](/docs/working-with-spaces/space-update.webp)

To update the space, stop it and then start it again. Add volumes that have been added to the template will be created when the space starts and any volumes that have been removed from the template will be deleted along with the data they contain.

A space can also be edited, this allows changing of the space name as well as updating any additional names for the space. Additional URLs are supported as soon as the space is successfully saved.

## Deleting a Space

{{< callout type="error" >}}
  Deleting a space will delete the volumes and any data they contain.
{{< /callout >}}

Only stopped spaces can be deleted.

From the menu next to the stopped space select the `Delete` item and confirm deletion. When the space is deleted all resources are freed from the Nomad cluster and all volumes and their associated data are removed.
