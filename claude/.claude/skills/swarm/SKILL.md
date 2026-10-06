---
name: swarm
description: Multi-source research swarm. Use when the user wants thorough, verified research instead of a quick single-source answer — triggers include "swarm this", "swarm research", "deep research", "research X thoroughly", or any request that explicitly names multiple sources (web + firecrawl + context7 + GitHub + official docs). Fans out parallel agents across web search, firecrawl, context7, GitHub, and official documentation, then synthesizes with a sources table.
user_invocable: true
---

# Swarm — Multi-Source Research

The user invoked swarm because they want breadth and verification, not a single quick answer. Do not shortcut this. The point of the swarm is that one source can be wrong, stale, or shallow — multiple independent sources catch what a single search misses.

## Arguments

The skill receives a topic string. Optional flags inside the args:

- `--quick` — skip GitHub + official-docs fanout; run only web + firecrawl. Use when the topic is shallow or time-sensitive.
- `--no-github` / `--no-context7` / `--no-docs` — selectively drop a source.

If no topic is given, ask the user for one. If the topic has multiple distinct interpretations, ask ONE clarifying question before fanning out. Otherwise proceed.

## Step 1: Plan the fanout

Decide which sources are relevant. Don't force-fanout to a source that has nothing useful to add for this topic.

- **Web / news (almost always)** — firecrawl-search or WebSearch for recent coverage, opinions, blog posts, articles
- **Official docs** — when the topic names a library, framework, SDK, API, CLI, or vendor product. Use firecrawl-scrape against the official site.
- **context7** — when the topic is technical and names a library/framework with versioned docs. Use the `mcp__plugin_context7_context7__resolve-library-id` and `query-docs` tools.
- **GitHub** — when the topic is about a project, has known repos, or benefits from issues/source verification. Use `mcp__github__search_code`, `search_issues`, `search_repositories`.
- **Reference docs / specific URLs** — if the user mentioned specific URLs or vendor sites, scrape them directly.

State the plan in one short sentence to the user before launching ("Fanning out: web, context7, GitHub, and official docs for X.") so they can redirect if a source is wrong.

## Step 2: Launch parallel agents in ONE message

Fire all agents in a single message with multiple Agent tool calls so they run concurrently. Each agent gets:

- The topic + the specific scope it's responsible for (so they don't overlap)
- An instruction to return **findings with source URLs and dates**
- An instruction to **flag when sources are thin, contradictory, or stale**
- An instruction to **not fabricate** — if it can't find the answer, say so

Recommended agent assignments:

| Source | Agent type | Notes |
|---|---|---|
| Web / news | `research` | Refuses to answer with thin sources, returns an evidence packet |
| context7 | `general-purpose` | Tell it explicitly to use `mcp__plugin_context7_context7__*` tools |
| GitHub | `general-purpose` | Tell it to use `mcp__github__search_*` and `get_file_contents` |
| Official docs | `general-purpose` | Tell it to use firecrawl-scrape on specific vendor URLs |

If a source is small (e.g., just one URL to scrape), do it inline in a fork rather than spawning a subagent — overhead beats parallelism for trivial work.

## Step 3: Synthesize

When all agents return:

1. **Cross-check claims across sources.** Note any contradictions explicitly.
2. **Weight by recency and authority.** Official docs > GitHub source > recent blog posts > old StackOverflow.
3. **Write the synthesis with reasoning**, not just a list of findings. The user wants an answer, not a literature review.
4. **End with a Sources table.**

If sources disagree, present the disagreement. Don't paper over it. If a claim has only one source, mark it `[single source]` so the user knows the confidence floor.

## Step 4: Output format

```
## Answer
<synthesis, 3-8 paragraphs depending on topic depth>

## Confidence
<one short paragraph: what's well-supported across sources vs what's single-sourced or contradicted>

## Sources
| Source | URL | Contribution | Date |
|---|---|---|---|
| ... | ... | ... | ... |
```

## Rules

- **Don't fabricate.** If a source-agent returned thin, say so in the Confidence section. Do not fill the gap with plausible-sounding training data.
- **Match scope to question.** A version-compatibility lookup doesn't need a 6-source swarm; a "current state of X" question does. Use `--quick` for the former.
- **No em dashes** in the output (Jerry's global preference).
- **Verify before recommending action.** If the synthesis ends with "you should run X" or "the fix is Y", confirm X exists / Y is current before saying so.
- **Surface ambiguity, don't resolve it silently.** If sources point to genuinely different answers depending on context (version, OS, configuration), present the branches.
