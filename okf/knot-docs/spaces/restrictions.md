---
description: Lock a space down - choose which buckets it can reach, make file storage read-only, switch off personal secrets, or lock its processes out of everything else.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/spaces/restrictions/
sources:
    - resource: https://getknot.dev/docs/spaces/restrictions/
status: stable
tags:
    - spaces
    - security
    - file-storage
title: Space Restrictions
type: Guide
---
# Space Restrictions

A space can restrict what it can reach, for example before running an AI agent or code you don't fully trust. Restrictions apply to the space's own credential, which the knot command, scripts and tools inside the space use, and hold, across restarts, until they're lifted from the web interface or the knot command on your desktop.

You can:

- keep only the [buckets](../file-storage.md) you name, each read-only or read and write, and hide all the others
- make file storage read-only, or switch it off
- switch off [personal secrets](../variables/personal-secrets.md) 
- lock the space's processes out of everything else, leaving their files, secrets, and restart and shut down

They add to what the space's template switches off; they can't turn back on anything the template turns off.

## Restrict a space from inside it

```sh
knot restrict --bucket notes:ro --bucket scratch --no-secrets
```

Repeat `--bucket` for each bucket to keep, adding `:ro` to make it read-only. Buckets shared with you use their full name, such as `alice--assets:ro`. Every other bucket is hidden, including ones created or shared with you later.

Other options:

| Option | Effect |
|---|---|
| `--files ro` | Every bucket the space can reach becomes read-only |
| `--no-files` | Switch file storage off |
| `--no-secrets` | Switch personal secrets off |
| `--secret-allow <prefix>` | Allow only personal secrets under this prefix; see below |
| `--secret-deny <prefix>` | Refuse personal secrets under this prefix; see below |
| `--lock` | Lock the space's processes out of everything but files and secrets; see below |

From inside a space restrictions only ever tighten. A bucket that has been dropped can't be added back, read-only stays read-only, and nothing in the space can lift them, not even restarting it. That makes it safe to restrict a space from its [startup script](startup-scripts.md): the first start applies them, and every start after that is restricted from the moment it begins:

```python
import knot.space

knot.space.restrict(buckets=["notes:ro", "scratch"], no_secrets=True)
```

### Limit personal secrets by path

 Rather than switch [personal secrets](../variables/personal-secrets.md) off, a space can keep only some of them:

```sh
knot restrict --secret-allow op://Dev/ --secret-deny op://Dev/Root/
```

Each prefix starts with its source's scheme, such as `op://`, and matches the start of the secret's reference without regard to case. End a prefix with `/` to cover a whole vault or item: `op://Dev/` covers `op://dev/Database/password` but not `op://DevOps/...`.

- With only `--secret-deny`, every secret is allowed except those under a denied prefix.
- With `--secret-allow`, only secrets under an allowed prefix can be read. A denied prefix still refuses those under it.

Repeat either option for more prefixes. Added later, they still only tighten: denied prefixes add to the ones already denied, and allowed prefixes narrow the ones already allowed, so allowing a prefix outside them leaves the space with no secrets.

To see what a space is restricted to:

```sh
knot restrictions
```

It shows, as do `knot space restrictions <space>` and the space's **Restricted** badge in the web interface, three areas: **secrets**, allowed, off, or limited to the prefixes listed; **files**, every bucket or only the ones kept, each read & write or read-only, or off; and **other access**, confined to the space, or locked.

## Lock the space

```sh
knot restrict --lock
```

Each restriction covers one area: `--bucket`, `--files` and `--no-files` govern file storage, `--no-secrets`, `--secret-allow` and `--secret-deny` govern personal secrets , and `--lock` covers everything else. With `--lock`, the knot command, scripts and tools in the space keep the files and secrets their other restrictions allow, and can restart or shut the space down (`knot agent restart`, `knot agent shutdown`), show its restrictions and add more, such as `--no-files`; everything else, from port forwards and tunnels to fields, events and methods, is refused. Logs the space's services send to the agent still reach the space's log stream.

To lock a space down completely, combine them: `knot restrict --lock --no-files --no-secrets`.

What you start from outside the space keeps working, because the agent carries it out with its own credential, which the space's processes never see:

- port forwards and commands added from the web interface or the knot command on your desktop
- scripts run in the space from outside, such as `knot space run-script`, and the space's startup scripts, which can still use the knot API, within the space's other restrictions

So a startup script can call `knot.space.restrict(lock=True)` at any point and carry on afterwards.

## A restricted space is confined

A space's credential acts as its owner, so without limits it could step around its restrictions, for example by making an API token or running a command in another space. Any restriction therefore also confines the space. It can still:

- do anything to itself, such as running commands, copying files, jobs, logs and port forwards
- reach the buckets it is allowed
- use tunnels and reach other spaces' ports
- read its owner's details, the list of spaces and templates, and scripts
- start, stop and restart other spaces and stacks

Everything else is refused: making API tokens, running commands or scripts in other spaces or changing them, calling methods, changing the owner's account or skills, the MCP endpoint, pools, and managing buckets (creating, sharing, transferring or deleting them). A restricted space also no longer gets its owner's SSH private key or service password.

Restrictions limit what the space's own credential can do. If you put a personal API token in the space, for example in a `knot.toml`, anything that reads it can use your full access, so don't for code you don't trust.

## Restrict a space from outside

The space's owner, anyone it is shared with, and users with the Manage Spaces permission can restrict a space from the knot command, or lift its restrictions:

```sh
knot space restrict my-space --files ro
knot space restrictions my-space
knot space restrict my-space --clear
```

On the Spaces page a restricted space shows a **Restricted** badge. Select it to see the restrictions or lift them.



Restarting a space keeps its restrictions. When a pool member's lease ends and it goes back to the pool, its restrictions are lifted, so the next lease starts unrestricted. Every change is recorded in the audit log as a Space Restrict event.
