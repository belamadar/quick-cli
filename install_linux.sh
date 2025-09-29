#!/bin/sh
set -e
printf ">>> Running Linux install script...\n"

msg() {
  printf "%s>>> %s%s\n" "$GREEN" "$1" "$NC"
}

# Colors
GREEN="\033[0;32m"
NC="\033[0m"

msg "Checking for Homebrew..."
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
	eval "$('/home/linuxbrew/.linuxbrew/bin/brew' shellenv)"
else
	msg "Homebrew not found. Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
		eval "$('/home/linuxbrew/.linuxbrew/bin/brew' shellenv)"
	else
		echo "Homebrew installation failed. Exiting."
		exit 1
	fi
fi

if command -v zsh >/dev/null 2>&1; then
  msg "Z Shell is available"
else
  msg "Installing Z Shell..."
  brew install zsh
fi

msg "Installing terminal tools..."
brew install \
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
	echo "Nerd Font already installed, skipping."
fi

msg "Setting up zsh config..."
if [ -f ~/.zshrc ]; then
	cp ~/.zshrc ~/.zshrc.backup.$(date +%s)
	msg "Backed up existing .zshrc"
fi

cat > ~/.zshrc <<'EOF'
## ---- Quick CLI - zsh preset ----

# Homebrew path
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
	eval "$('/home/linuxbrew/.linuxbrew/bin/brew' shellenv)"
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

# Aliases
alias ls="eza --icons --group-directories-first"
alias cat="bat"
alias vi="nvim"

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

EOF

msg "Applying Starship preset..."
starship preset nerd-font-symbols -o ~/.config/starship.toml

msg "Done! Restart your terminal to enjoy zsh + starship."
