# Dotfiles Fixes

Pending improvements to apply manually.

---

## 1. `zsh/.zshrc` — Remove duplicate lines

Delete these duplicate lines (they run twice, slowing startup):

- **Line 313**: `autoload -U compinit && compinit` — duplicate of line 50
- **Line 314**: `eval "$(register-python-argcomplete --no-defaults exegol)"` — duplicate of line 56

---

## 2. `zsh/.zshrc` — Remove wrong-username PATH line

Delete **line 318**:
```zsh
export PATH=/home/dev/.opencode/bin:$PATH
```
The correct version already exists on line 327: `export PATH=$HOME/.opencode/bin:$PATH`

---

## 3. `zsh/.zshrc` — Remove/fix hardcoded `exegol` alias

Delete **line 315** (outside any platform block, wrong username):
```zsh
alias exegol='sudo -E /home/dev/.local/bin/exegol'
```
Move it inside the Linux block and use `$HOME`:
```zsh
alias exegol="sudo -E $HOME/.local/bin/exegol"
```

---

## 4. `zsh/.zshrc` — Move LM Studio PATH inside Darwin block

Move **line 331** inside the `if [[ "$(uname)" == "Darwin" ]]` block and use `$HOME`:
```zsh
# Before (hardcoded, outside Darwin block):
export PATH="$PATH:/Users/jerrysolis/.lmstudio/bin"

# After (inside Darwin block):
export PATH="$PATH:$HOME/.lmstudio/bin"
```

---

## 5. `zsh/.zshrc` — Move bun completions inside Darwin block

Move **lines 335-340** inside the `if [[ "$(uname)" == "Darwin" ]]` block and use `$HOME`:
```zsh
# Before:
[ -s "/Users/jerrysolis/.bun/_bun" ] && source "/Users/jerrysolis/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# After (inside Darwin block, use $HOME):
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
```

---

## 6. `zsh/.zshrc` — Fix claude-mem alias

Update **line 342** to use `$HOME` instead of hardcoded path:
```zsh
# Before:
alias claude-mem='/Users/jerrysolis/.bun/bin/bun "/Users/jerrysolis/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

# After:
alias claude-mem="$HOME/.bun/bin/bun \"$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs\""
```

---

## 7. `zsh/.zshrc` — Lazy-load NVM (startup speed)

Replace **lines 159-161** (eager NVM load, ~500ms penalty):
```zsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

With lazy stubs:
```zsh
export NVM_DIR="$HOME/.nvm"
nvm()  { unfunction nvm;  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"; nvm "$@"; }
node() { unfunction node; [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"; node "$@"; }
npm()  { unfunction npm;  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"; npm "$@"; }
```

---

## 8. `~/.claude/settings.json` — Disable co-authorship

Add to `~/.claude/settings.json` (already gitignored, safe to create if missing):
```json
{
  "includeCoAuthoredBy": false
}
```

---

## 9. Git — Commit staged deletions

The following are staged for deletion and should be committed:
- `borders/`
- `sketchybar/`
- `wezterm/`
- `openclaw/workspace/` and `openclaw/completions/`
- `opencode/.config/opencode/skills/`

```sh
git add -A
git commit -m "chore: remove unused packages (sketchybar, borders, wezterm, openclaw workspace, opencode skills)"
```

---

## 10. (Optional) Add missing packages

| Package | What to add |
|---------|-------------|
| `ssh/` | `~/.ssh/config` — host aliases, identity files, jump hosts |
| `tmux/` | Verify it exists and is stowed |
| `fastfetch/` | Verify it exists and is stowed |
