# Rules for local models

## Environment
- Repos by host:
  - DESKTOP-P2MLG2F (WSL2 Ubuntu 24.04): /mnt/c/Users/Jerry/Projects/ (DSA, WebstormProjects/genesis, LocalLLM, nerv)
  - Genesis (macOS): ~/Projects/
- Shell: zsh. Node 24, Python 3.12.
- Package managers: npm for JS, pip for Python. Do not switch tools.

## Workflow
- Plan first. State the files you will touch and why before editing.
- Make the smallest change that satisfies the request. Do not touch adjacent code, comments, or formatting.
- Match the surrounding style: quotes, indentation, type hints, naming.
- After editing, run the project's existing test or lint command if one exists. Report the result verbatim.
- If unsure, say so and stop. Do not guess CLI flags or API names.

## Prohibitions
- Never run rm -rf, git push --force, git reset --hard, or any command that deletes untracked work.
- Never read or modify ~/.ssh, ~/.claude, ~/.config/opencode, or any .env file.
- Never install packages globally or with sudo.
- Never commit. Leave changes staged for review.

## Output
- Short answers. No preamble, no summary of what you are about to do.
- Show a diff or the changed lines, not the whole file.
