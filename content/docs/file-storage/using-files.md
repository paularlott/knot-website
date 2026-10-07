---
title: Using Files
description: Browse and manage files from the Files page, and copy and sync them with the knot file commands.
type: Guide
tags: [storage]
weight: 10
---

## The Files Page

**Files** in the sidebar lists the buckets you own or that are shared with you, with your access, size and your usage against your quota. The page updates by itself when files or buckets change, whether the change was made by you, someone else, or on another server in the cluster: changes are gathered for a moment and the page then refreshes what it shows. Open a bucket to browse its folders, then:

- **Upload files** or **Upload folder**, or drag files and folders onto the list; progress is shown per file.
- **Download** any file, or **View**/**Edit** text files up to 1 MB in place. Saving is refused if someone else changed the file since you opened it, so no change is silently lost.
- **New file** creates a text file, with `/` in the name for folders.
- **Delete** files, or a folder and everything in it.

As the owner with **Share Buckets**, **Share** lists who has access, changes each grant between read only and read & write, removes grants and adds users, groups or all users. As the owner with **Transfer Buckets**, **Transfer** gives the bucket to another user and shows the name it will have. File storage managers can share and transfer any bucket and tick **Show all buckets** to see every bucket. Users with read-only access see only View and Download.

The page is keyboard and screen reader friendly and uses nothing from outside the knot server.

---

## Working with Files

A bucket's files are written `bucket:path`, e.g. `configs:app/settings.toml` for your own bucket or `alice--configs:app/settings.toml` for one shared with you; `configs:` on its own is the bucket itself. Any other path is local, so which way a copy goes follows from the arguments. Keys may contain `/` to organise files into folders, but not empty, `.` or `..` segments.

```shell
knot file ls                                   # your buckets (alias: list)
knot file ls configs:                          # one level of a bucket
knot file ls -r configs:app                    # everything below app/
knot file ls 'configs:app/*.toml'              # files matching a wildcard

knot file copy settings.toml configs:app/      # upload, keeping the name (alias: cp)
knot file copy settings.toml configs:app/main.toml   # upload under another name
knot file copy -r ./dotfiles configs:dotfiles/ # a directory and everything in it
echo "debug = true" | knot file copy - configs:app/debug.toml

knot file copy configs:app/settings.toml .     # download into the current directory
knot file copy configs:app/settings.toml ~/.config/app/main.toml
knot file copy -r configs:dotfiles ~/dotfiles
knot file copy configs:app/settings.toml -     # to stdout; so does: knot file cat configs:app/settings.toml

knot file copy configs:app/settings.toml backups:app/   # between buckets, on the server
knot file copy -r configs: backups:2026-10-05/

knot file mv configs:app/old.toml configs:app/new.toml   # rename (alias: move)
knot file mv configs:app/new.toml configs:archive/       # move into a folder, keeping the name
knot file mv configs:app configs:app-2026                # a folder, with everything in it

knot file rm configs:app/debug.toml            # alias: delete
knot file rm -r configs:old

knot file usage                                # usage against your quota
```

### How `copy` works

- **Direction.** A path of the form `bucket:path` is in a bucket, anything else is local, and `-` is stdin or stdout. A copy goes from the sources to the destination, the last argument; at least one side must be a bucket. A local path with a colon in its name is written with a leading `./` (`./notes:v2.txt`) so it isn't read as a bucket, and a bucket name is at least three characters, so a Windows drive such as `C:\` is always local.
- **Into a folder.** Several sources, a directory or folder source, or a wildcard need a destination that is a folder: an existing local directory (or one ending in `/`, which is created), or a bucket path ending in `/`, or just `bucket:`. A single file goes to the name you give it, so write the `/` to copy into a folder. Files already at the destination are replaced, and two sources that would land on the same destination are refused before anything is copied.
- **Folders.** `-r` copies a directory or bucket folder with everything below it. Its *contents* go into the destination folder, as with `rsync` and `rclone copy`, rather than the directory itself, so `copy -r ./site configs:site/` puts `./site/index.html` at `site/index.html`. Without `-r` a directory or folder is refused. Empty folders in a bucket become empty directories on download.
- **Wildcards.** `*` and `?` match within one name and `[abc]` a set of characters, as in a shell; `**` matches any number of folders. Quote a pattern for a bucket path, `'configs:logs/*.log'`, so the shell leaves it alone (an unquoted pattern with no match is an error in zsh). Unquoted local patterns are expanded by the shell as usual, and `copy` expands a quoted one itself. A pattern takes only files, unless `-r` is given, when a folder it matches is taken with everything below it. Files keep their path below the part of the pattern before the first wildcard: `'logs/**/*.log'` copies `logs/2026/10/a.log` as `2026/10/a.log`. To match a character that is a wildcard, put it in brackets: `a[*]b`.
- **Between buckets.** A copy from one bucket to another, or within one, happens on the server and moves no data, however large the files, and keeps their content type, metadata and modification time. You need read access to the source and write access to the destination, and the destination bucket's owner is charged for the new file against their quota.
- **Standard input and output.** `copy - bucket:path/file` uploads stdin as one file, and `copy bucket:path/file -` writes one file to stdout.

`mv` renames or moves files and folders, with the same `bucket:path` arguments. A destination ending in `/`, or naming an existing folder, takes the sources into it and keeps their names; otherwise it is the new name, which needs a single source. Several sources and quoted wildcards (`'configs:logs/*.log'`) work as with `copy`, and a folder moves with everything below it. Within a bucket the move happens on the server and transfers no content, however large the files. Between buckets the files are copied on the server and then removed from the source, and you need write access to both. A move that would replace an existing file is refused before anything changes, unless `--overwrite` (`-f`) is given.

`rm` takes several paths and wildcards the same way: `knot file rm 'configs:logs/*.tmp' configs:old.txt`. A folder, or `bucket:`, needs `-r`, which deletes every file below it (the bucket itself stays; see `knot file bucket delete`). A path that matches nothing deletes nothing.

Uploads record the file's modification time and downloads restore it. Downloaded files are created readable by others (0644), or keep the mode of the file they replace.

Files fetched through the API are sent as attachments with a sandboxing `Content-Security-Policy`, so opening another user's HTML or SVG file in a browser downloads it rather than running it on the knot server.

### Syncing a directory

`knot file sync` makes a destination match a source, transferring only what differs, comparing files by size and SHA-256. Either side is a local directory or a bucket folder, and the direction follows from which is which:

```shell
knot file sync ./site configs:site                 # local -> bucket
knot file sync configs:site ./site                 # bucket -> local
knot file sync configs:site backups:site           # bucket -> bucket, on the server
knot file sync ./site configs:site --delete        # also remove files at the destination not in the source
knot file sync configs:site ./site -n              # dry run: show what would change
```

Modification times are kept in every direction. `--delete` removes files at the destination that aren't in the source. Between buckets only the files whose content differs are copied, with no data transferred, and folders in the same bucket that overlap are refused. `sync` takes folders, not wildcards.

**Which server.** Inside a space the commands discover the space's server and credentials through the agent — nothing to configure, so a space startup script can pull its configuration with `knot file copy`. On the desktop they use the connection saved by `knot connect`, choosing the server with `--alias` (default `default`). An explicit `--server`/`--token` pair overrides both, as with other knot commands.
