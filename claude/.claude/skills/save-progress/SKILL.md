---
name: save-progress
description: Save current session's key findings, decisions, and open issues to a structured
session log
user_invocable: true
---

# Save Session Progress

Review the current conversation and identify:

1. **Key Findings** — discoveries, root causes identified, things learned
2. **Decisions Made** — architectural choices, approach selections, trade-offs resolved
3. **Open Issues** — unresolved problems, things to revisit, blockers

Then append an entry to `~/.claude/session-log.md` using this format:

```markdown
---
## [DATE] [TIME] — [Brief Title]
**Tags:** #tag1 #tag2

### Findings
- finding 1
- finding 2

### Decisions
- decision 1

### Open Issues
- [ ] issue 1
```

Guidelines:
- Use America/Los_Angeles timezone for timestamps
- Tags should be lowercase, kebab-case (e.g., #discord-mcp, #hooks, #dsa, #dotfiles)
- Keep entries concise — 1-2 lines per bullet
- Skip any section that has no entries (don't include empty headers)
- If the session log file doesn't exist, create it with a `# Session Log` header