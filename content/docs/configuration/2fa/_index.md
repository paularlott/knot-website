---
title: Two Factor Authentication
linkTitle: 2FA
description: Enable TOTP-based two-factor authentication for enhanced login security.
type: Overview
tags: [security, authentication, configuration]
weight: 60
---

To enhance the security of Knot installations, Knot supports **Two-Factor Authentication (2FA)** through applications like **Google Authenticator**, **Microsoft Authenticator**, and even **1Password**.

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

After making these changes, restart Knot to apply the configuration.

---

## First-Time Login with 2FA

Once 2FA is enabled, the login screen includes an extra **Authenticator code** field.

1. On the **first login**, enter your **Email** and **Password** and leave the **Authenticator code** field blank.
2. Click **Sign In**. A new secret is generated and shown with a QR code.
3. Scan the QR code, or enter the secret by hand, in your authenticator application.
4. Enter the 6-digit code your authenticator application shows and click **Verify and continue**.

If the code doesn't match, check that the secret in your app is the one shown on screen, wait for the next code and try again; the secret stays the same, so you can scan the QR code again. Repeated wrong codes count towards the same rate limit as failed logins and are recorded in the audit log.

You can view the secret again later from your profile page.

---

## Subsequent Logins

For all future logins, complete all three fields:

- **Email**
- **Password**
- **Authenticator code**

If all three fields match, you will be successfully logged into the system.

## Resetting the TOTP

If a user loses access to their **One Time Password**, it can be reset using the command line. Run the following command, replacing `<email address>` with the email address of the user:

```shell
knot admin reset-totp <email address>
```

When the user next logs in, a new QR code will be generated, allowing them to set up 2FA again.
