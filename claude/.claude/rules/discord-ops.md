---
paths:
  - "Services/eva/**"
---

# Discord Plugin Operator Notes

Loads when a session rooted at `~` reads eva files (debugging eva). The eva service session itself does not match this glob, by design.

- The Discord MCP plugin requires the Discord gateway session to not be rate-limited. If the bot won't come online, check for gateway rate limiting first. The .env file may appear missing but actually be sandbox-blocked (shown as character device). Do not assume .env is missing without checking `ls -la`.
- Discord channels require launching with `claude --channels plugin:discord@claude-plugins-official`. The channels subsystem is also gated by the `tengu_harbor` GrowthBook flag.
