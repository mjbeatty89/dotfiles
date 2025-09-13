#!/bin/bash
# Chezmoi run_once script to install essential packages after OS migration

set -euo pipefail

echo "🚀 Installing essential packages..."

# Update package lists
sudo apt update

# Install essential development tools
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    neovim \
    tmux \
    zsh \
    build-essential \
    python3-pip \
    python3-dev \
    nodejs \
    npm \
    cargo \
    rustc \
    docker.io \
    docker-compose \
    flatpak \
    pipx

# Install chezmoi if not already installed
if ! command -v chezmoi &> /dev/null; then
    sh -c "$(curl -fsLS get.chezmoi.io)"
fi

# Restore from backup if available
BACKUP_DIR="$HOME/backup"
if [ -d "$BACKUP_DIR" ]; then
    echo "📦 Restoring packages from backup..."
    
    # Restore selected packages (filter out Pop!_OS specific ones)
    if [ -f "$BACKUP_DIR/installed-packages.txt" ]; then
        grep install$ "$BACKUP_DIR/installed-packages.txt" | \
        grep -v -E "(pop-|system76-|elementary-)" | \
        cut -f1 | \
        head -100 | \
        xargs sudo apt install -y --ignore-missing || true
    fi
    
    # Restore Flatpaks
    if [ -f "$BACKUP_DIR/flatpak-apps.txt" ]; then
        while read -r app; do
            [ -n "$app" ] && flatpak install -y flathub "$app" 2>/dev/null || true
        done < "$BACKUP_DIR/flatpak-apps.txt"
    fi
    
    # Restore Python packages
    if [ -f "$BACKUP_DIR/pip-requirements.txt" ]; then
        pip3 install -r "$BACKUP_DIR/pip-requirements.txt" || true
    fi
    
    # Restore pipx applications
    if [ -f "$BACKUP_DIR/pipx-apps.txt" ]; then
        echo "📋 Pipx applications to install manually:"
        cat "$BACKUP_DIR/pipx-apps.txt"
    fi
fi

echo "✅ Package installation complete!"