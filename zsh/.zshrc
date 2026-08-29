fastfetch 

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
export TERM=xterm-256color

# ============================================
# POWERLEVEL10K INSTANT PROMPT
# ============================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================
# OH MY ZSH CONFIGURATION
# ============================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins - add wisely, as too many plugins slow down shell startup
plugins=(
  git
  colored-man-pages
  command-not-found
  sudo
)

source $ZSH/oh-my-zsh.sh

# ============================================
# PAGER CONFIGURATION
# ============================================
export PAGER="less"
export LESSCHARSET=utf-8
export LESS="-r -F -X -i"

# ============================================
# COMPLETIONS
# ============================================
# To activate completions for zsh you need to have
# bashcompinit enabled in zsh:

autoload -U bashcompinit
bashcompinit

# Afterwards you can enable completion for pipx:

eval "$(register-python-argcomplete pipx)"

autoload -Uz compinit && compinit

# Docker CLI completions
fpath=($HOME/.docker/completions $fpath)

# Exegol completions
eval "$(register-python-argcomplete --no-defaults exegol)"

# ============================================
# THEME & PROMPT
# ============================================
source ~/powerlevel10k/powerlevel10k.zsh-theme
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================
# MODERN CLI TOOLS
# ============================================

if command -v eza &> /dev/null; then 
  # eza (better ls with icons and git integration)
  alias ls="eza --icons --git"
  alias ll="eza --icons --git -lah"
  alias la="eza --icons --git -a"
  alias tree="eza --tree"
fi

if command -v zoxide &> /dev/null; then 
  # zoxide (better cd with frecency)
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v rg &> /dev/null; then 
  # ripgrep (better grep)
  alias grep="rg"
fi

if command -v procs &> /dev/null; then 
  # procs (better ps)
  alias ps="procs --tree"
fi

if command -v dust &> /dev/null; then 
  # dust (better du)
  alias du="dust"
fi

if command -v duf &> /dev/null; then 
  # duf (better df)
  alias df="duf"
fi

if command -v tldr &> /dev/null; then 
  # tldr (better man)
  alias man="tldr"
fi

# ============================================
# SHELL ENHANCEMENTS
# ============================================

# Disable autocomplete menus
setopt NO_AUTO_MENU
setopt MENU_COMPLETE
zstyle ':completion:*' menu select

# ============================================
# CUSTOM ALIASES
# ============================================
# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"

# Quick navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Utility aliases
alias reload="source ~/.zshrc"
alias zshconfig="nvim ~/.zshrc"
alias c="clear"
alias pn="pnpm"
alias pir='pi --tools read,grep,find,ls'

# ============================================
# CUSTOM FUNCTIONS
# ============================================
# HTB: open the SOCKS tunnel to kali, then drop into an interactive shell
htb() {
    if ! lsof -nP -iTCP:1080 -sTCP:LISTEN >/dev/null 2>&1; then
        ssh -fN -o ConnectTimeout=5 kali-socks || return 1
    fi
    ssh -o ClearAllForwardings=yes kali-socks
}

# Spotify queue automation helpers
spotify-queue-help() {
    echo "Spotify queue commands:"
    echo "  spotify-queue-once        Run one queue maintenance check."
    echo "  spotify-queue-auto-on     Enable automatic checks every five minutes."
    echo "  spotify-queue-auto-off    Disable automatic checks."
    echo "  spotify-queue-auto-status Show whether automatic checks are enabled."
    echo "  spotify-queue-help        Show this help message."
    echo ""
    echo "Each command also supports -h and --help."
}

