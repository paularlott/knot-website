---
title: SSH Access
weight: 80
---

SSH access allows you to securely connect to your spaces for advanced management and development. This guide explains how to set up SSH keys, connect via SSH, and simplify connections using `.ssh/config`.

---

## Adding a Public SSH Key

1. Click your username in the top-right corner of the web interface and select **`My Profile`**.
2. Paste your public SSH key into the **`SSH Public Key`** field and click **`Update`**.
   - This key will be used for all your containers, enabling passwordless authentication.
   {{< picture src="../images/profile-sshkey.webp" caption="SSH Public Key" >}}

3. Alternatively, automatically fetch your public keys from GitHub by entering your GitHub username in the **`GitHub Username`** field.

---

## Connecting via SSH

### Step 1: Connect to the **knot** Server

1. Ensure the **knot** [client](/docs/quick-start/client/) is installed on your local machine.
2. Open a terminal and run the following command, replacing the URL with your **knot** server's address:

   ```shell
   knot connect https://knot.internal:3000
   ```

3. Enter your username and password when prompted.
4. The generated access key will be stored in `~/.config/knot/knot.yml` for future use.

---

### Step 2: Open an SSH Connection

1. Use the following command to connect to a space (e.g., `phptest`), replacing `user` with your username:

   ```shell
   ssh -o ProxyCommand='knot forward ssh %h' -o StrictHostKeyChecking=no user@phptest
   ```

2. This will open an SSH session to the space, functioning like any other SSH connection.

---

## Simplifying Connections with `.ssh/config`

To streamline SSH connections, add the following configuration to your local machine's `.ssh/config` file:

```text {filename=".ssh/config"}
Host knot.phptest
  HostName knot.phptest
  StrictHostKeyChecking=no
  LogLevel ERROR
  UserKnownHostsFile=/dev/null
  ProxyCommand knot forward ssh phptest
```

Once added, you can connect to the space with a shorter command:

```bash
ssh user@phptest
```

### Automating `.ssh/config` Updates

The **knot** client includes a helper function to manage `.ssh/config` entries for all your spaces:

- **Add entries for all spaces**:
  ```shell
  knot ssh-config update
  ```

- **Remove all entries**:
  ```shell
  knot ssh-config remove
  ```

---

## Enabling Agent Forwarding

Agent forwarding allows you to use SSH keys from your local machine within the space. To enable it, add the `-A` option to your SSH command:

```bash
ssh -A user@phptest
```

### Managing SSH Keys

- **View exported keys**:
  ```bash
  ssh-add -L
  ```

- **Add a key**:
  ```bash
  ssh-add YOUR-KEY
  ```

### Persistent Keys on macOS

On macOS, the `ssh-agent` forgets keys after a restart. To persist keys in the keychain, use the `--apple-use-keychain` option:

```shell
ssh-add --apple-use-keychain ~/.ssh/id_rsa
```
