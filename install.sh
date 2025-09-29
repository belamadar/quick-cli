#!/bin/sh
set -e

OS="$(uname -s)"
BASE_URL="https://raw.githubusercontent.com/belamadar/quick-cli/main"

if [ "$OS" = "Darwin" ]; then
  curl -fsSL "$BASE_URL/install_mac.sh" | bash
elif [ "$OS" = "Linux" ]; then
  curl -fsSL "$BASE_URL/install_linux.sh" | bash
else
  echo "Unsupported OS: $OS"
  exit 1
fi

