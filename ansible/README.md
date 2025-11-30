# Ansible Playbook for Dotfiles Deployment

This Ansible playbook automates the deployment of dotfiles and development environment configuration, replacing the `deploy.sh` bash script with a more robust, idempotent solution.

## Features

- **Cross-platform support**: Works on macOS and Linux (Debian/Ubuntu)
- **Idempotent**: Safe to run multiple times without side effects
- **Declarative**: Clear, readable configuration
- **Flexible**: Easy to customize via variables
- **Comprehensive**: Handles all aspects of the deployment:
  - Package installation (Homebrew, apt)
  - Shell configuration (bash, zsh)
  - Plugin managers (Antigen, TPM, Vundle)
  - Configuration symlinks
  - Vim/Neovim setup

## Prerequisites

### Install Ansible

**macOS:**
```bash
brew install ansible
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt update
sudo apt install ansible
```

**Verify installation:**
```bash
ansible --version
```

### Install Ansible Collections

The playbook uses the `community.general` collection for Homebrew support:

```bash
ansible-galaxy collection install community.general
```

## Usage

### Basic Deployment

Run the playbook to deploy dotfiles on the local machine:

```bash
cd ~/dotfiles
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml
```

### Customizing Behavior

Edit `ansible/vars.yml` to customize the deployment:

```yaml
# Enable/disable package installation
install_macos_packages: true
install_linux_packages: true
install_python_packages: true

# Customize package lists
linux_packages:
  - tmux
  - vim
  # ... add more packages
```

### Override Variables at Runtime

You can override any variable without editing files:

```bash
# Skip macOS package installation
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml \
  -e "install_macos_packages=false"

# Skip Python packages
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml \
  -e "install_python_packages=false"

# Use a different dotfiles directory
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml \
  -e "dotfiles_dir=/path/to/dotfiles"
```

### Dry Run (Check Mode)

See what changes would be made without actually making them:

```bash
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml --check
```

### Verbose Output

Get detailed information about what Ansible is doing:

```bash
# Basic verbose
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml -v

# More verbose (shows task arguments)
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml -vv

# Very verbose (shows connection debugging)
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml -vvv
```

### Run Specific Tasks

Use tags to run only specific parts of the playbook (if tags are added):

```bash
# Example: Only run symlink tasks
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml --tags "symlinks"
```

## What Gets Deployed

### Shell Configuration
- Downloads and configures Antigen (zsh plugin manager)
- Adds `shellrc.sh` sourcing to `.bashrc` and `.zshrc`
- Downloads iTerm2 shell integration (macOS only)

### Package Managers
- Installs Homebrew (macOS)
- Installs packages from `mac/Brewfile` (macOS)
- Installs base packages via apt (Linux)

### Plugin Managers
- Clones and configures Tmux Plugin Manager (TPM)
- Clones and configures Vundle (Vim plugin manager)

### Configuration Symlinks
Creates symlinks for:
- `.tmux.conf`
- `.gitconfig` and `.gitignore_global`
- `.visidatarc`
- `.ignore` (ripgrep)
- `.config/fd/ignore`
- `.config/bat/config`
- `.config/fastfetch/config.jsonc`

### Vim/Neovim Setup
- Clones `vim-config` repository
- Symlinks Vim configuration files
- Creates Vim temporary directories
- Installs Vundle and Vim plugins
- Symlinks Neovim configuration (if Neovim is installed)

### Optional Components
- Python packages (xlrd, openpyxl for visidata)
- FZF installation and key bindings (macOS)
- Powerline10k configuration (macOS, disabled by default)

## Advantages Over deploy.sh

1. **Idempotency**: Safe to run multiple times; Ansible checks state before making changes
2. **Better Error Handling**: Ansible provides detailed error messages and rollback capabilities
3. **Modularity**: Easy to skip or customize specific tasks
4. **Cross-platform**: Better abstraction for platform differences
5. **Dry Run**: Test changes before applying them (`--check` mode)
6. **Reporting**: Clear output showing what changed and what didn't
7. **Remote Deployment**: Can easily deploy to remote machines
8. **No Interactive Prompts**: All configuration is declarative (no y/n prompts)

## Troubleshooting

### Homebrew Module Not Found

If you get an error about the `homebrew_bundle` module:

```bash
ansible-galaxy collection install community.general
```

### Permission Denied Errors

Some tasks (like apt package installation) require sudo privileges. The playbook uses `become: yes` for these tasks. You may need to run:

```bash
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml --ask-become-pass
```

### Python Interpreter Issues

If Ansible can't find the correct Python interpreter:

```bash
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml \
  -e "ansible_python_interpreter=/usr/bin/python3"
```

### Existing Configuration Conflicts

The playbook uses `force: yes` for symlinks, which will overwrite existing files. To be safe:

1. Run with `--check` first to see what would change
2. Back up any important configurations
3. Review the changes in `ansible/vars.yml`

## Migrating from deploy.sh

If you've been using `deploy.sh`, you can safely switch to the Ansible playbook:

1. Review `ansible/vars.yml` and adjust settings as needed
2. Run the playbook with `--check` to preview changes
3. Run the playbook normally to apply changes
4. The playbook handles existing installations gracefully

The Ansible playbook is designed to produce the same result as `deploy.sh` while being more reliable and maintainable.

## Remote Deployment

To deploy dotfiles to remote machines:

1. Edit `ansible/inventory.yml` and add your remote hosts
2. Ensure SSH access is configured
3. Run the playbook targeting the remote host:

```bash
ansible-playbook -i ansible/inventory.yml ansible/dotfiles.yml \
  --limit server1 --ask-become-pass
```

## Contributing

When adding new configuration steps:

1. Add tasks to `ansible/dotfiles.yml`
2. Add relevant variables to `ansible/vars.yml`
3. Update this README with the new functionality
4. Test with `--check` mode first

## Further Reading

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [dotfiles project structure](../CLAUDE.md)
