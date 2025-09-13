#!/bin/bash
# Setup development environments after OS migration

set -euo pipefail

echo "🔧 Setting up development environments..."

# Install nvm and Node.js
if [ ! -d "$HOME/.config/nvm" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    export NVM_DIR="$HOME/.config/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
fi

# Install global npm packages if backup exists
if [ -f "$HOME/backup/npm-global.txt" ]; then
    echo "Restoring npm global packages..."
    grep -E "^\w" "$HOME/backup/npm-global.txt" | \
    sed 's/@.*$//' | \
    while read -r package; do
        [ -n "$package" ] && npm install -g "$package" 2>/dev/null || true
    done
fi

# Setup Python development
echo "Setting up Python development tools..."
pip3 install --user virtualenv pipenv poetry

# Install Rust tools if cargo backup exists
if [ -f "$HOME/backup/cargo-packages.txt" ] && command -v cargo &> /dev/null; then
    echo "Restoring Rust packages..."
    grep -E "^[a-zA-Z]" "$HOME/backup/cargo-packages.txt" | \
    awk '{print $1}' | \
    while read -r package; do
        [ -n "$package" ] && cargo install "$package" 2>/dev/null || true
    done
fi

# Setup shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s $(which zsh)
fi

# Install oh-my-zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install powerlevel10k if not managed by chezmoi
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ] && [ ! -d "$HOME/powerlevel10k" ]; then
    echo "Installing powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        $HOME/.oh-my-zsh/custom/themes/powerlevel10k
fi

echo "✅ Development environment setup complete!"
echo "🔄 Please restart your terminal or run: exec zsh"