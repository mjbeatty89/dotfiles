#!/bin/bash
# ============================================================================
# Ansible Bootstrap Script
# Installs Ansible and runs the setup playbook
# ============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Ansible Bootstrap${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

echo -e "Detected OS: ${YELLOW}$OS${NC}"
echo ""

# Install Ansible if not present
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${YELLOW}Ansible not found. Installing...${NC}"
    
    if [[ "$OS" == "macos" ]]; then
        # Check for Homebrew
        if ! command -v brew &> /dev/null; then
            echo -e "${YELLOW}Installing Homebrew...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        brew install ansible
    else
        # Linux - try pip
        if command -v pip3 &> /dev/null; then
            pip3 install --user ansible
        elif command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y ansible
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ansible
        else
            echo -e "${RED}Cannot install Ansible. Please install manually.${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✓ Ansible installed${NC}"
else
    echo -e "${GREEN}✓ Ansible already installed${NC}"
fi

echo ""
ansible --version | head -1

# Run the appropriate playbook
echo ""
echo -e "${BLUE}Running setup playbook...${NC}"
echo ""

cd "$SCRIPT_DIR"

if [[ "$OS" == "macos" ]]; then
    ansible-playbook -i inventory/hosts.yml playbooks/setup-macos.yml --ask-become-pass "$@"
else
    ansible-playbook -i inventory/hosts.yml playbooks/setup-linux.yml --ask-become-pass "$@"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Bootstrap complete!${NC}"
echo -e "${GREEN}============================================${NC}"
