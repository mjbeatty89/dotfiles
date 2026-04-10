# Ansible Playbooks

Automation for setting up and maintaining machines across the homelab.

## Quick Start

```bash
# Install Ansible (macOS)
brew install ansible

# Run macOS external home setup
cd ~/dotfiles/ansible
ansible-playbook -i inventory/hosts.yml playbooks/setup-macos.yml
```

## Structure

```
ansible/
├── inventory/
│   └── hosts.yml           # Machine inventory
├── playbooks/
│   └── setup-macos.yml     # macOS setup playbook
└── roles/
    └── macos-external-home/
        ├── tasks/main.yml  # Setup tasks
        └── vars/main.yml   # Configuration variables
```

## Playbooks

### setup-macos.yml

Sets up a macOS machine with external home directory:

- Verifies external home is properly configured
- Migrates data from old home (if exists)
- Creates shell config symlinks (zshrc, zprofile, gitconfig)
- Creates app config symlinks from dotfiles2
- Fixes legacy symlinks pointing to old paths
- Validates the setup

**Usage:**
```bash
# Full setup
ansible-playbook -i inventory/hosts.yml playbooks/setup-macos.yml

# Specific host only
ansible-playbook -i inventory/hosts.yml playbooks/setup-macos.yml --limit mmm4

# Dry run (check mode)
ansible-playbook -i inventory/hosts.yml playbooks/setup-macos.yml --check
```

## Inventory

Machines are defined in `inventory/hosts.yml`:

| Group | Hosts | Description |
|-------|-------|-------------|
| macos | mmm4 | M4 Mac Mini with external home |
| linux | (planned) | Linux desktop |
| servers | (planned) | Unraid, Proxmox, etc. |
| raspberry_pi | (planned) | RPi devices |

## Adding New Machines

1. Add host to `inventory/hosts.yml`:
   ```yaml
   new-mac:
     ansible_host: new-mac.local
     external_home: /Volumes/ssd/username
     old_home: /Users/username
   ```

2. Create machine-specific zsh config:
   ```bash
   touch ~/dotfiles/zsh/machines/$(hostname -s).zsh
   ```

3. Run the playbook:
   ```bash
   ansible-playbook -i inventory/hosts.yml playbooks/setup-macos.yml --limit new-mac
   ```

## Requirements

- Ansible 2.9+
- SSH access (for remote hosts)
- macOS home directory already changed in System Settings (for external home setup)

## Future Roles (Planned)

- `homebrew` - Install and manage Homebrew packages
- `dotfiles` - Clone and setup dotfiles repo
- `linux-desktop` - Linux desktop configuration
- `docker` - Docker setup and configuration
- `backup` - Automated backup configuration
