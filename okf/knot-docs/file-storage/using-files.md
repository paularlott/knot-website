---
description: Browse and manage files from the Files page, and copy and sync them with the knot file commands.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/file-storage/using-files/
sources:
    - resource: https://getknot.dev/docs/file-storage/using-files/
status: stable
tags:
    - storage
title: Using Files
type: Guide
---
# Using Files

 File storage is experimental: its behaviour, commands and on-disk formats may change in later releases.

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

knot file move configs:app/old.toml configs:app/new.toml # rename (alias: mv)
knot file mv configs:app/new.toml configs:archive/       # move into a folder, keeping the name
knot file mv configs:app configs:app-2026                # a folder, with everything in it

knot file snapshot configs:app/ backups:app/2026-11-06/ # a folder as it is at one moment

knot file cat configs:app/a.toml configs:app/b.toml   # several files to stdout, one after another

knot file rm configs:app/debug.toml            # alias: delete
knot file rm -r configs:old

knot file usage                                # usage against your quota
```

`--json` prints the result of `ls`, `usage`, `bucket list`, `bucket info` and `bucket permissions` as JSON, for scripts. File storage managers can add `--all` to `knot file ls` (with no path) or `knot file bucket list` to list every bucket. `bucket share` and `bucket unshare` take `-u` for `--user`, `-g` for `--group` and, on `share`, `-w` for `--write`.

### How `copy` works

- **Direction.** A path of the form `bucket:path` is in a bucket, anything else is local, and `-` is stdin or stdout. A copy goes from the sources to the destination, the last argument; at least one side must be a bucket. A local path with a colon in its name is written with a leading `./` (`./notes:v2.txt`) so it isn't read as a bucket, and a bucket name is at least three characters, so a Windows drive such as `C:\` is always local.
- **Into a folder.** Several sources, a directory or folder source, or a wildcard need a destination that is a folder: an existing local directory (or one ending in `/`, which is created), or a bucket path ending in `/`, or just `bucket:`. A single file goes to the name you give it, so write the `/` to copy into a folder. Files already at the destination are replaced, and two sources that would land on the same destination are refused before anything is copied.
- **Folders.** `-r` copies a directory or bucket folder with everything below it. Its *contents* go into the destination folder, as with `rsync` and `rclone copy`, rather than the directory itself, so `copy -r ./site configs:site/` puts `./site/index.html` at `site/index.html`. Without `-r` a directory or folder is refused. The folders below it are copied too, empty ones included, with their modes (see [Folders](#folders)).
- **Wildcards.** `*` and `?` match within one name and `[abc]` a set of characters, as in a shell; `**` matches any number of folders. Quote a pattern for a bucket path, `'configs:logs/*.log'`, so the shell leaves it alone (an unquoted pattern with no match is an error in zsh). Unquoted local patterns are expanded by the shell as usual, and `copy` expands a quoted one itself. A pattern takes only files, unless `-r` is given, when a folder it matches is taken with everything below it. Files keep their path below the part of the pattern before the first wildcard: `'logs/**/*.log'` copies `logs/2026/10/a.log` as `2026/10/a.log`. To match a character that is a wildcard, put it in brackets: `a[*]b`.
- **Between buckets.** A copy from one bucket to another, or within one, happens on the server and moves no data, however large the files, and keeps their content type, metadata and modification time. You need read access to the source and write access to the destination, and the destination bucket's owner is charged for the new file against their quota.
- **Standard input and output.** `copy - bucket:path/file` uploads stdin as one file, and `copy bucket:path/file -` writes one file to stdout.

`move` (`mv`) renames or moves files and folders, with the same `bucket:path` arguments. A destination ending in `/`, or naming an existing folder, takes the sources into it and keeps their names; otherwise it is the new name, which needs a single source. Several sources and quoted wildcards (`'configs:logs/*.log'`) work as with `copy`, and a folder moves with everything below it. Within a bucket the move happens on the server and transfers no content, however large the files. Between buckets the files are copied on the server and then removed from the source, and you need write access to both. A move that would replace an existing file is refused before anything changes, unless `--overwrite` (`-f`) is given.

`snapshot` copies a folder and everything below it to a new folder, in the same bucket or another, as the folder was at one moment: every file is read at once on the server, so however much is being written to the folder, the copy never holds some files older or newer than the rest, as a `copy -r` made a file at a time can. `bucket:` is the whole bucket. Like a copy between buckets it transfers no content, and the destination bucket's owner is charged for every file. The new folder must not exist; its files appear over a moment, and the snapshot is complete once its manifest, `.knot-snapshot.json`, which records where and when it was taken, is there. A snapshot that fails part way takes away what it wrote. It holds what the server holds, so writes still being saved over [NFS](nfs.md) or by a `sync` are not in it until they reach the server.

`rm` takes several paths and wildcards the same way: `knot file rm 'configs:logs/*.tmp' configs:old.txt`. A folder, or `bucket:`, needs `-r`, which deletes every file below it (the bucket itself stays; see `knot file bucket delete`). A path that matches nothing deletes nothing.

Uploads record the file's modification time and mode (its permission bits) and downloads restore them, so a script copied up and back stays executable. A file stored before modes were kept has none, and is downloaded readable by others (0644), or keeps the mode of the file it replaces. Modes are stored as rclone stores them with `--metadata`, so a file shows the same mode through the knot command, the [NFS server](nfs.md) and [S3](s3.md) . On Windows, which has no such modes, none are recorded or restored.

Replacing a file without giving a mode, from the web interface, a script or `knot file cp -` (stdin), keeps the mode the file had. A new file written without one gets 0644, and a folder 0755, so a file uploaded from the web interface is readable by others and shows the same mode over NFS and S3 as from the knot command.

Symbolic links found inside a folder copied with `-r`, or synced, are copied as links, not followed, as `cp -R` and `rsync -a` copy them, so composer's `vendor/bin` keeps working and a link to a folder outside isn't copied in. A link is stored as the [NFS server](nfs.md) stores one, so it is a link over NFS too. A file or folder named on the command line is followed. Downloads never write through a link: a file whose path passes through a local link is refused, so a bucket can't place files outside the destination. On Windows links are not copied.

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

Modification times and modes are kept in every direction, and a file whose mode alone changed, after a `chmod`, has just its mode updated, without its content being sent again. Folders are synced too, empty ones included, with their modes (see [Folders](#folders)). `--delete` removes files and folders at the destination that aren't in the source; a local folder is only removed once it is empty. Between buckets only the files whose content differs are copied, with no data transferred, and folders in the same bucket that overlap are refused. `sync` takes folders, not wildcards. A file renamed or copied locally isn't uploaded again when the bucket already has its content: it is copied on the server, or, if the old file was deleted within the last hour, its content is reused.

#### Keeping a directory in sync

`--watch` (`-w`) and `--two-way` work between a local directory and a bucket folder only, not between two bucket folders. `--watch` keeps the sync running after the first pass and makes each change as it happens, until you stop it with Ctrl+C. Local changes are seen as they are made; the bucket's arrive through the server's live updates, so a file written from the web interface, another machine or S3 reaches the directory within a second or so. If the live updates are unavailable the bucket is checked every 15 seconds instead, and both sides are looked at in full every few minutes as a safety net. Each file uploaded, downloaded or deleted is logged as it happens; `knot --log-level debug file sync ...` also logs each pass and the state of the live updates, and `--log-level warn` only conflicts and problems.

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

- **Conflicts.** A file changed on both sides since they last matched is kept both ways: the bucket's version keeps the name and the local one is renamed beside it, on both sides, as `name.conflict-<host>-<time>.ext`: `report.txt` changed on both sides on the machine `laptop` leaves `report.txt` (the bucket's version) and `report.conflict-laptop-20261012-143005.txt` (yours). Nothing is ever silently overwritten or deleted: an upload or a deletion in the bucket is only made against the version of the file it was planned against, so a file changed there meanwhile is left for the next pass, where the change wins.
- **Deletions.** Without `--delete` a file deleted on one side is put back from the other. With it the deletion is made on the other side, unless the file was changed there since, in which case the change wins and the file comes back.
- **Links.** Symbolic links are synced as links in both directions; a link and a file of the same name are different files.
- **Modes.** A mode changed on one side is set on the other. Changed on both sides since they last matched, this side's wins; with no earlier sync to go by, the bucket's.
- **State.** The sync remembers what the two sides last agreed on, so it can tell a deletion from a new file. The state is kept in the [sync folder](#where-the-sync-keeps-its-files), or where `--state-file` says (it applies to `--two-way` only; a one-way sync keeps no state). The first run of a pair, with no state, deletes nothing: files on one side only are copied to the other and files that differ are kept both ways.

#### Folders

A folder is kept in a bucket as the [NFS server](nfs.md) keeps one: a marker, an empty object named for the folder with a trailing `/` (`site/assets/`), which holds the folder's mode. `sync` and `copy -r` give every folder they upload a marker, as `mkdir` over NFS does, so a tree looks the same in the bucket whichever way it arrived, and an empty folder is kept. Downloads make each folder with its marker's mode; a folder made read-only is made so once everything in it is written. A `chmod` of a folder on either side reaches the other, as a file's does, and `--watch` picks up folders made, removed and changed as it does files.

A folder with no marker, from an S3 client or a sync by knot before 0.42, is there because files are below it, and has no mode of its own: downloads make it 0755. The next sync up gives it a marker. On Windows folders are synced without modes.

#### Large directories

A sync reads a file for its checksum only when it has changed since it was last read: the checksums are kept between runs in the [sync folder](#where-the-sync-keeps-its-files), so a second sync of a large tree that has not changed takes seconds, without reading the files again. A file counts as changed when its size, its modification time, or, on macOS and Linux, its inode number or change time differs, so an edit made by a tool that puts the modification time back (`cp -p`, `tar x`, `rsync -t`, `touch -r`) is still noticed. On Windows only size and modification time are compared, as `rsync` does by default. Give `--hash-file` to keep the checksums somewhere else, such as beside the directory: `knot file sync ~/notes notes: --hash-file ~/.notes-hashes`. A checksum file inside the directory being synced is never synced itself.

**Large files** of 256 MiB or more are sent in parts of 64 MiB, by `copy` and `sync` alike. An upload stopped part way, by a lost connection or an interrupted command, carries on from the parts already sent the next time it is run, as long as the file hasn't changed meanwhile; each part the server holds is checked against the local file before it is used. The server keeps the parts of an unfinished upload for a week. Parts are held by the server that received them, so an upload carries on only through the same server.

**Stalled transfers.** A transfer of file content, either way, is given up after two minutes without any data moving, rather than waiting on the network to notice a dead connection; there is no limit on how long a transfer takes in all, so a large file is never cut off part way. A `--watch` sync carries on and tries again on its next pass.

While watching, local changes are seen as they are made, however large the tree:

- **macOS** watches the whole directory with FSEvents, in one stream, so there is no limit on the number of files or folders.
- **Linux** watches each folder with inotify, up to `fs.inotify.max_user_watches` for all of a user's processes (and, in a container, for every container on the host). When the limit is reached, the sync says so once, with how many folders could not be watched and the setting to raise; changes in those folders are found by the full scan every five minutes until it is raised:

  ```shell
  sudo sysctl fs.inotify.max_user_watches=524288
  echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/90-knot.conf
  ```

- **Windows** watches each folder, with no low limit.

A folder that appears, from a move, an unpack or a package install, is looked at on its own, not by walking the whole tree.

#### Where the sync keeps its files

The sync keeps a few files of its own in the **sync folder** of your configuration directory:

| System | Sync folder |
|---|---|
| Linux | `~/.config/knot/sync` (or `$XDG_CONFIG_HOME/knot/sync`) |
| macOS | `~/Library/Application Support/knot/sync` |
| Windows | `%AppData%\knot\sync` |

| File | Holds | Removed when |
|---|---|---|
| `hashes-<id>.bin` | the checksums of a local directory's files, one per directory (`--hash-file` moves it) | unused for 90 days |
| `state-<id>.bin` | the state of a two-way sync, one per directory and bucket folder (`--state-file` moves it) | unused for 90 days |
| `upload-<id>.json` | where an unfinished upload in parts got to | the upload completes, or after 7 days, when the server has let its parts go |

The checksums and the two-way state hold an entry for every file synced, which for a large tree is tens of megabytes, so they aren't written out whole each time: a change appends a record of a few dozen bytes for each file it touched. Once the records replaced by later ones outweigh the rest, the file is written afresh, so it never grows much past twice what it holds. Each record carries its own checksum. A file damaged, or cut short by a crash, keeps the records before the damage: for the files after it, a lost checksum means the file is read once more, and a lost two-way state entry means that file is synced as on a first run. The sync says when a state was damaged, and writes it afresh. The sync doesn't force each change to disk, which would make every pass wait on the drive: a power cut can lose the last changes, which costs no more than damage does. A file named with `--hash-file` or `--state-file` that isn't one of these is left alone and the sync refused, rather than overwritten.

Every sync marks the files it uses, and removes from the sync folder those unused for that long, so a directory you no longer sync doesn't leave its checksums behind for good. All of them can be deleted by hand at any time, for example to free the space or start afresh, as long as no sync is running: without the checksums the next sync reads each file once more, without a two-way state it is a first run, which deletes nothing, and without an upload record a large file is sent again from the start. Files kept elsewhere with `--hash-file` or `--state-file` are yours to remove; they are not swept.

#### What is left out

`--exclude` (`-x`, repeatable) leaves out paths matching a pattern, such as `node_modules/` (a trailing `/` matches folders only) or `*.log`; patterns match a file's name or its path, and excluding a folder excludes everything in it. Excluded files are neither copied nor deleted on either side.

A continual (`--watch`) or two-way sync also leaves out version control folders (`.git`, `.hg`, `.svn`) and the scratch files editors and the system write beside your files (`.DS_Store`, `Thumbs.db`, swap and backup files such as `.*.swp` and `*~`). Give `--no-default-excludes` to sync them too. A single one-way sync copies everything not excluded, `.git` included.

#### Safety

- **Mass deletions.** A pass that would delete more than half of a side's files (when that's more than 10), or everything because the other side came up empty — a directory not mounted, a share withdrawn — is refused, and a single sync then changes nothing. While watching, the deletions are held back with a warning and everything else carries on. Give `--allow-mass-delete` when you do mean it.
- **Case.** Bucket names are case-sensitive. On a file system that ignores case (macOS and Windows by default) two bucket files whose names differ only in case can't both be stored, so the second is skipped with a warning rather than written over the first, and a local file spelled differently from the bucket's is treated as the same file.
- `--dry-run` shows what a single pass would do; it can't be combined with `--watch`.

**Which server.** Inside a space the commands discover the space's server and credentials through the agent — nothing to configure, so a space startup script can pull its configuration with `knot file copy`. On the desktop they use the connection saved by `knot connect`, choosing the server with `--alias` (default `default`). An explicit `--server`/`--token` pair overrides both, as with other knot commands.

### Sync projects

A sync project is one or more syncs, each keeping a local directory and a bucket folder in step as `knot file sync` does, described in a TOML file and run together. Use one to keep a space's source code in a bucket, so a space can be deleted and a new one made with the code back as it was left:

```toml
name = "foo"                     # defaults to the file's name
exclude = ["node_modules/"]      # left out of every job
no_default_excludes = false      # true: every job syncs .git and editor scratch files too

