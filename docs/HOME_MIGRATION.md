# macOS Home Directory Migration to External Drive

This document describes the process of migrating a macOS home directory from the internal drive (`/Users/mjb`) to an external SSD (`/Volumes/mm2ssd/mjb`).

## Overview

### Why External Home?
- More storage space on external SSD
- Portable home directory across machines
- Separate data from OS for easier backup/restore

### Directory Structure

```
/Volumes/mm2ssd/mjb/           # New $HOME
├── dotfiles/                  # Git repo - shell configs (zsh, git, starship)
├── dotfiles2/                 # Extended dotfiles (app configs, NOT a git repo)
├── Library/                   # macOS app data, preferences, keychains
├── Documents/, Desktop/, etc. # Standard user folders
└── .zshrc -> dotfiles/zsh/.zshrc  # Symlinks to dotfiles
```

### Symlink Strategy

**Top-level dotfiles** → symlink to `dotfiles/` (git-managed):
- `.zshrc` → `dotfiles/zsh/.zshrc`
- `.zprofile` → `dotfiles/zsh/.zprofile`
- `.gitconfig` → `dotfiles/git/.gitconfig`
- `.config/starship.toml` → `dotfiles/starship/starship.toml`

**App-specific configs** → symlink to `dotfiles2/` (not git-managed):
- `.claude` → `dotfiles2/.claude`
- `.ssh` → `dotfiles2/.ssh`
- `.docker` → `dotfiles2/.docker`
- (many others)

## Migration Steps

### 1. Preparation

```bash
# Verify external drive is mounted
ls /Volumes/mm2ssd

# Check current home
echo $HOME
```

### 2. Change macOS Home Directory

**Via System Settings (Recommended):**
1. System Settings → Users & Groups
2. Right-click your user → Advanced Options
3. Change "Home directory" to `/Volumes/mm2ssd/mjb`
4. Restart

**Via Command Line:**
```bash
sudo dscl . -change /Users/mjb NFSHomeDirectory /Users/mjb /Volumes/mm2ssd/mjb
```

### 3. Migrate Data from Old Home

```bash
# Sync with rsync (excludes caches and cloud storage)
rsync -avhE --progress \
  --exclude='.Trash/' \
  --exclude='Library/Caches/' \
  --exclude='Library/Logs/' \
  --exclude='Library/CloudStorage/' \
  --exclude='Library/Containers/' \
  --exclude='Library/Group Containers/' \
  --exclude='node_modules/' \
  --exclude='.cache/' \
  /Users/mjb/ /Volumes/mm2ssd/mjb/
```

### 4. Fix Broken Symlinks

After migration, symlinks may point to old paths. Use this script to fix them:

```bash
# Fix symlinks pointing to old home variants
cd /Volumes/mm2ssd/mjb

# Find and display broken symlinks
find . -maxdepth 1 -type l ! -exec test -e {} \; -print

# Fix symlinks pointing to mjb2/dotfiles2 (if applicable)
find . -maxdepth 1 -type l -exec sh -c '
  target=$(readlink "$1")
  if echo "$target" | grep -q "mjb2/dotfiles2"; then
    linkname=$(basename "$1")
    newtarget="dotfiles2/$linkname"
    if [ -e "$newtarget" ]; then
      rm "$1"
      ln -s "$newtarget" "$1"
      echo "FIXED: $1 -> $newtarget"
    fi
  fi
' _ {} \;
```

### 5. Verify Shell Configs

```bash
# Test that configs load correctly
cat ~/.zshrc | head -5
cat ~/.gitconfig | head -5

# Verify no broken symlinks remain
find ~ -maxdepth 2 -type l ! -exec test -e {} \; -print
```

## What Gets Excluded

These are excluded from migration because they regenerate or sync from cloud:

| Excluded Path | Reason |
|--------------|--------|
| `Library/Caches/` | Regenerates automatically |
| `Library/Logs/` | Not needed, regenerates |
| `Library/CloudStorage/` | Synced by cloud services |
| `Library/Containers/` | App sandboxes, regenerate |
| `Library/Group Containers/` | Shared app data, regenerates |
| `node_modules/` | Reinstall with npm/yarn |
| `.cache/` | Various app caches |
| `.Trash/` | Not needed |

## What Gets Migrated

| Path | Contains |
|------|----------|
| `Library/Application Support/` | App preferences and data |
| `Library/Preferences/` | plist files |
| `Library/Keychains/` | Passwords and certificates |
| `Library/Services/` | Quick Actions |
| `Documents/`, `Desktop/`, etc. | User files |
| `dotfiles/` | Shell configuration (git repo) |
| `.ssh/`, `.gnupg/` | Keys and security |
| `.warp/`, `.claude/`, etc. | App-specific configs |

## Troubleshooting

### 1Password SSH Agent Not Working

The 1Password agent socket has a dynamic name. Check and update:

```bash
# Find the actual socket
ls -la ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/

# Update symlink if needed (socket name varies)
ln -sf "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ~/.1password/agent.sock
```

### Git Not Finding Config

```bash
# Verify symlink
ls -la ~/.gitconfig

# Should point to dotfiles
# .gitconfig -> dotfiles/git/.gitconfig
```

### Homebrew Path Issues

Ensure `/opt/homebrew/bin` is in PATH. Check `.zprofile`:

```bash
cat ~/.zprofile
# Should contain: eval "$(/opt/homebrew/bin/brew shellenv)"
```

## Ansible Integration (Future)

This migration can be automated with Ansible. Key tasks:

1. Create external home directory structure
2. Rsync data with exclusions
3. Fix symlinks programmatically
4. Update macOS user home path
5. Verify shell loads correctly

See `ansible/roles/macos-home/` (when implemented).

## Related Files

- `scripts/setup-external-home.sh` - Automated setup script
- `zsh/machines/mmm4.zsh` - M4 Mac Mini specific config

---

*Last updated: April 2026*
*Migration performed: /Users/mjb → /Volumes/mm2ssd/mjb*
