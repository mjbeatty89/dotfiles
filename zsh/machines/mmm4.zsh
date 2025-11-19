# ============================================================================
# Machine-Specific Configuration: M4 Mac Mini (mmm4)
# ============================================================================

# M4 Mac Mini - 10-core CPU optimization
export MAKEFLAGS="-j$(sysctl -n hw.ncpu)"

# Homebrew optimizations
export HOMEBREW_NO_AUTO_UPDATE=1  # Faster brew commands (update manually with brewup)

# M4-specific aliases
alias cpu-info='sysctl -a | grep machdep.cpu'
alias m4-temp='sudo powermetrics --samplers smc -i1 -n1'

# QMK Firmware development (you have QMK installed)
export QMK_HOME="$HOME/qmk_firmware"

# Warp terminal specific settings (if needed)
export WARP_THEME="dracula"

# Add any M4-specific paths or tools here
# export PATH="$HOME/m4-specific-tools:$PATH"

echo "🖥️  M4 Mac Mini config loaded"
