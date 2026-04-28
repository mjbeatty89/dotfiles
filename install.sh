#!/bin/bash
# ============================================================================
# Dotfiles Installer
# Matthew Beatty - mjbeatty89@gmail.com
# ============================================================================

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}Dotfiles Installer${NC}"
echo -e "${BLUE}============================================================================${NC}\n"

# Backup existing files
backup_if_exists() {
    if [ -f "$1" ] || [ -L "$1" ]; then
        local backup_name="$1.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}⚠️  Backing up existing $1 to $backup_name${NC}"
        mv "$1" "$backup_name"
    fi
}

# Create symlinks
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ ! -f "$source" ]; then
        echo -e "${RED}✗ Source file not found: $source${NC}"
        return 1
    fi
    
    backup_if_exists "$target"
    ln -sf "$source" "$target"
    echo -e "${GREEN}✓ Linked $target -> $source${NC}"
}

echo -e "${BLUE}Installing dotfiles...${NC}\n"

# ZSH
echo -e "${BLUE}Setting up ZSH...${NC}"
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"

# Git
echo -e "\n${BLUE}Setting up Git...${NC}"
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# Starship
echo -e "\n${BLUE}Setting up Starship...${NC}"
mkdir -p "$HOME/.config"
create_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# Machine-specific config
HOSTNAME=$(hostname -s)
MACHINE_CONFIG="$DOTFILES_DIR/zsh/machines/${HOSTNAME}.zsh"

echo -e "\n${BLUE}Checking for machine-specific config...${NC}"
if [ -f "$MACHINE_CONFIG" ]; then
    echo -e "${GREEN}✓ Found machine config for: ${HOSTNAME}${NC}"
    echo -e "${YELLOW}Note: Machine-specific config will be sourced automatically${NC}"
else
    echo -e "${YELLOW}⚠️  No machine-specific config found for: ${HOSTNAME}${NC}"
    echo -e "${YELLOW}   You can create one at: $MACHINE_CONFIG${NC}"
fi

# Check for 1Password env file
echo -e "\n${BLUE}Checking for 1Password env file...${NC}"
if [ ! -f "$HOME/.env.ai" ]; then
    echo -e "${YELLOW}⚠️  No ~/.env.ai file found${NC}"
    echo -e "${YELLOW}   Create it via 1Password Environments (or manually) for withai aliases${NC}"
    echo -e "${YELLOW}   Recommended permissions: chmod 600 ~/.env.ai${NC}"
else
    echo -e "${GREEN}✓ ~/.env.ai exists${NC}"
fi

echo -e "\n${BLUE}============================================================================${NC}"
echo -e "${GREEN}🚀 Dotfiles installed successfully!${NC}"
echo -e "${BLUE}============================================================================${NC}\n"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Restart your shell or run: ${BLUE}source ~/.zshrc${NC}"
echo -e "  2. Ensure ${BLUE}~/.env.ai${NC} is available for withai aliases"
echo -e "  3. Create machine-specific config if needed\n"
