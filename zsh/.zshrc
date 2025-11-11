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
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="$PATH:/Users/jerrysolis/.local/bin"
export DYLD_LIBRARY_PATH=/opt/homebrew/lib:$DYLD_LIBRARY_PATH
export DISPLAY=:0

# ============================================
# COMPLETIONS
# ============================================
autoload -Uz compinit && compinit

# Docker CLI completions
fpath=(/Users/jerrysolis/.docker/completions $fpath)

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
# bat (better cat with syntax highlighting)
alias cat="bat"

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
alias find="fd"

# procs (better ps)
alias ps="procs"

# dust (better du)
alias du="dust"

# duf (better df)
alias df="duf"

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

# Syntax highlighting (must be near the end)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Auto-suggestions (must be at the end)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

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
