---
name: job-sweep
description: Run, resume, or check Jerry's daily job-sweep pipeline on nimbus (~/Services/job-sweep). Use when Jerry says "run the sweep", "job sweep", "did today's sweep run", "resume the sweep", or asks for new roles. nimbus only.
user_invocable: true
---

# Job Sweep

The sweep is a scripted pipeline, not an agent swarm. Never spawn discovery agents for it; agents are only for judgment calls
on single exceptions. Full stage table: `~/Services/job-sweep/README.md`. Background: memory `project_job_sweep_pipeline`.

## 1. Check before running

The timer runs daily at 07:00 Pacific, so today's run usually already exists.

1. `ls ~/Services/job-sweep/state/ | rg '^\d{4}-' | tail -3` and read `state/<today>/status.json`.
2. `journalctl --user -u job-sweep.service -n 50 --no-pager` if a stage failed.
3. Done and clean as a REAL run (`status.json` has `dry=false`, all stages succeeded): summarize from
   `state/<today>/report_summary.json` and stop. Do not re-run. A completed `dry=true` run is only a preview: if Jerry
   asked for a real sweep, run it.

## 2. Run or resume

Always from cwd `/home/jerry` (a cwd inside the repo drops sandbox placeholder files), in the background:

- Resume a failed run from its first failed stage:
  `cd ~/Services/job-sweep && python3 -m jobsweep.run --run <YYYY-MM-DD> --stages <stage>,<later stages...>`
- Preview without writing the sidecar, vault or Discord: add `--dry`.
- `bash run.sh` is gated inside Claude Code; use the `python3 -m jobsweep.run` form.
- Exit 3 = another run holds `state/.lock`. Exit 1 after two degraded days = discovery streak, not a crash.

## 3. Hard rules

- NEVER edit `config/rubric.md` while a run is scoring; every cached score is fingerprinted and gets discarded.
- About 80-95 unverified roles a day from 403-blocking hosts is the normal baseline, not an outage.
- After a real run, confirm the sidecar actually changed (backup `.bak-<run>` exists, counts in `sidecar_summary.json`).
- Report to Jerry links only: new roles scored 4+ (company, title, link, band) plus one closures line. Evidence stays in `state/`.
- No new-grad roles, DoD/federal screen is employer-scoped, no em dashes in anything published.

## 4. Then point Jerry at applying

End with the top 3 new 5/4 roles and one line asking which he's applying to today. The sweep is only useful if it turns into applications.
