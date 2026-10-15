---
name: codex-loop
description: Run Codex review rounds on a plan or diff with a stopping rule (minimum 2, default cap 4). Use when work needs Codex QC before Jerry commits or before executing a plan, or when Jerry says "codex review", "QC this", "get Codex on it".
user_invocable: true
---

# Codex Review Loop

Policy source: memory `feedback_multi_round_qc`. Runtime:
`node ~/.claude/plugins/marketplaces/openai-codex/plugins/codex/scripts/codex-companion.mjs <review|adversarial-review|status|result> [args]`

## Pick the reviewer

- Uncommitted diff: `review --scope working-tree`. Committed branch: `review --base <base-ref>` (ignores the working tree).
- Security, infra or production path (hooks, settings, systemd units, ~/Services, host config): `adversarial-review` with one
  line of focus text naming the risk.
- Plans and documents (no diff): ad-hoc `codex exec ... --skip-git-repo-check </dev/null`, one concern per prompt.
- Launch with Bash `run_in_background: true`, wait for the completion notification, no polling. `result <job-id>` if several ran.
- Use the configured default model; switch only on a usage-limit error.

## Rounds

1. Round 1 always. Round 2 always on anything multi-file or if round 1 found blockers.
2. Plain `review` takes no focus text, so rounds 2+ on a diff use `adversarial-review [--scope working-tree|--base <ref>]`
   with the focus text: earlier findings marked fixed or declined-by-Jerry, an instruction to verify each claimed fix and
   re-report any that is incomplete, not to re-report declined ones, substantive defects only, no style, and an explicit
   APPROVED / NOT APPROVED at the end.
3. **Stop** once the mandatory rounds in step 1 are done and a round returns no critical, high or medium findings.
4. **Cap 4 rounds.** Past 4 without asking only for security/infra/production changes or job-sweep report audits. Anything
   else still finding issues at round 4: stop and show Jerry the remaining findings so he can choose another round or ship.
5. Rounds that only produce low-severity or style items mean stop, not continue.

## Between rounds

Show Jerry Codex's findings verbatim, then fix what he approves (a terse "proceed" = fix the critical/high/medium items).
Keep a running file in the scratchpad: round, finding, severity, fixed / declined + reason. Never write DONE until the last
change has an APPROVED round.

**At the cap:** fixes made after the final capped round get one verify-only pass (`adversarial-review` told to confirm
only those fixes, report nothing new, and end APPROVED / NOT APPROVED). It does not count toward the cap. Its APPROVED
satisfies the DONE gate. If it rejects a fix, do not write DONE: report the open item to Jerry and stop.
