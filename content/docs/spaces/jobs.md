---
title: Space Jobs
description: Run periodic or manually triggered jobs inside a space, stored on the space and pushed to its agent.
type: Guide
tags: [spaces, automation]
weight: 145
---

A space can define its own jobs — shell commands that run inside the space on a schedule, or only when triggered manually. Job definitions are stored on the space itself and pushed to the space's agent, which runs them as the space user with the space's normal environment. Because the definitions live on the space record (not on a file inside the container) they survive restarts even without permanent storage, and they can be read and edited while the space is stopped. Changes are pushed to a running agent immediately, with no restart needed.

Jobs only fire while the space is running. Occurrences that pass while the space is stopped are simply missed — there is no catch-up, the job waits for its next occurrence. Times are evaluated in the space's timezone, which comes from the user's profile.

---

## Defining Jobs

Each job has a name (unique within the space), a shell command, an optional schedule, and an enabled flag. Jobs are defined from the web UI, the CLI, or a scriptling — see [Running Jobs](#running-jobs) below. A template can also define jobs that are copied into each space created from it, giving every space its own editable copy (see [Managing Templates](../templates/managing/)).

A job with **no schedule is manual only** — it never fires automatically but can always be triggered on demand. A job with `enabled = false` is listed but never fires automatically; manual triggering works regardless.

### Schedule syntax

The schedule is a standard **5-field cron expression** (`minute hour day month weekday`). The usual syntax is supported: lists (`1,15`), ranges (`1-5`) and steps (`*/10`).

| Example            | Meaning                                    |
| ------------------ | ------------------------------------------ |
| `0 2 * * *`        | Daily at 02:00                             |
| `30 9 * * 1-5`     | Weekdays at 09:30                          |
| `*/5 * * * *`      | Every 5 minutes                            |
| `0 */2 * * *`      | Every 2 hours                              |

Invalid definitions are rejected on save with a per-job error, so a bad schedule can never reach the agent.

### The job runner

Scheduled firing is controlled by the job runner, a per-space switch that is stored alongside the jobs. Disabling it stops all scheduled firing while manual triggering keeps working; per-job `enabled = false` does the same for an individual job. The runner state is persisted, so a restart picks up where you left off.

## Running Jobs

### From the web UI

Spaces with jobs show a **clock icon** in the space row while running — green when the job runner is enabled, grey when it is stopped. Clicking it opens the jobs panel: each job shows its schedule, next and last run, and a **Run now** button, and a **Job Runner Enabled** toggle starts and stops scheduled firing. Job output appears in the space's logs, each line prefixed with the job name.

The space's action menu (⋯) has an **Edit Jobs** entry that opens the same panel. Jobs are added, changed and removed from there — each row has an enable toggle, an edit and a delete action, and **Add Job** opens a form with the schedule validation described above.

### From your machine (desktop client)

```shell
knot space jobs list my-space
knot space jobs add my-space backup --command "./scripts/backup.sh" --schedule "0 2 * * *"
knot space jobs update my-space backup --disable
knot space jobs remove my-space backup
knot space jobs run my-space backup
knot space jobs enable my-space     # the job runner
knot space jobs disable my-space
```

`list` prints the runner state (enabled or stopped) alongside the jobs, with next/last run when the space is running. Definitions can be edited while the space is stopped; a stopped agent picks the changes up when it next starts. These commands also work from inside a space, using the space's own credentials.

### Inside the space

The space's terminal can inspect and trigger jobs by talking to the agent directly:

```shell
knot jobs list
knot jobs run backup
```

### From a scriptling

The `knot.jobs` library manages jobs through the same API:

```python
import knot.apiclient
import knot.jobs

knot.apiclient.configure("https://knot.example.com", "your-token")

knot.jobs.add("my-space", "backup", command="./backup.sh", schedule="0 2 * * *")
knot.jobs.list("my-space")
knot.jobs.run("my-space", "backup")
knot.jobs.disable("my-space", "backup")
knot.jobs.enable_runner("my-space")
knot.jobs.remove("my-space", "backup")
```

## Behaviour notes

- **No catch-up**: occurrences that pass while the space is stopped (or the runner or job is disabled) are missed; the next occurrence fires as scheduled.
- **Overlap**: if a job is still running when its next occurrence is due, that occurrence is skipped and recorded as `skipped` in the job's history.
- **Output and logging**: each run logs the job name, its output lines, and the final status (with duration) to the space's standard logs.
- **Run history**: the agent keeps the last few runs per job in memory (status, duration, trigger); it is not persisted across space restarts.

{{< tip >}}
Combine jobs with [space schedules](../managing/) (start/stop between hours): a space that auto-starts each workday brings its agent — and therefore its scheduled jobs — up with it automatically.
{{< /tip >}}
