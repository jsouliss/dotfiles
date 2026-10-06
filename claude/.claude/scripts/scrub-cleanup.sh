#!/usr/bin/env bash
# Sweep zero-byte stub files leaked by the Claude Code sandbox on WSL2
# (anthropics/claude-code#26722). Only deletes EMPTY regular files with
# exact stub names in the project root — never real content, never dirs.
d="${CLAUDE_PROJECT_DIR:-$PWD}"
/usr/bin/find "$d" -maxdepth 1 -type f -empty \( \
    -name '.env' -o -name '.env.*' \
    -o -name '.npmrc' -o -name '.yarnrc' -o -name '.yarnrc.yml' \
    -o -name 'package.json' -o -name 'package-lock.json' \
    -o -name 'yarn.lock' -o -name 'pnpm-lock.yaml' \
    -o -name 'bunfig.toml' -o -name '.gitmodules' \
    -o -name '.bashrc' -o -name '.bash_profile' -o -name '.profile' \
    -o -name '.zshrc' -o -name '.zprofile' \
    -o -name '.gitconfig' -o -name '.ripgreprc' -o -name '.mcp.json' \
    -o -name '.idea' -o -name '.github' -o -name 'scripts' \
    \) -delete 2>/dev/null
exit 0
