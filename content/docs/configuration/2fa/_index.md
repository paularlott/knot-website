---
title: Two Factor Authentication
weight: 60
---

To enhance the security of **knot** installations, **knot** supports **Two-Factor Authentication (2FA)** through applications like **Google Authenticator**, **Microsoft Authenticator**, and even **1Password**.

---

## Enabling 2FA

To enable 2FA, edit the `knot.toml` configuration file and add the following section:

```toml
[server.totp]
enabled = true
issuer = 'Knot'
```

- The `enabled` field must be set to `true` to activate 2FA.
- The `issuer` field can be set to a string to identify your installation (e.g., "Knot").

After making these changes, restart **knot** to apply the configuration.

---

## First-Time Login with 2FA

Once 2FA is enabled, the login screen will include an additional entry box for the **One Time Password (OTP)**.

1. On the **first login**, enter your **Email** and **Password**, leaving the **One Time Password** field blank.
2. Click **Sign In**. A new one-time password will be generated, and a QR code will be displayed on the screen.

{{< picture src="images/new-totp.webp" caption="Login" >}}

3. Scan the QR code or record the secret within your authenticator application.
4. Click **I Have Recorded The Code** to complete the setup.

---

## Subsequent Logins

For all future logins, complete all three fields:

- **Email**
- **Password**
- **One Time Password**

If all three fields match, you will be successfully logged into the system.

## Resetting the TOTP

If a user loses access to their **One Time Password**, it can be reset using the command line. Run the following command, replacing `<email address>` with the email address of the user:

```shell
knot admin reset-totp <email address>
```

When the user next logs in, a new QR code will be generated, allowing them to set up 2FA again.
