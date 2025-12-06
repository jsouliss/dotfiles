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
# PATH EXPORTS
# ============================================
# export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
# export PATH="$PATH:/Users/jerrysolis/.local/bin"
# export DYLD_LIBRARY_PATH=/opt/homebrew/lib:$DYLD_LIBRARY_PATH
# export DISPLAY=:0
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"

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
fpath=(/Users/jerrysolis/.docker/completions $fpath)

# Exegol completions
# eval "$(register-python-argcomplete --no-defaults exegol)"

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
# bat (better cat with syntax highlighting)
# macos
# alias cat="bat"
# linux
alias cat="batcat"

# eza (better ls with icons and git integration)
alias ls="eza --icons --git"
alias ll="eza --icons --git -lah"
alias la="eza --icons --git -a"
alias tree="eza --tree"

# zoxide (better cd with frecency)
eval "$(zoxide init zsh)"
alias cd="z"

# ripgrep (better grep)
alias grep="rg"

# fd (better find)
alias find="fdfind"

# procs (better ps)
alias ps="procs --tree"

# dust (better du)
alias du="dust"

# duf (better df)
alias df="duf"

# tldr (better man)
alias man="tldr"

# ============================================
# FZF (FUZZY FINDER)
# ============================================
# Uncomment after installing fzf: brew install fzf
# eval "$(fzf --zsh)"

# ============================================
# SHELL ENHANCEMENTS
# ============================================
# Show system info on startup
fastfetch

# Disable autocomplete menus
setopt NO_AUTO_MENU
setopt MENU_COMPLETE
zstyle ':completion:*' menu select

# Syntax highlighting (must be near the end)
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source /home/dev/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Auto-suggestions (must be at the end)
# source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

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

# ============================================
# ENVIRONMENT VARIABLES
# ============================================
# Preferred editor
export EDITOR='nvim'
export VISUAL='nvim'

# Language environment
export LANG=en_US.UTF-8

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

[[ -s "/home/dev/.gvm/scripts/gvm" ]] && source "/home/dev/.gvm/scripts/gvm"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Created by `pipx` on 2025-12-05 15:12:54
export PATH="$PATH:/home/dev/.local/bin"
