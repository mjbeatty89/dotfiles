# ============================================================================
# ZSH Configuration for M4 Mac Mini
# Matthew Beatty - mjbeatty89@gmail.com
# ============================================================================

# ============================================================================
# PATH Configuration
# ============================================================================

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/mjb/.lmstudio/bin"

# ============================================================================
# API Keys and Secrets
# ============================================================================
# Source secrets file if it exists (not tracked in git)
if [ -f ~/.zshrc.secrets ]; then
    source ~/.zshrc.secrets
fi

# ============================================================================
# History Configuration
# ============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Write timestamp to history file
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_SPACE         # Don't record entries starting with space
setopt HIST_VERIFY               # Don't execute immediately upon history expansion
setopt SHARE_HISTORY             # Share history between all sessions

# ============================================================================
# Directory Navigation
# ============================================================================
setopt AUTO_CD                   # cd by typing directory name if it's not a command
setopt AUTO_PUSHD                # Make cd push old directory onto directory stack
setopt PUSHD_IGNORE_DUPS         # Don't push multiple copies of same directory
setopt PUSHD_SILENT              # Don't print directory stack after pushd/popd

# ============================================================================
# Completion System
# ============================================================================
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Enable menu selection
zstyle ':completion:*' menu select

# Better completion for kill command
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

# Complete . and .. directories
zstyle ':completion:*' special-dirs true

# Group results by category
zstyle ':completion:*' group-name ''

# Enable approximate matches for completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# ============================================================================
# ZSH Autocomplete (from Homebrew)
# ============================================================================
source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Configure zsh-autocomplete
zstyle ':autocomplete:*' min-input 2
zstyle ':autocomplete:*' min-delay 0.05  # seconds (float)

# ============================================================================
# Colors
# ============================================================================
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Enable colored output for grep
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'

# ============================================================================
# Modern CLI Tool Replacements
# ============================================================================

# eza (modern replacement for ls with colors and icons)
if command -v eza &> /dev/null; then
    alias ls='eza --color=always --group-directories-first --icons'
    alias ll='eza -la --color=always --group-directories-first --icons'
    alias la='eza -a --color=always --group-directories-first --icons'
    alias lt='eza -aT --color=always --group-directories-first --icons'
    alias l.='eza -a | grep "^\."'
fi

# bat (modern replacement for cat with syntax highlighting)
if command -v bat &> /dev/null; then
    alias cat='bat --style=auto'
    alias bathelp='bat --help'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# ripgrep (modern replacement for grep)
if command -v rg &> /dev/null; then
    alias grep='rg'
fi

# fd (modern replacement for find)
if command -v fd &> /dev/null; then
    alias find='fd'
fi

# ============================================================================
# FZF - Fuzzy Finder
# ============================================================================
if command -v fzf &> /dev/null; then
    # Set up fzf key bindings and fuzzy completion
    source <(fzf --zsh)
    
    # Use fd for fzf if available
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi
    
    # Color scheme for fzf
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info \
        --color=fg:#d0d0d0,bg:#121212,hl:#5f87af \
        --color=fg+:#ffffff,bg+:#262626,hl+:#5fd7ff \
        --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff \
        --color=marker:#87ff00,spinner:#af5fff,header:#87afaf"
fi

# ============================================================================
# Zoxide - Smarter cd
# ============================================================================
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# ============================================================================
# TheFuck - Correct Previous Command
# ============================================================================
if command -v thefuck &> /dev/null; then
    eval $(thefuck --alias)
    eval $(thefuck --alias fk)  # Shorter alias
fi

# ============================================================================
# Git Configuration
# ============================================================================

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate --all'

# ============================================================================
# Development Aliases
# ============================================================================

# Python
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'

# Make
alias m='make'

# VSCode
alias code='/Applications/Visual\\ Studio\\ Code.app/Contents/Resources/app/bin/code'

# Quick directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ============================================================================
# Networking & System
# ============================================================================

# Network
alias myip='curl ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias ports='lsof -i -P | grep LISTEN'

# System
alias cpu='top -o cpu'
alias mem='top -o mem'

# Homebrew
alias brewup='brew update && brew upgrade && brew cleanup'

# ============================================================================
# QMK Keyboard Development
# ============================================================================
export QMK_HOME="$HOME/qmk_firmware"

# ============================================================================
# Custom Functions
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$@" && cd "$_"
}

# Extract any archive
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick find file/directory
ff() { find . -type f -name "*$1*"; }
fd() { find . -type d -name "*$1*"; }

# Git commit with message
gcm() {
    git commit -m "$*"
}

# Create and checkout new git branch
gcb() {
    git checkout -b "$*"
}

# Search through command history
h() {
    history | grep "$@"
}

# ============================================================================
# Starship Prompt
# ============================================================================
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# ============================================================================
# Machine-Specific Configuration
# ============================================================================
# Load machine-specific config if it exists
HOSTNAME=$(hostname -s)
MACHINE_CONFIG="$HOME/dotfiles/zsh/machines/${HOSTNAME}.zsh"
if [ -f "$MACHINE_CONFIG" ]; then
    source "$MACHINE_CONFIG"
fi

# ============================================================================
# Welcome Message
# ============================================================================
echo "🚀 M4 Mac Mini - Welcome back, Matthew!"
echo "💡 Tip: Use 'fuck' or 'fk' to correct the last command"

source /Users/mjb/.config/op/plugins.sh
