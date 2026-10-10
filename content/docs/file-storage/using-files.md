---
title: Using Files
description: Browse and manage files from the Files page, and copy and sync them with the knot file commands.
type: Guide
tags: [storage]
weight: 10
---

## The Files Page

**Files** in the sidebar lists the buckets you own or that are shared with you, with your access, size and your usage against your quota. The page updates by itself when files or buckets change, whether the change was made by you, someone else, or on another server in the cluster: changes are gathered for a moment and the page then refreshes what it shows. Click the folder icon on a bucket, or its name, to browse its folders. The path above the file list shows where you are and takes you back up. Then:

- **Upload files** or **Upload folder**, or drag files and folders onto the list; progress is shown per file.
- **Download** any file, or **View**/**Edit** text files up to 1 MB in place. The editor highlights the language it recognises from the file name, including Markdown, YAML, TOML, JSON, PHP, Python, shell, JavaScript, HTML, CSS, XML, INI, SQL, Go, Dockerfile and HCL, and a **Language** picker changes it. Ctrl+S or ⌘S saves. Saving is refused if someone else changed the file since you opened it, so no change is silently lost.
- **New file** creates a text file, with `/` in the name for folders.
- **Rename or move** a file, or a folder with everything in it: the dialog takes the new path in the bucket, so changing just the name renames it and adding folders (`archive/2026/report.txt`) moves it, creating the folders if they don't exist. Or drag a row onto a folder, or onto a part of the path above the list, to move it there. Moves happen on the server without transferring any content, and are refused rather than replacing an existing file. Files can't be moved between buckets here; use [`knot file mv`](#working-with-files).
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

Modification times are kept in every direction. `--delete` removes files at the destination that aren't in the source. Between buckets only the files whose content differs are copied, with no data transferred, and folders in the same bucket that overlap are refused. `sync` takes folders, not wildcards. A file renamed or copied locally isn't uploaded again when the bucket already has its content: it is copied on the server, or, if the old file was deleted within the last hour, its content is reused.

#### Keeping a directory in sync

`--watch` keeps the sync running after the first pass and makes each change as it happens, until you stop it with Ctrl+C. Local changes are seen as they are made; the bucket's arrive through the server's live updates, so a file written from the web interface, another machine or S3 reaches the directory within a second or so. If the live updates are unavailable the bucket is checked every 15 seconds instead, and both sides are looked at in full every few minutes as a safety net. Each file uploaded, downloaded or deleted is logged as it happens; `knot --log-level debug file sync ...` also logs each pass and the state of the live updates, and `--log-level warn` only conflicts and problems.

```shell
knot file sync ./site configs:site --watch --delete   # publish as you edit
knot file sync configs:site ./site --watch --delete   # follow a bucket folder
```

#### Two-way sync

`--two-way` syncs a directory and a bucket folder in both directions: a change on either side is made on the other. Add `--watch` to keep them in step continually, for example to work on the same files from your desktop and a space, or from two machines:

```shell
knot file sync --two-way --watch ./notes notes:        # changes either side, made on the other
knot file sync --two-way --watch --delete ./notes notes:  # deletions are passed across too
```

- **Conflicts.** A file changed on both sides since they last matched is kept both ways: the bucket's version keeps the name and the local one is renamed beside it, on both sides, as `name.conflict-<host>-<time>.ext`. Nothing is ever silently overwritten; an upload is only made against the version of the file it was planned against.
- **Deletions.** Without `--delete` a file deleted on one side is put back from the other. With it the deletion is made on the other side, unless the file was changed there since, in which case the change wins and the file comes back.
- **State.** The sync remembers what the two sides last agreed on, so it can tell a deletion from a new file. The state is kept in your configuration directory (`~/.config/knot/sync` on Linux, `~/Library/Application Support/knot/sync` on macOS), or where `--state-file` says. The first run of a pair, with no state, deletes nothing: files on one side only are copied to the other and files that differ are kept both ways.

#### What is left out

`--exclude` (`-x`, repeatable) leaves out paths matching a pattern, such as `node_modules/` (a trailing `/` matches folders only) or `*.log`; patterns match a file's name or its path, and excluding a folder excludes everything in it. Excluded files are neither copied nor deleted on either side.

A continual (`--watch`) or two-way sync also leaves out version control folders (`.git`, `.hg`, `.svn`) and the scratch files editors and the system write beside your files (`.DS_Store`, `Thumbs.db`, swap and backup files such as `.*.swp` and `*~`). Give `--no-default-excludes` to sync them too. A single one-way sync copies everything not excluded, `.git` included.

#### Safety

- **Mass deletions.** A pass that would delete more than half of a side's files (when that's more than 10), or everything because the other side came up empty — a directory not mounted, a share withdrawn — is refused, and a single sync then changes nothing. While watching, the deletions are held back with a warning and everything else carries on. Give `--allow-mass-delete` when you do mean it.
- **Case.** Bucket names are case-sensitive. On a file system that ignores case (macOS and Windows by default) two bucket files whose names differ only in case can't both be stored, so the second is skipped with a warning rather than written over the first, and a local file spelled differently from the bucket's is treated as the same file.
- `--dry-run` shows what a single pass would do; it can't be combined with `--watch`.

**Which server.** Inside a space the commands discover the space's server and credentials through the agent — nothing to configure, so a space startup script can pull its configuration with `knot file copy`. On the desktop they use the connection saved by `knot connect`, choosing the server with `--alias` (default `default`). An explicit `--server`/`--token` pair overrides both, as with other knot commands.
