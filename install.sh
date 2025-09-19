#!/usr/bin/env bash
set -e

# Colors
GREEN="\033[0;32m"
NC="\033[0m"

msg() {
  echo -e "${GREEN}>>> $1${NC}"
}

msg "Checking for Homebrew..."
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

msg "Installing terminal tools..."
brew install \
  zsh \
  zsh-autosuggestions zsh-syntax-highlighting zsh-completions \
  zoxide \
  starship \
  bat \
  eza \
  fzf \
  ripgrep \
  neovim \
  tealdeer \
  fastfetch

msg "Installing Nerd Font..."
if [ ! -f ~/.local/share/fonts/CaskaydiaCoveNerdFont-Regular.ttf ]; then
  brew install --cask font-caskaydia-cove-nerd-font
else
  echo ">>> Nerd Font already installed, skipping."
fi

msg "Setting up zsh config..."

# Backup existing zshrc if present
if [ -f ~/.zshrc ]; then
  cp ~/.zshrc ~/.zshrc.backup.$(date +%s)
  msg "Backed up existing .zshrc"
fi

cat > ~/.zshrc <<'EOF'
## ---- Quick CLI - zsh preset ----

# Homebrew path
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

# Aliases
alias ls="eza --icons --group-directories-first"
alias cat="bat"
alias vim="nvim"

# Plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fpath+=("$(brew --prefix)/share/zsh-completions")
autoload -Uz compinit && compinit

# Tools
eval "$(zoxide init zsh --cmd cd)"
eval "$(fzf --zsh)"

# Prompt
eval "$(starship init zsh)"

# MOTD
if [ -f ~/.config/quick-cli/motd ]; then
  cat ~/.config/quick-cli/motd
fi
EOF

# Create MOTD file
mkdir -p ~/.config/quick-cli
/bin/cat > ~/.config/quick-cli/motd <<'EOM'

  󱍢 Welcome to Quick CLI

   $(fastfetch --structure User:Host:Shell:OS)

    Command                          │ Description
  ────────────────────────────────────┼───────────────────────────────────────────────
    brew help                         │ Manage command line packages
    tldr <cmd>                        │ Show simplified man pages
    zoxide query <dir>                │ Jump quickly to a directory
    fzf                               │ Fuzzy-find files or history
    vi                                │ Open the modern neovim text editor

EOM

msg "Applying Starship preset..."
starship preset gruvbox-rainbow -o ~/.config/starship.toml

msg "Done! Restart your terminal to enjoy zsh + starship."
echo "To make zsh your default shell, run: chsh -s $(which zsh)"

