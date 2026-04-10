#!/bin/bash
# ============================================================================
# External Home Directory Setup Script
# Matthew Beatty - mjbeatty89@gmail.com
# ============================================================================
#
# This script helps migrate a macOS home directory to an external drive.
# It should be run AFTER changing the home directory in System Settings.
#
# Usage:
#   ./setup-external-home.sh [old_home] [new_home]
#
# Example:
#   ./setup-external-home.sh /Users/mjb /Volumes/mm2ssd/mjb
#
# ============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Defaults
OLD_HOME="${1:-/Users/mjb}"
NEW_HOME="${2:-/Volumes/mm2ssd/mjb}"
DOTFILES_DIR="$NEW_HOME/dotfiles"
DOTFILES2_DIR="$NEW_HOME/dotfiles2"

echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}External Home Directory Setup${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""
echo -e "Old Home: ${YELLOW}$OLD_HOME${NC}"
echo -e "New Home: ${YELLOW}$NEW_HOME${NC}"
echo ""

# Verify new home exists
if [[ ! -d "$NEW_HOME" ]]; then
    echo -e "${RED}Error: New home directory does not exist: $NEW_HOME${NC}"
    exit 1
fi

# Verify we're running from new home
if [[ "$HOME" != "$NEW_HOME" ]]; then
    echo -e "${YELLOW}Warning: Current \$HOME ($HOME) doesn't match new home ($NEW_HOME)${NC}"
    echo -e "${YELLOW}Make sure you've updated System Settings and restarted.${NC}"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# ============================================================================
# Step 1: Migrate data from old home
# ============================================================================
echo -e "\n${BLUE}Step 1: Migrate data from old home${NC}"

if [[ -d "$OLD_HOME" ]]; then
    echo -e "Syncing data from $OLD_HOME to $NEW_HOME..."
    echo -e "${YELLOW}This may take a while for large directories.${NC}"
    
    rsync -avhE --progress \
        --exclude='.Trash/' \
        --exclude='Library/Caches/' \
        --exclude='Library/Logs/' \
        --exclude='Library/CloudStorage/' \
        --exclude='Library/Containers/' \
        --exclude='Library/Group Containers/' \
        --exclude='node_modules/' \
        --exclude='.cache/' \
        "$OLD_HOME/" "$NEW_HOME/" 2>&1 || {
            echo -e "${YELLOW}Warning: rsync completed with some errors (this is often normal)${NC}"
        }
    
    echo -e "${GREEN}✓ Data migration complete${NC}"
else
    echo -e "${YELLOW}Old home not found, skipping migration${NC}"
fi

# ============================================================================
# Step 2: Fix symlinks pointing to old paths
# ============================================================================
echo -e "\n${BLUE}Step 2: Fix broken symlinks${NC}"

cd "$NEW_HOME"

# Count broken symlinks
broken_count=$(find . -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null | wc -l | tr -d ' ')
echo -e "Found ${YELLOW}$broken_count${NC} broken symlinks"

# Fix symlinks pointing to mjb2/dotfiles2 (legacy path)
echo -e "Fixing symlinks pointing to legacy paths..."
find . -maxdepth 1 -type l -exec sh -c '
    target=$(readlink "$1")
    if echo "$target" | grep -q "mjb2/dotfiles2"; then
        linkname=$(basename "$1")
        newtarget="dotfiles2/$linkname"
        if [ -e "$newtarget" ] || [ -L "$newtarget" ]; then
            rm "$1"
            ln -s "$newtarget" "$1"
            echo "  FIXED: $1 -> $newtarget"
        fi
    fi
' _ {} \;

# Fix symlinks pointing to /Users/mjb
find . -maxdepth 1 -type l -exec sh -c '
    target=$(readlink "$1")
    if echo "$target" | grep -q "/Users/mjb"; then
        # Try to create equivalent path in new home
        newpath=$(echo "$target" | sed "s|/Users/mjb|.|")
        if [ -e "$newpath" ]; then
            rm "$1"
            ln -s "$newpath" "$1"
            echo "  FIXED: $1 -> $newpath"
        fi
    fi
' _ {} \;

echo -e "${GREEN}✓ Symlink repair complete${NC}"

# ============================================================================
# Step 3: Setup shell config symlinks
# ============================================================================
echo -e "\n${BLUE}Step 3: Setup shell config symlinks${NC}"

if [[ -d "$DOTFILES_DIR" ]]; then
    # Remove existing and create new symlinks
    rm -f "$NEW_HOME/.zshrc" "$NEW_HOME/.zprofile" "$NEW_HOME/.gitconfig"
    
    ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$NEW_HOME/.zshrc"
    echo -e "${GREEN}✓ .zshrc -> dotfiles/zsh/.zshrc${NC}"
    
    ln -sf "$DOTFILES_DIR/zsh/.zprofile" "$NEW_HOME/.zprofile"
    echo -e "${GREEN}✓ .zprofile -> dotfiles/zsh/.zprofile${NC}"
    
    ln -sf "$DOTFILES_DIR/git/.gitconfig" "$NEW_HOME/.gitconfig"
    echo -e "${GREEN}✓ .gitconfig -> dotfiles/git/.gitconfig${NC}"
    
    # Starship config
    mkdir -p "$NEW_HOME/.config"
    rm -f "$NEW_HOME/.config/starship.toml"
    ln -sf "$DOTFILES_DIR/starship/starship.toml" "$NEW_HOME/.config/starship.toml"
    echo -e "${GREEN}✓ .config/starship.toml -> dotfiles/starship/starship.toml${NC}"
else
    echo -e "${YELLOW}Warning: dotfiles directory not found at $DOTFILES_DIR${NC}"
fi

# ============================================================================
# Step 4: Verify
# ============================================================================
echo -e "\n${BLUE}Step 4: Verification${NC}"

# Check for remaining broken symlinks
remaining=$(find "$NEW_HOME" -maxdepth 2 -type l ! -exec test -e {} \; -print 2>/dev/null | wc -l | tr -d ' ')

if [[ "$remaining" -gt 0 ]]; then
    echo -e "${YELLOW}Warning: $remaining broken symlinks remain:${NC}"
    find "$NEW_HOME" -maxdepth 2 -type l ! -exec test -e {} \; -print 2>/dev/null | head -10
else
    echo -e "${GREEN}✓ No broken symlinks found${NC}"
fi

# Test shell config
if [[ -f "$NEW_HOME/.zshrc" ]]; then
    echo -e "${GREEN}✓ Shell config accessible${NC}"
fi

# Test git config
if [[ -f "$NEW_HOME/.gitconfig" ]]; then
    echo -e "${GREEN}✓ Git config accessible${NC}"
fi

# ============================================================================
# Done
# ============================================================================
echo -e "\n${BLUE}============================================================================${NC}"
echo -e "${GREEN}🚀 External home setup complete!${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Restart your shell or run: ${BLUE}source ~/.zshrc${NC}"
echo -e "  2. Verify git identity: ${BLUE}git config user.name${NC}"
echo -e "  3. Test SSH: ${BLUE}ssh -T git@github.com${NC}"
echo ""
echo -e "${YELLOW}If issues persist, see:${NC}"
echo -e "  ${BLUE}$DOTFILES_DIR/docs/HOME_MIGRATION.md${NC}"
