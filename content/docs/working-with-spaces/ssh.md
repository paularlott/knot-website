---
title: SSH Access
weight: 60
---

## Adding a Public SSH Key

Click your username in the top right of the web interface and paste your public SSH key into the field `SSH Public Key`, then click `Update User`. This will set the public key to be used by all your containers when connecting via SSH to allow authentication without passwords.

![](/docs/working-with-spaces/ssh-key.webp)

## Connecting via SSH

SSH access requires the [knot client](/docs/install/client) be installed on the local computer as it will forward the SSH session to the remote container.

If not already done, on the client machine connect to the knot server, replacing the URL with the address of the real server, first open a terminal and run:

```bash
knot connect https://knot.example.com
```

When the command runs the browser is opened and if not logged in you will need to login, copy the generated token and paste into terminal.

Next open a SSH connection to the space called `mytest` by running the command below (adjust the username as required):

```bash
ssh -o ProxyCommand='knot forward ssh %h' -o StrictHostKeyChecking=no user@mytest
```

The SSH session will be opened to the container and can be used as per any other SSH connection.

## Using .ssh/config

To shorten the command for connecting to the remote space the following can be added to the `.ssh/config` file of the local computer:

```text {filename=".ssh/config"}
Host mytest
  HostName mytest
  StrictHostKeyChecking = no
  ProxyCommand knot forward ssh %h
```

Once this is done a SSH connection can be opened with:

```bash
ssh user@mytest
```

## Agent Forwarding

Adding the `-A` option to the ssh command will enable agent forwarding which allows SSH keys from the local machine to be used within the space.

The current list of keys exported can be found by running the following on the local machine:

```bash
ssh-add -L
```

SSH keys can be added with `ssh-add YOUR-KEY`

On macOS the ssh-agent will forget the key once it is restarted, e.g. the machine is rebooted, however the key can be added to the keychain with the `--apple-use-keychain` option, `ssh-add --apple-use-keychain YOUR-KEY`.
