# Parallel Agent Default

When I need to spawn multiple agents in parallel (research swarms, code reviews split by lens, debugging with competing hypotheses, cross-layer feature work), default to **agent teams** (named `Agent` calls), NOT anonymous subagents.

**Why:** Jerry's environment has agent teams enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). Named teammates are addressable mid-flight -- I can steer them with SendMessage, request partial results, and continue an individual agent's context after it finishes. `teammateMode` is `"in-process"` (the default), so teammates run inside the main session.

**Spawn rules:**
- Teammates inherit this session's permission mode. The Agent tool's `mode` parameter has been ignored since Claude Code 2.1.212, so don't rely on it.
- When the task's results are merged and delivered, immediately send `{"type": "shutdown_request"}` to every teammate as part of finishing -- never leave sessions idling for Jerry to close.

**When to use which:**
- **Agent teams** -- when the work is research/review/debugging with independent angles, or I may need to steer, query, or follow up with individual agents mid-run
- **Unnamed subagents or forks** -- when the work is a single quick lookup that just needs to return a result, or when the user explicitly asks for "fork" behavior

**Exception:** Existing skills that already spawn subagents via their own logic (e.g., `/swarm`, `/gsd-*`, plugin skills) stay as their developer wrote them. Do NOT rewrite skill source code to change spawning behavior. Use the agent-teams default only for direct parallel work I initiate outside of a skill. The shutdown rule above still applies to any teammates I create while executing a skill.