spotify-queue-once() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        spotify-queue-help
        return 0
    fi
    if (( $# > 0 )); then
        echo "Unknown option: $1"
        echo "Run spotify-queue-help for usage."
        return 2
    fi

    (
        cd "$HOME/Projects/codex-spotify-queue-automation" || exit 1
        npm run queue
    )
}

spotify-queue-auto-on() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        spotify-queue-help
        return 0
    fi
    if (( $# > 0 )); then
        echo "Unknown option: $1"
        echo "Run spotify-queue-help for usage."
        return 2
    fi

    local launch_domain="gui/$(id -u)"
    local service_id="${launch_domain}/com.jsoulis.codex-spotify-queue"
    local plist_path="$HOME/Library/LaunchAgents/com.jsoulis.codex-spotify-queue.plist"

    if launchctl print "$service_id" >/dev/null 2>&1; then
        echo "Spotify queue automation is already ENABLED and runs every five minutes."
        return 0
    fi

    launchctl bootstrap "$launch_domain" "$plist_path" || return 1
    echo "Spotify queue automation is ENABLED and runs every five minutes."
}

spotify-queue-auto-off() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        spotify-queue-help
        return 0
    fi
    if (( $# > 0 )); then
        echo "Unknown option: $1"
        echo "Run spotify-queue-help for usage."
        return 2
    fi

    local launch_domain="gui/$(id -u)"
    local service_id="${launch_domain}/com.jsoulis.codex-spotify-queue"
    local plist_path="$HOME/Library/LaunchAgents/com.jsoulis.codex-spotify-queue.plist"

    if ! launchctl print "$service_id" >/dev/null 2>&1; then
        echo "Spotify queue automation is already DISABLED."
        return 0
    fi

    launchctl bootout "$launch_domain" "$plist_path" || return 1
    echo "Spotify queue automation is DISABLED."
}

spotify-queue-auto-status() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        spotify-queue-help
        return 0
    fi
    if (( $# > 0 )); then
        echo "Unknown option: $1"
        echo "Run spotify-queue-help for usage."
        return 2
    fi

    local service_id="gui/$(id -u)/com.jsoulis.codex-spotify-queue"

    if launchctl print "$service_id" >/dev/null 2>&1; then
        echo "Spotify queue automation is ENABLED and runs every five minutes."
    else
        echo "Spotify queue automation is DISABLED."
    fi
}

if command -v launchctl >/dev/null 2>&1 && launchctl print "gui/$(id -u)/com.jsoulis.codex-spotify-queue" >/dev/null 2>&1; then
    echo "Spotify queue automation is ENABLED and runs every five minutes."
fi

# ============================================
# ENVIRONMENT VARIABLES
# ============================================
# Preferred editor
export EDITOR='nvim'
export VISUAL='nvim'

# Language environment
export LANG=en_US.UTF-8

# Java
export JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Auto-suggestions (must be at the end)
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# MACOS
if [[ "$(uname)" == "Darwin" ]]; then 
    # ============================================
    # PATH EXPORTS
    # ============================================
    export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
    export PATH="$PATH:$HOME/.local/bin"
    export DYLD_LIBRARY_PATH=/opt/homebrew/lib:$DYLD_LIBRARY_PATH
    export DISPLAY=:0
    # Added by LM Studio CLI (lms)
    export PATH="$PATH:$HOME/.lmstudio/bin"
    # End of LM Studio CLI section

    # bun
    [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    # MacTeX (pdflatex, etc.)
    export PATH="/Library/TeX/texbin:$PATH"

    # ============================================
    # FZF (FUZZY FINDER)
    # ============================================
    # Uncomment after installing fzf: brew install fzf
    eval "$(fzf --zsh)"

    # Modern CLI Tools
    # gvm config 
    unalias cd 2>/dev/null
    # Disabled 2026-08-04: gvm env files pin Go 1.25.5, but Homebrew now ships 1.26.5,
    # so sourcing only emitted _encode/_decode errors and left GOROOT/GOPATH empty.
    # Go comes from Homebrew at /opt/homebrew/bin/go. To restore: gvm install go<ver>
    # [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

    # Custom Aliases
    # bat (better cat with syntax highlighting)
    if command -v bat &> /dev/null; then 
      alias cat="bat"
    fi

    if command -v fd &> /dev/null; then 
      # fd (better find)
      alias find="fd"
    fi

    if command -v brew &> /dev/null; then
      # updating brew packages alias
      alias update="brew update && brew upgrade && brew cleanup"
    fi

    if command -v grc &> /dev/null; then
      # generic colouriser
      [[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh
      for cmd in g++ gas head make ld ping6 tail traceroute6 $( ls /opt/homebrew/share/grc ); do
        cmd="${cmd##*conf.}"
        type "${cmd}" >/dev/null 2>&1 && alias "${cmd}"="$( which grc ) --colour=auto ${cmd}"
      done
    fi

    # Syntax highlighting (must be near the end)
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # Auto-suggestions (must be at the end)
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# LINUX
if [[ "$(uname)" == "Linux" ]]; then 
    # ============================================
    # PATH EXPORTS
    # ============================================
    export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
    export DOTNET_ROOT="$HOME/.dotnet"
    export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"
    export PATH="$HOME/.cargo/bin:$PATH"
    # Created by `pipx` on 2025-12-05 15:12:54
    export PATH="$PATH:$HOME/.local/bin"
    export PATH="$PATH:$HOME/.local/kitty.app/bin"
    export JAVA_HOME=/usr/lib/jvm/jdk-25.0.1+8
    export PATH=$PATH:$JAVA_HOME/bin

    # JetBrains ToolBox
    export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/apps/clion/bin"
    export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/apps/goland/bin"
    export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/apps/pycharm/bin" 
    export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/apps/rider/bin"
    export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/apps/rustrover/bin"
    export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/apps/webstorm/bin"
    export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/apps/intellij-idea-ultimate/bin"

    # mingw aliases
    alias disassemble="x86_64-w64-mingw32-objdump -rd"
    alias disassemble-hex="x86_64-w64-mingw32-objdump -s"
    alias coffparse-reloc="x86_64-w64-mingw32-objdump -r"
    alias coffparse-all="x86_64-w64-mingw32-objdump -x"
    alias piclink="x86_64-w64-mingw32-objcopy --dump-section .text=out.bin"

    # Custom Aliases
    # bat (better cat with syntax highlighting)
    if command -v batcat &> /dev/null; then 
      alias cat="batcat"
    fi

    if command -v fdfind &> /dev/null; then 
      # fd (better find)
      alias find="fdfind"
    fi

    if command -v grc &> /dev/null; then
      # generic colouriser
      [[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh
      for cmd in g++ gas head make ld ping6 tail traceroute6 $( ls /usr/share/grc/ ); do
        cmd="${cmd##*conf.}"
        type "${cmd}" >/dev/null 2>&1 && alias "${cmd}"="$( which grc ) --colour=auto ${cmd}"
      done
    fi

    alias update="sudo apt-get update -y"
    alias upgrade="sudo apt-get upgrade -y"
    alias clean="sudo apt-get clean -y"
    alias autoremove="sudo apt-get autoremove -y"

    # Havoc
    export QT_QPA_PLATFORM=xcb

    # source $HOME/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi

check_tools() {
  local tools=("eza" "zoxide" "rg" "procs" "dust" "duf" "tldr")
  for tool in "${tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
      echo "$tool is not installed"
    fi
  done

  # Linux specific tools
  if [[ "$(uname)" == "Linux" ]]; then 
    if ! command -v "batcat" &> /dev/null; then
      echo "batcat is not installed"
    fi
    if ! command -v "fdfind" &> /dev/null; then
      echo "fdfind is not installed"
    fi
  fi

  # MacOS specific tools
  if [[ "$(uname)" == "Darwin" ]]; then 
    if ! command -v "bat" &> /dev/null; then
      echo "bat is not installed"
    fi
    if ! command -v "fd" &> /dev/null; then
      echo "fd is not installed"
    fi
  fi

  echo "Tool check complete."
}
eval "$(register-python-argcomplete --no-defaults exegol)"

export PATH="$HOME/.npm-global/bin:$PATH"

test -e "$HOME/.shellfishrc" && source "$HOME/.shellfishrc"

# opencode
export PATH=$HOME/.opencode/bin:$PATH

export GSETTINGS_SCHEMA_DIR=/opt/homebrew/share/glib-2.0/schemas
export OLLAMA_HOST=${OLLAMA_HOST:-http://localhost:11434}

# ============================================
# ATUIN (shell history with sync)
# ============================================
[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Trixy — Claude with Discord channel
alias trixy="claude --channels plugin:discord@claude-plugins-official"
export CLAUDE_CODE_NO_FLICKER=1

# ============================================
# Codex
# ============================================
if command -v codex &> /dev/null; then
  eval "$(codex completion zsh)"
fi
alias cauto="codex --profile safe-auto"

# ============================================
# GitHub OAuth OAuth
# ============================================
export GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token 2>/dev/null)"

# ============================================
# DO Droplet
# ============================================
if [[ "$(uname)" == "Darwin" ]]; then
  export DIGITALOCEAN_API_TOKEN="$(security find-generic-password -a "$USER" -s DIGITALOCEAN_API_TOKEN -w 2>/dev/null)"
fi

export PLANNOTATOR_REMOTE=0
export PLANNOTATOR_PORT=19432

alias claude-mem='bun "/Users/jerrysolis/.claude/plugins/cache/thedotmack/claude-mem/12.3.9/scripts/worker-service.cjs"'

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# ============================================
# llama-server API key
# ============================================
if [[ "$OSTYPE" == darwin* ]]; then
  export LLAMACPP_API_KEY="$(security find-generic-password -a "$USER" -s LLAMACPP_API_KEY -w 2>/dev/null)"
else
  [ -r "$HOME/.config/secrets/env" ] && source "$HOME/.config/secrets/env"
fi
