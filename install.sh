
autoload -Uz compinit && compinit

# Main install dispatcher
set -e
OS="$(uname)"
if [ "$OS" = "Darwin" ]; then
  ./install_mac.sh
elif [ "$OS" = "Linux" ]; then
  ./install_linux.sh
else
  echo "Unsupported OS: $OS"
  exit 1
fi

