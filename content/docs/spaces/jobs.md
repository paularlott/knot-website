---
title: Space Jobs
description: Run periodic or manually triggered jobs inside a space, defined in ~/.knot-jobs.toml.
type: Guide
tags: [spaces, automation]
weight: 145
---

A space can define its own jobs — shell commands that run inside the space on a schedule, or only when triggered manually. Jobs are defined in `~/.knot-jobs.toml` in the space's home directory and are executed by the space's agent, so they run as the space user with the space's normal environment. The agent reloads the file on every run, so edits (including creating or deleting the file) are picked up without restarting anything.

Jobs only run while the space is running. Occurrences that pass while the space is stopped are simply missed — there is no catch-up, the job waits for its next occurrence. Times are evaluated in the space's timezone, which comes from the user's profile.

---

## Defining Jobs

Create `~/.knot-jobs.toml` in the space (a template's startup script can install it automatically). Each job is a `[jobs.<name>]` table:

```toml
# Daily at 02:00
[jobs.backup]
command = "./scripts/backup.sh"
hour = 2
minute = 0

# Weekday mornings at 09:30, disabled by default
[jobs.nightly-build]
command = "make nightly"
hour = 9
minute = 30
weekday = "1-5"
enabled = false

# Every 5 minutes
[jobs.pulse]
command = "./healthcheck.sh"
minute = "*/5"

# Weekday mornings at 09:30, as a raw cron expression
[jobs.build]
command = "make nightly"
schedule = "30 9 * * 1-5"

# Manual only — no schedule, appears in the UI and CLI for on-demand runs
[jobs.cleanup]
command = "./clean.sh"
```

### Schedule syntax

A schedule can be written two ways — **named cron fields** or a **raw cron expression** — but never both in the same job:

- Named fields: `minute`, `hour`, `day` (of month), `month`, `weekday`. Any field you omit defaults to `*`. Values may be ints (`minute = 5`) or strings (`minute = "*/5"`), and support the usual cron syntax: lists (`1,15`), ranges (`1-5`) and steps (`*/10`).
- Raw expression: a single `schedule` key holding a standard 5-field cron string (`minute hour day month weekday`), e.g. `schedule = "30 9 * * 1-5"` for 09:30 on weekdays or `schedule = "0 2 * * *"` for daily at 02:00.

Both forms accept the same per-field syntax and are equivalent — `hour = 2, minute = 0` and `schedule = "0 2 * * *"` produce the same schedule. Job lists show the normalized 5-field expression either way.

A job with **no schedule at all is manual only** — it never fires automatically but can always be triggered on demand.

Jobs with an invalid definition are listed with their error but never run; a broken file never stops the other jobs (the agent keeps the last good configuration and reports the parse error).

### The job runner

Scheduled firing is controlled by the job runner. When the agent starts it defaults to **running** if `~/.knot-jobs.toml` exists and **stopped** if it does not — so adding the file to an already-running space leaves the runner stopped until you enable it:

```shell
knot jobs enable    # inside the space
knot space jobs enable my-space    # from your machine
```

The runner state lives in the agent's memory only: it is never persisted, and the next space restart goes back to the default (running if the file is there, stopped if not). Deleting `~/.knot-jobs.toml` stops the runner on the next reload; recreating it leaves the runner stopped until enabled again. `knot jobs disable` stops scheduled firing the same way; manual triggering keeps working, and per-job `enabled = false` in the file still prevents an individual job from firing automatically.

## Running Jobs

### From the web UI

Spaces with a jobs file show a **clock icon** in the space row while running — green when the job runner is enabled, grey when it is stopped. Clicking it opens the jobs panel: a **Job Runner Enabled** toggle starts and stops scheduled firing, and each job shows its schedule, next and last run, and a **Run now** button. Job output appears in the space's logs, each line prefixed with the job name.

### From your machine (desktop client)

```shell
knot space jobs list my-space
knot space jobs run my-space backup
knot space jobs enable my-space
knot space jobs disable my-space
```

`list` prints the runner state (enabled or stopped) alongside the jobs.

### Inside the space

The same commands work in the space's terminal, talking to the agent directly:

```shell
knot jobs list
knot jobs run backup
knot jobs enable
knot jobs disable
```

## Behaviour notes

- **No catch-up**: occurrences that pass while the space is stopped (or the runner or job is disabled) are missed; the next occurrence fires as scheduled.
- **Overlap**: if a job is still running when its next occurrence is due, that occurrence is skipped and recorded as `skipped` in the job's history.
- **Output and logging**: each run logs the job name, its output lines, and the final status (with duration) to the space's standard logs.
- **Run history**: the agent keeps the last few runs per job in memory (status, duration, trigger); it is not persisted across space restarts.

{{< tip >}}
Combine jobs with [space schedules](../managing/) (start/stop between hours): a space that auto-starts each workday brings its agent — and therefore its scheduled jobs — up with it automatically.
{{< /tip >}}
