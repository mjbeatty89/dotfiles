# Matthew's Dotfiles

Personal dotfiles for ZSH, Git, Starship, and various development tools.

**Multi-OS Support:** macOS, Linux, and Windows (WSL)

## 🖥️ Systems
- **Primary:** M4 Mac Mini (mmm4) - macOS, external home on SSD
- Linux Desktop
- Windows Laptop (WSL)
- Various servers and Raspberry Pis

> **Note:** The M4 Mac Mini uses an external SSD for the home directory.
> See [docs/HOME_MIGRATION.md](docs/HOME_MIGRATION.md) for details.

## 🚀 Quick Start

### First Time Setup

```bash
git clone https://github.com/mjbeatty89/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

### After Installation

1. Restart your shell or run: `source ~/.zshrc`
2. Create `~/.zshrc.secrets` for API keys (see Secrets Management below)
3. Customize machine-specific settings if needed

## 📦 What's Included

### Shell Configuration (ZSH)
- **Starship** prompt with git integration
- **Modern CLI tools:**
  - `eza` - colorful ls replacement
  - `bat` - syntax-highlighted cat
  - `fzf` - fuzzy finder (Ctrl+R, Ctrl+T)
  - `zoxide` - smart cd
  - `ripgrep` - fast grep
  - `thefuck` - command correction
- **Autocomplete:** zsh-autocomplete with smart suggestions
- **History:** 50K commands with deduplication
- **Colors:** everywhere!

### Git Configuration
- Beautiful diffs with `git-delta`
- Helpful aliases (`gs`, `ga`, `gc`, `glog`)
- Color-coded output

### Tools & Aliases
- Git shortcuts
- Python/development aliases
- Network utilities
- Archive extraction function
- Directory navigation helpers

## 🔒 Secrets Management

API keys and secrets are stored separately in `~/.zshrc.secrets` which is:
- ✅ Automatically loaded by `.zshrc`
- ✅ Excluded from git (.gitignore)
- ✅ Has secure permissions (chmod 600)

**Create your secrets file:**
```bash
touch ~/.zshrc.secrets
chmod 600 ~/.zshrc.secrets
```

**Add your API keys:**
```bash
export GEMINI_API_KEY="your-key-here"
export OPENAI_API_KEY="your-key-here"
# Add more as needed
```

## 🎯 Machine-Specific Configuration

Each machine can have custom settings in `zsh/machines/<hostname>.zsh`

**Current machines:**
- `mmm4.zsh` - M4 Mac Mini (external home on SSD)

To create a config for a new machine:
```bash
hostname -s  # Find your hostname
touch ~/dotfiles/zsh/machines/<hostname>.zsh
```

## 🔌 External Home Directory (macOS)

The M4 Mac Mini uses an external SSD (`/Volumes/mm2ssd/mjb`) as the home directory for more storage space.

### Quick Setup

1. Change home directory in System Settings → Users & Groups → Advanced Options
2. Run the setup script:

```bash
cd ~/dotfiles
./scripts/setup-external-home.sh /Users/mjb /Volumes/mm2ssd/mjb
```

### Structure

```
/Volumes/mm2ssd/mjb/          # $HOME
├── dotfiles/                 # This repo (git-managed)
├── dotfiles2/                # Extended app configs (NOT git-managed)
├── Library/                  # macOS app data
└── .zshrc -> dotfiles/...    # Symlinks to this repo
```

For full documentation, see [docs/HOME_MIGRATION.md](docs/HOME_MIGRATION.md).

## 🔀 OS-Specific Features

The configuration automatically detects your OS and adjusts:

**macOS:**
- Homebrew package manager (`brewup`, `brewclean`)
- macOS-specific paths (LM Studio, etc.)
- 1Password CLI plugin integration
- `localip` shows WiFi IP address

**Linux:**
- APT/DNF/Pacman package managers auto-detected
- Linux-specific paths (`~/.local/bin`)
- `localip` shows first network interface IP
- Compatible with Ubuntu, Fedora, Arch, etc.

**Package Manager Aliases:**
- macOS: `brewup`, `brewclean`
- Ubuntu/Debian: `aptup`, `aptclean`
- Fedora/RHEL: `dnfup`
- Arch: `pacup`, `pacclean`

## 🔄 Keeping Things Updated

### Update Dotfiles from Repo
```bash
cd ~/dotfiles
git pull
```

### Update Repo with Local Changes

**Easy way (recommended):**
```bash
dotfiles-update  # Automatically commits and pushes your changes
```

**Manual way:**
```bash
cd ~/dotfiles
git add .
git commit -m "Update configs from $(hostname)"
git push
```

### Update Installed Packages
```bash
brewup  # Alias for: brew update && brew upgrade && brew cleanup
```

## 📋 Brewfile

The `Brewfile` tracks all Homebrew packages. To restore on a new machine:

```bash
cd ~/dotfiles
brew bundle install
```

To update the Brewfile after installing new packages:
```bash
cd ~/dotfiles
brew bundle dump --force
git add Brewfile
git commit -m "Update Brewfile"
git push
```

## 🎨 Customization

### Colors & Theme
- Starship prompt: Edit `starship/starship.toml`
- Terminal theme: Using Dracula-inspired colors

### Add New Aliases
- Common aliases: Add to main `.zshrc`
- Machine-specific: Add to `zsh/machines/<hostname>.zsh`

### Add New Functions
Add to the "Custom Functions" section in `.zshrc`

## 🛠️ Structure

```
dotfiles/
├── README.md                        # This file
├── install.sh                       # Installation script
├── Brewfile                         # Homebrew packages
├── .gitignore                       # Excludes secrets
├── docs/
│   └── HOME_MIGRATION.md            # External home setup guide
├── zsh/
│   ├── .zshrc                       # Main ZSH config
│   ├── .zprofile                    # Homebrew initialization
│   └── machines/                    # Machine-specific configs
│       └── mmm4.zsh                 # M4 Mac Mini (external home)
├── git/
│   └── .gitconfig                   # Git configuration
├── starship/
│   └── starship.toml                # Prompt configuration
└── scripts/
    └── setup-external-home.sh       # External home migration script
```

## 💡 Useful Commands

| Command | Description |
|---------|-------------|
| `ll` | List files with icons and details |
| `cat file` | View file with syntax highlighting |
| `z project` | Jump to frequently used directory |
| `fuck` / `fk` | Fix last command |
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy find files |
| `glog` | Beautiful git log |
| `gcm "msg"` | Quick git commit |
| `brewup` | Update all Homebrew packages |

## 🔗 Links

- [Starship Documentation](https://starship.rs/)
- [Homebrew](https://brew.sh/)
- [FZF](https://github.com/junegunn/fzf)
- [Zoxide](https://github.com/ajeetdsouza/zoxide)

## 📝 Notes

- **Secrets** are never committed to this repo
- **Backups** of replaced files are created automatically with timestamps
- **Machine configs** allow customization without breaking other systems
- **Symlinks** mean editing local files updates the repo (don't forget to commit!)

## 👨‍💻 Author

Matthew Beatty
- Email: mjbeatty89@gmail.com
- GitHub: [@mjbeatty89](https://github.com/mjbeatty89)
- Role: Chemical Engineer & AI Champion @ General Motors

---

*Last updated: April 2026*
