# ============================================================================
# Machine-Specific Configuration: Linux Desktop (stub)
# ============================================================================

# Use all cores for builds
export MAKEFLAGS="-j$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN || echo 4)"

# Package manager helpers (if needed)
# alias update='sudo apt update && sudo apt upgrade -y'    # Debian/Ubuntu
# alias update='sudo dnf update -y'                        # Fedora/RHEL
# alias update='sudo pacman -Syu'                          # Arch

# Paths
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# GPU or vendor-specific items can go here
# export NVIDIA_VISIBLE_DEVICES=all

# Add any Linux-only aliases or functions below
# alias lsblk='lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL'

echo "🐧 Linux desktop config loaded"
