# Dotfiles

Personal dotfiles repository for managing shell configurations, application settings, and development environment setup across macOS and Linux systems.

## Features

- **Cross-platform**: Works on both macOS and Linux (Debian/Ubuntu)
- **Modular shell configuration**: Shared configs for bash and zsh
- **Modern CLI tools**: Pre-configured bat, eza, ripgrep, fd, delta, and more
- **Consistent theming**: Catppuccin Mocha theme across all tools
- **Idempotent deployment**: Safe to run multiple times
- **Plugin managers**: Antidote (zsh), ble.sh (bash), TPM (tmux), Vundle (vim)

## Quick Start

### First Time Setup on a New Computer

#### 1. Configure GitHub Account

Before cloning this repository, set up Git and SSH access to GitHub:

```bash
# Install Git (if not already installed)
# macOS: git is pre-installed or via Xcode Command Line Tools
xcode-select --install

# Linux:
sudo apt update && sudo apt install git

# Configure Git identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Generate SSH key for GitHub
ssh-keygen -t ed25519 -C "your.email@example.com"
# Press Enter to accept default location (~/.ssh/id_ed25519)
# Optionally set a passphrase

# Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard
# macOS:
pbcopy < ~/.ssh/id_ed25519.pub

# Linux:
cat ~/.ssh/id_ed25519.pub
# Then manually copy the output

# Add SSH key to GitHub account:
# 1. Go to https://github.com/settings/keys
# 2. Click "New SSH key"
# 3. Paste the public key and save

# Test SSH connection
ssh -T git@github.com
# Should see: "Hi username! You've successfully authenticated..."
```

#### 2. Clone and Deploy

```bash
# Clone this repository
cd ~
git clone git@github.com:blewcio/dotfiles.git

# Run deployment script
cd ~/dotfiles
./deploy.sh
```

The deploy script will:
- Initialize git submodules (including private configs if accessible)
- Install shell plugin managers (Antidote, ble.sh)
- Prompt to install packages (Homebrew on macOS, apt on Linux)
- Create symlinks for all configuration files
- Set up vim/neovim with plugin managers
- Configure tmux, git, and other tools

#### 3. Restart Shell

```bash
# Restart your shell or source the config
source ~/.zshrc
# or
source ~/.bashrc
```

## Repository Structure

```
dotfiles/
├── deploy.sh              # Main deployment script (idempotent)
├── shellrc.sh             # Core shell config (sourced by .bashrc/.zshrc)
├── shell.d/               # Modular shell configuration
│   ├── aliases.sh         # Command aliases
│   ├── exports.sh         # Environment variables
│   ├── func.sh            # Utility functions
│   ├── keys.sh            # Key bindings
│   └── private.sh         # Private overrides (gitignored)
├── config/                # Application configurations
│   ├── git/               # Git config with delta pager
│   ├── tmux/              # Tmux with vim bindings
│   ├── bat/               # Syntax highlighting themes
│   ├── zsh/               # Zsh plugins and themes
│   └── ...                # fd, ripgrep, btop, lazygit, etc.
├── bin/                   # Custom scripts
├── mac/
│   ├── Brewfile           # Homebrew packages
│   └── mac-install.sh     # macOS installation script
├── private/               # Private config submodule (optional)
└── agents/                # Claude Code agents and skills
```

## Key Configuration Files

### Shell
- `shellrc.sh`: Main entry point sourced by both bash and zsh
- `shell.d/*.sh`: Modular configs auto-loaded on shell start

### Git
- Uses git-delta for beautiful diffs
- Side-by-side diff view with syntax highlighting
- Catppuccin color scheme

### Tmux
- Prefix: `Ctrl-Space`
- Vim-style navigation (`hjkl`)
- Smart pane switching with vim integration
- Plugins: resurrect, continuum, sessionx, catppuccin theme
- Cheat sheet: `prefix + e`

### Modern CLI Tools

The following modern alternatives are configured and aliased:
- `bat` → `cat` (syntax highlighting)
- `eza` → `ls` (git integration, icons)
- `delta` → git diff pager
- `ripgrep` → `grep`
- `fd` → `find`
- `dust` → `du`
- `duf` → `df`
- `zoxide` → `cd` (smart directory jumping)

## Custom Functions

### FZF + fasd Integration
- `v` - Edit recent files with fuzzy finder
- `j` - Jump to recent directories
- `jf` - Jump to directory containing recent file
- `o` - Open recent files in default application

### Utilities
- `reload` - Reload shell configuration
- `copy_to_trash` - Safe file deletion (aliased to `rm`)

## Platform-Specific

### macOS
- Homebrew package management via `Brewfile`
- iTerm2 shell integration
- Catppuccin iTerm2 color scheme
- FZF key bindings

### Linux
- Debian/Ubuntu package installation
- Optional comprehensive package setup via `debian-packages.sh`

## Development Workflow

### Testing Changes
```bash
# Reload shell config
source ~/dotfiles/shellrc.sh
# or use the alias
reload

# Reload tmux config
# In tmux: prefix + S
```

### Adding New Configurations

**Shell functions/aliases:**
1. Add to appropriate file in `shell.d/`
2. Run `reload` or restart shell

**Application configs:**
1. Place in `config/<app-name>/`
2. Add symlink command to `deploy.sh`
3. Run `./deploy.sh` to deploy

**Packages:**
- macOS: Add to `mac/Brewfile`, run `brew bundle --file=mac/Brewfile`
- Linux: Add to package list in `deploy.sh`

## Post-Installation

### Tmux Plugins
After first tmux launch, install plugins:
```
prefix + I
```

### Neovim
Run `:Mason` in Neovim to install LSP servers.

### iTerm2 Theme (macOS)
1. Open iTerm2 → Preferences (Cmd+,)
2. Go to Profiles → Colors
3. Click 'Color Presets' → Import
4. Select: `~/dotfiles/config/iTerm2/catppuccin-mocha.itermcolors`
5. Choose 'Catppuccin Mocha' from presets

## Private Configuration

The repository supports a private git submodule for sensitive configurations:
- Location: `~/dotfiles/private/`
- Auto-initialized by deploy script if accessible
- Place private shell configs in `private/shell/`
- Alternatively use `shell.d/private.sh` (gitignored)

## Notes

- The script is idempotent - safe to run multiple times
- Git configuration includes user name/email - update as needed
- Vim config uses separate repository at `~/vim-config`
- Some operations require user confirmation (package installation, etc.)

## Requirements

### Minimal
- Git
- Bash or Zsh
- curl/wget

### Recommended
- Homebrew (macOS)
- tmux
- neovim or vim
- Modern terminal with true color support

## Troubleshooting

**Submodule not initialized:**
```bash
cd ~/dotfiles
git submodule update --init --recursive
```

**Symlinks not created:**
```bash
cd ~/dotfiles
./deploy.sh
```

**Shell config not loading:**
Check that `~/.zshrc` or `~/.bashrc` sources `shellrc.sh`:
```bash
grep shellrc ~/.zshrc
```

## License

Personal configuration - use at your own discretion.
