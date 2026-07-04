#!/usr/bin/env bash
set -euo pipefail

if [ -f package.json ]; then
  if command -v nvm >/dev/null 2>&1; then
    bash -i -c "nvm install --lts && nvm install-latest-npm"
    npm install
    npm run build
  else
    echo "Warning: nvm is not available, skipping npm setup"
  fi
fi

# Install dependencies for shfmt extension if curl is available
if command -v curl >/dev/null 2>&1; then
  curl -sS https://webi.sh/shfmt | sh &>/dev/null || echo "Warning: shfmt install failed"
else
  echo "Warning: curl is not installed, skipping shfmt install"
fi

# Configure ZSH plugins only if Oh My Zsh is installed
if [ -d "$HOME/.oh-my-zsh" ]; then
  mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" || true
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" || true
fi

mkdir -p "$HOME"
touch "$HOME/.zshrc"

if ! grep -q '^plugins=.*zsh-syntax-highlighting' "$HOME/.zshrc" 2>/dev/null; then
  if grep -q '^plugins=' "$HOME/.zshrc" 2>/dev/null; then
    sed -i -E 's/^(plugins=\()([^)]+)(\))/\1\2 zsh-syntax-highlighting\3/' "$HOME/.zshrc"
  else
    echo 'plugins=(git zsh-syntax-highlighting)' >>"$HOME/.zshrc"
  fi
fi

if ! grep -q '^plugins=.*zsh-autosuggestions' "$HOME/.zshrc" 2>/dev/null; then
  if grep -q '^plugins=' "$HOME/.zshrc" 2>/dev/null; then
    sed -i -E 's/^(plugins=\()([^)]+)(\))/\1\2 zsh-autosuggestions\3/' "$HOME/.zshrc"
  else
    echo 'plugins=(git zsh-autosuggestions)' >>"$HOME/.zshrc"
  fi
fi

# Avoid git log use less
if ! grep -q '^unset LESS' "$HOME/.zshrc" 2>/dev/null; then
  echo -e "\nunset LESS" >>"$HOME/.zshrc"
fi
