---
description: Create the initial admin user to access the knot web interface.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/quick-start/local-containers/create-admin-user/
sources:
    - resource: https://getknot.dev/docs/quick-start/local-containers/create-admin-user/
status: stable
tags:
    - installation
    - security
    - authentication
title: Create Admin User
type: Guide
---
# Create Admin User

To create the initial admin user, follow these steps:

---

### Step 1: Access the Setup Page

Open your web browser and navigate to `https://knot.internal:3000`. Since knot uses a self-signed certificate by default, your browser may display a security warning. You'll need to accept the certificate to proceed. Look for an option like "Advanced" or "Proceed to knot.internal (unsafe)" depending on your browser.

If the server is running correctly, you'll see the setup form prompting you to create the initial user.



---

### Step 2: Create the Admin Account

Complete the form with the required information and click `Create User`. This will create your admin account. Once the account is created, the login form will appear.



---

### Step 3: Log In

Enter your username and password to log in.

The sidebar groups the pages into **Workspace** (spaces, files, tunnels and API tokens), **Build** (templates, variables, stack templates, volumes, scripts and the AI tools), **Admin** (users, groups, roles and the server) and **Extensions** (plugin pages); you only see the sections and pages your role allows. Each section opens and closes, and remembers how you left it. Star a page with the star beside it to put it in a **Starred** block at the top; reorder starred pages by dragging or with their up and down arrows.



To find anything quickly, press **Shift+⌘+K** (**Shift+Ctrl+K** on Windows and Linux) or click **Search** at the top of the page: it searches spaces, templates, scripts and the rest at once, and opens what you pick. On a list page, **⌘+K** (**Ctrl+K**) jumps to that page's own search box; **Alt** works in place of ⌘/Ctrl for both.



After logging in, click your name in the top-right corner of the screen to open the profile menu.



---

### Step 4: Update Profile and Timezone

From the profile menu, select `My Profile`. Here, you can edit your user information, including setting your timezone.

---

## What's Next

- [Creating a Template](creating-a-template.md)
