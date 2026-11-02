---
title: Passkeys
description: Sign in to knot with a passkey instead of a password and authenticator code.
type: Overview
tags: [security, authentication, configuration]
weight: 61
---

Users can sign in to knot with a **passkey**, held by their device, browser or password manager, such as 1Password, instead of a password and authenticator code.

---

## Requirements

Passkeys need no configuration. They're available when:

- `server.url` uses a host name, not an IP address. The passkey is tied to that host, so users must reach knot at the same URL. If the host name changes, existing passkeys stop working.
- The server isn't a [leaf node](../leaf-mode/), which takes its users from its origin server.

When passkeys aren't available, the login page doesn't show the passkey button.

---

## Adding a Passkey

Users add passkeys from their **Profile** in the web interface, up to 20 each, and remove them there.

A passkey can't be added through the API with an API token, or while switched to another user.

An administrator with **Manage Users** can see and remove a user's passkeys when editing that user.

Adding and removing passkeys, and every passkey sign-in, is recorded in the audit log.

---

## Signing In

On the login page, choose **Sign in with a passkey**. A passkey signs in on its own, without a password or [authenticator code](../2fa/). An inactive user can't sign in with one.

Passkeys still work when [`disable_password_auth`](/docs/best-practices/security/authentication/) turns password sign-in off.

{{< pro-badge >}} A user whose sign-in provider has [`require_sso`](../oauth/#requiring-single-sign-on) set can neither add nor sign in with a passkey.
