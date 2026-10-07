# Codex Review Habit + Cross-Session Messaging

## Codex plugin commands
`/codex:review`, `/codex:adversarial-review`, `/codex:transfer`, `/codex:status`, `/codex:result` and `/codex:cancel` carry `disable-model-invocation: true`, so the model cannot invoke them; Jerry types them. I reach the same runtime from Bash:
`node ~/.claude/plugins/marketplaces/openai-codex/plugins/codex/scripts/codex-companion.mjs <review|adversarial-review|status|result> [args]`
Reviews run synchronously inside that process, so launch them with Bash `run_in_background: true` and wait for the completion notification (no polling, no BashOutput in the launch turn). `status` is an on-demand check; `result [job-id]` prints a finished job's output (pass the id when more than one job ran).

- **Before Jerry commits any diff I produced**, run a companion `review --scope working-tree` for uncommitted changes, or `--base <base-ref>` only for changes already committed on a branch (`--base` ignores the working tree). Return Codex's findings verbatim and unfixed, then fix only what Jerry approves. Ad-hoc `codex exec` prompts remain the tool for plan and document reviews; the companion reviewer is for git diffs.
- **Security, infra or production-path changes** (hooks, settings, systemd units, anything under ~/Services) get `adversarial-review` with one line of focus text naming the risk, not plain `review`.
- **Handoff to Codex CLI**: when Jerry wants to continue a task in Codex, tell him to run `/codex:transfer` and keep the `codex resume <id>` line it prints.
- Keep the stop-time review gate off (`status` prints "Review gate: disabled").

## Cross-session messaging
- Run `ListAgents` first and use the exact listed name; a peer that is not listed is not reachable. The eva Discord service session (tmux `eva`) is listed with a suffix such as `eva-c5`.
- Use `SendMessage` (load it with ToolSearch `select:SendMessage`) when the work lives on another machine. First ask that peer to confirm its host and repo path, then give it the task and what to send back, and wait for its reply notification instead of polling.
- Do not message the eva session unless Jerry asks.
- Never put secrets, env values or file contents in a peer message; send a path instead.
