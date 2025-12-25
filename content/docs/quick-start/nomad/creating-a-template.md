---
title: Creating a Template
weight: 40
---

Once logged in to the **knot** web interface at `http://knot.internal` (or the domain you configured), you'll be presented with a list of available spaces. Initially, this list will be blank.

{{< picture src="../../local-containers/images/spaces.webp" caption="Spaces on Login" >}}

In this tutorial, we'll create a space that runs PHP and includes a web server powered by Caddy.

---

## Step 1: Start a New Template

1. Click on `Templates` in the navigation menu, then select `New Template`.

{{< picture src="../../local-containers/images/new-template.webp" caption="New Template" >}}

2. Fill out the following fields:
   - **Name**: Enter `phptest`.
   - **Description**: Enter a short description, such as `A test space that runs PHP.`.
   - **Template Icon**: Type `PHP` in the field and select the PHP icon.

{{< tip >}}
The icon selected here will be the default icon for new spaces created from this template. However, it can be changed when creating a space.
{{< /tip >}}

---

## Step 2: Define the Job

Next, define the job for the template. In this case, we'll create a Nomad-based space.

1. Click on `Nomad` to select the container type.
2. In the **Nomad Job** field, enter the following HCL configuration:

```hcl
job "${{.space.name}}-${{.user.username}}" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "1m"
    auto_revert = false
  }

  group "php" {
    count = 1

    volume "home_volume" {
      type            = "csi"
      source          = "${{.space.id}}"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "php" {
      driver = "docker"
      config {
        image = "paularlott/knot-php:8.4"
        hostname = "${{ .space.name }}"
      }

      volume_mount {
        volume      = "home_volume"
        destination = "/home"
      }

      env {
        # Define environment variables for agent
        KNOT_SERVER = "${{.server.url}}"
        KNOT_AGENT_ENDPOINT = "${{.server.agent_endpoint}}"
        KNOT_SPACEID = "${{.space.id}}"
        KNOT_HTTP_PORT = "80=Web"
        KNOT_LOGLEVEL = "info"
        KNOT_USER = "${{.user.username}}"
        KNOT_SERVICE_PASSWORD = "${{.user.service_password}}"
      }

      resources {
        cpu = 300
        memory = 4096
      }
    }
  }
}
```

---

## Step 3: Add a Volume Definition

To ensure data persistence between reboots, define a volume to host the user's home directory within the container:

1. In the **Volume Definition** field, enter the following YAML configuration:

```yaml
volumes:
  - id: "${{.space.id}}"
    name: "${{.space.id}}"
    plugin_id: "rbd"
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
      userID: "storage"
      userKey: "ZEKPDSUyCCE5RdmykazPRgezLbyvxvFQ"
    parameters:
      clusterID: "e8c43967-e62d-48a8-86d7-9e778d72f77f"
      pool: "rbd"
      imageFeatures: "deep-flatten,exclusive-lock,fast-diff,layering,object-map"
```

**Note:** This assumes that the Nomad cluster has access to Ceph RBD services and can create volumes on demand.

---

## Step 4: Enable Features

For this tutorial, we won't apply any restrictions. However, we'll enable the following features:

- **Web Terminal**
- **SSH Access**

{{< picture src="../../local-containers/images/template-features.webp" caption="Enable Template Features" >}}

---

## Step 5: View the New Template

Once saved, you'll be redirected to the `Templates` page, where your new template will be displayed.

{{< picture src="../../local-containers/images/templates.webp" caption="Templates" >}}

---

## What's Next

- [Creating a Space](../creating-a-space)