[[sync]]
name     = "src"                 # defaults to the directory's name
local    = "~/src/foo"
remote   = "src:projects/foo/"
snapshot = "src:templates/go/"   # the folder starts as a snapshot of this
mode     = "two-way"             # two-way (default), download or upload
watch    = true                  # keep syncing changes (default)
delete   = true                  # pass deletions on (default)
exclude  = [".cache/"]
exclude_from = ".gitignore"      # more patterns, from a file in the directory
no_default_excludes = false      # true syncs .git and editor scratch files too
allow_mass_delete = false
```

Each `[[sync]]` table is a job: `local` is the directory (`~` is the home directory of whoever runs it), `remote` the bucket folder. A job is a `knot file sync` of the two: `two-way` as `--two-way`, `download` from the bucket folder and `upload` to it, with `watch` and `delete` on unless set `false`. `exclude` adds to the project's patterns. As with `sync`, watched and two-way jobs also leave out the [default exclusions](#what-is-left-out), version control folders such as `.git` and editor scratch files; `no_default_excludes = true`, for the whole project or one job, syncs everything the `exclude` patterns don't leave out, so a space's repository, history and branches included, comes back with it. `exclude_from` reads more patterns from a file in the directory, such as `.gitignore`, when the job starts, or from the bucket folder when the file has not come down yet; patterns starting `!`, which put files back, are skipped with a warning, and anchored ones (`/build`) match at any depth.

**Starting from a snapshot.** A job with `snapshot` makes its bucket folder a [snapshot](#working-with-files) of that folder when the bucket folder does not exist yet, so each new project starts as a copy of a starter, made on the server without transferring anything. When the folder exists it is synced as it is, so the starter is never copied over work. A folder still being made by a snapshot, by another space starting at the same moment, is waited for until its manifest is there; the manifest itself is never synced into the directory. Snapshots are of a folder, so a job with `snapshot` syncs a folder, not a whole bucket.

**Running a project.** On the desktop, or anywhere, `run` runs a project until Ctrl+C; jobs that don't watch run once, and it ends once they all have:

```shell
knot file sync-project run sync.toml
```

In a space, `start` hands a project to the space's agent, which runs it in the background, and again whenever the agent starts, until it is stopped. A project of the same name is replaced, unless it's running unchanged, when it's left running, so a startup script can start its project on every start; `--wait` returns once every job has made its first pass, so what follows finds the files there:

```shell
knot file sync-project start --wait ~/sync.toml
knot file sync-project list              # the projects running, the template's among them
knot file sync-project status [name]     # each job: state, passes, what it moved, its last error
knot file sync-project stop foo          # stop it and forget it; what it synced stays
```

Scripts in a space do the same with [`knot.files.sync`](../../knot-reference/libraries/files.md#knotfilessync), giving the project as a dict or as TOML.

**Stopping.** Before a space is stopped, restarted or deleted, the server has its agent send the local changes its projects have not sent yet, waiting up to 30 seconds, so an edit saved just before is kept. A project stopped with `stop`, or `run` interrupted with Ctrl+C, sends them too, for up to 5 seconds. If the space's agent or the server goes down, the changes stay where they were made and are sent when both are back; a space whose container is gone loses only what changed in it while its agent was down.

One job failing, its snapshot's source missing for example, leaves the rest running; a watching job that stops is started again, waiting longer each time up to a minute. A project syncing a directory another project syncs, or one inside it, is refused. The agent keeps the projects it was given in `~/.knot/sync-projects`, and syncs as the space's processes do, with the space owner's access.

**In a template.** A template's volumes can hold a `sync` block, a list of jobs as above, which every space made from it runs, on every platform, KVM included. [Template variables](../templates.md) are resolved in it, so each space can have a folder of its own:

```yaml
sync:
  - name: src
    local: ~/src
    remote: code:projects/${{ .space.name }}/
    snapshot: code:templates/go/
    exclude: [node_modules/]
```

The agent runs it as the project `template`, which runs for as long as the space does and cannot be stopped from inside it. A space deleted and made again with the same name finds its folder and gets its code back. Spaces made from a template whose spaces may not use file storage report the job as failed, saying why, in `knot file sync-project status`. The block is checked when the template is saved; values made from variables are checked when the space's agent starts.
