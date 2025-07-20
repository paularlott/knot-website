---
title: Creating a Template
weight: 30
---

Once logged in to the **knot** web interface at `http://knot.internal:3000`, you'll be presented with a list of available spaces. Initially, this list will be blank.

{{< picture src="../images/spaces.webp" caption="Spaces on Login" >}}

In this tutorial, we'll create a space that runs PHP and includes a web server powered by Caddy.

---

## Step 1: Start a New Template

Start by clicking `Templates` and then `New Template`.

- Click on Templates in the navigation menu, then select New Template.
  {{< picture src="../images/new-template.webp" caption="New Template" >}}
- Fill out the following fields:
  - **Name:** Enter phptest.
  - **Description:** Enter a short description, such as A test space that runs PHP..
  - **Template Icon:** Type PHP in the field and select the PHP icon.

{{< tip >}}
The icon selected here will be the default icon for new spaces created from this template. However, it can be changed when creating a space.
{{< /tip >}}

---

## Step 2: Define the Job

Next, define the job for the template. In this case, we'll create a Docker-based space.

- Click on Docker to select the container type.
- In the **Container Specification** field, enter the following YAML configuration:

```yaml
container_name: ${{ .user.username }}-${{ .space.name }}
hostname: "${{ .space.name }}"
image: paularlott/knot-php:8.4
volumes:
  - volume1:/home/${{ .user.username }}

environment:
  - "TZ=${{.user.timezone}}"
  - "KNOT_USER=${{.user.username}}"
  - "KNOT_SERVER=${{.server.url}}"
  - "KNOT_AGENT_ENDPOINT=${{.server.agent_endpoint}}"
  - "KNOT_SPACEID=${{.space.id}}"
  - "KNOT_SERVICE_PASSWORD=${{.user.service_password}}"
  - "KNOT_HTTP_PORT=80=Web"

# Add the address of the host
add_host:
  - knot.internal:192.168.1.100
```

---

## Step 3: Add a Volume Definition

To ensure data persistence between reboots, define a volume to host the user's home directory within the container:

- In the **Volume Definition** field, enter the following YAML configuration:

```yaml
volumes:
  - volume1:
```

---

## Step 4: Enable Features

For this tutorial, we won't apply any restrictions. However, we'll enable the following features:

- **Web Terminal**
- **SSH Access**

{{< picture src="../images/template-features.webp" caption="Enable Template Features" >}}

---

## Step 5: View the New Template

Once saved, you'll be redirected to the `Templates` page, where your new template will be displayed.

{{< picture src="../images/templates.webp" caption="Templates" >}}

---

## What's Next

- [Creating a Space](../creating-a-space)
