# ============================================================================
# Machine-Specific Configuration: mmm4 (M4 Mac Mini)
# ============================================================================
# This file is automatically sourced by .zshrc when hostname matches "mmm4"
# ============================================================================

# External home directory on SSD
# Home is on /Volumes/mm2ssd/mjb instead of /Users/mjb
export EXTERNAL_HOME="/Volumes/mm2ssd/mjb"

# Ensure we're using the external home
if [[ "$HOME" != "$EXTERNAL_HOME" ]] && [[ -d "$EXTERNAL_HOME" ]]; then
    echo "Warning: HOME ($HOME) doesn't match expected external home ($EXTERNAL_HOME)"
fi

# ============================================================================
# Paths specific to this machine
# ============================================================================

# LM Studio models location (on external SSD)
export LMSTUDIO_HOME="/Volumes/mm2ssd/mjb/.lmstudio"

# Docker on external drive
export DOCKER_CONFIG="$HOME/.docker"

# Development directories
export DEV_DIR="/Volumes/mm2ssd/dev"

# ============================================================================
# Aliases specific to this machine
# ============================================================================

# Quick access to external drive root
alias ssd='cd /Volumes/mm2ssd'

# Open home in Finder
alias home='open $HOME'

# Development directory
alias dev='cd /Volumes/mm2ssd/dev'

# ============================================================================
# Services / Apps specific to this machine
# ============================================================================

# 1Password SSH Agent (if using 1Password for SSH keys)
if [[ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]]; then
    export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi

# ============================================================================
# Performance tuning for M4
# ============================================================================

# Node.js memory limit (M4 has plenty of RAM)
export NODE_OPTIONS="--max-old-space-size=8192"

# Python optimizations
export PYTHONDONTWRITEBYTECODE=1  # Don't write .pyc files

# ============================================================================
# Machine info function
# ============================================================================

mmm4-info() {
    echo "Machine: M4 Mac Mini (mmm4)"
    echo "Home: $HOME"
    echo "External SSD: /Volumes/mm2ssd"
    echo ""
    echo "Key Paths:"
    echo "  dotfiles:  $HOME/dotfiles"
    echo "  dotfiles2: $HOME/dotfiles2"
    echo "  dev:       /Volumes/mm2ssd/dev"
    echo ""
    echo "Storage:"
    df -h /Volumes/mm2ssd 2>/dev/null | tail -1
}
