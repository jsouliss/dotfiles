#!/bin/bash

set -e # Exit on any errors

echo "[+] Starting Ubuntu installation"

# Core CLI tools
packages=(
  stow
  git
  curl
  wget
  unzip
  zsh
  tmux
  fastfetch
  ripgrep
  fd-find
  bat
  eza
  zoxide
  duf
  tldr
  procs
  dust
  fzf
  jq
  htop
  git-delta
)

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y "${packages[@]}"
sudo apt-get autoremove -y
sudo apt-get clean -y

# Neovim (apt version is too old for LazyVim)
echo "[+] Installing Neovim..."
curl -LO https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz
sudo tar -xzf nvim-linux-x86_64.tar.gz -C /opt/
rm nvim-linux-x86_64.tar.gz

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "[+] Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Powerlevel10k
if [ ! -d "$HOME/powerlevel10k" ]; then
  echo "[+] Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
fi

# TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "[+] Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# NVM
if [ ! -d "$HOME/.nvm" ]; then
  echo "[+] Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

echo "[+] Script completed"
echo "[!] Run: stow zsh p10k git nvim tmux fastfetch"
echo "[!] Then: source ~/.zshrc"
echo "[!] Then open tmux and press prefix + I to install plugins"
