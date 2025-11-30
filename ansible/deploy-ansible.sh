#!/bin/bash
# Wrapper script to run the Ansible playbook
# Usage: ./ansible/deploy-ansible.sh [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Dotfiles Ansible Deployment Tool    ║${NC}"
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}Error: Ansible is not installed.${NC}"
    echo
    echo "Install Ansible:"
    echo "  macOS:  brew install ansible"
    echo "  Linux:  sudo apt install ansible"
    exit 1
fi

# Check if required collections are installed
echo -e "${YELLOW}Checking Ansible collections...${NC}"
if ! ansible-galaxy collection list | grep -q "community.general"; then
    echo -e "${YELLOW}Installing required Ansible collections...${NC}"
    ansible-galaxy collection install -r requirements.yml
else
    echo -e "${GREEN}✓ Required collections are installed${NC}"
fi
echo

# Parse command-line arguments
CHECK_MODE=""
VERBOSE=""
EXTRA_VARS=""
SKIP_PACKAGES=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --check|-c)
            CHECK_MODE="--check"
            shift
            ;;
        --verbose|-v)
            VERBOSE="-v"
            shift
            ;;
        -vv)
            VERBOSE="-vv"
            shift
            ;;
        -vvv)
            VERBOSE="-vvv"
            shift
            ;;
        --skip-packages)
            SKIP_PACKAGES="-e install_macos_packages=false -e install_linux_packages=false"
            shift
            ;;
        --skip-macos-packages)
            EXTRA_VARS="$EXTRA_VARS -e install_macos_packages=false"
            shift
            ;;
        --skip-linux-packages)
            EXTRA_VARS="$EXTRA_VARS -e install_linux_packages=false"
            shift
            ;;
        --skip-python-packages)
            EXTRA_VARS="$EXTRA_VARS -e install_python_packages=false"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo
            echo "Options:"
            echo "  -c, --check              Run in check mode (dry-run)"
            echo "  -v, --verbose            Verbose output (-v, -vv, -vvv for more)"
            echo "  --skip-packages          Skip all package installation"
            echo "  --skip-macos-packages    Skip macOS Homebrew packages"
            echo "  --skip-linux-packages    Skip Linux apt packages"
            echo "  --skip-python-packages   Skip Python package installation"
            echo "  -h, --help               Show this help message"
            echo
            echo "Examples:"
            echo "  $0                       # Full deployment"
            echo "  $0 --check               # Dry-run to see what would change"
            echo "  $0 --skip-packages       # Deploy configs only, skip packages"
            echo "  $0 -v                    # Verbose output"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Display deployment mode
if [ -n "$CHECK_MODE" ]; then
    echo -e "${YELLOW}Running in CHECK MODE (dry-run)${NC}"
    echo -e "${YELLOW}No changes will be made to the system${NC}"
    echo
fi

# Run the playbook
echo -e "${GREEN}Running Ansible playbook...${NC}"
echo

ansible-playbook \
    -i inventory.yml \
    dotfiles.yml \
    $CHECK_MODE \
    $VERBOSE \
    $SKIP_PACKAGES \
    $EXTRA_VARS

# Success message
echo
if [ -n "$CHECK_MODE" ]; then
    echo -e "${GREEN}✓ Check completed successfully!${NC}"
    echo -e "${YELLOW}Run without --check to apply changes${NC}"
else
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Deployment completed! 🎉           ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo
    echo "Next steps:"
    echo "  1. Restart your shell or run: source ~/dotfiles/shellrc.sh"
    echo "  2. Launch tmux and press prefix+I to install tmux plugins"
    echo "  3. If using Neovim, launch it and run :Mason to install LSP servers"
    echo "  4. Update git user.name and user.email in ~/.gitconfig"
fi
