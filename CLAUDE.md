# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository for managing shell configurations, application settings, and development environment setup across macOS and Linux systems. The repository uses symbolic linking to deploy configuration files from a centralized location (`~/dotfiles`) to their expected locations in the home directory.

## Deployment

**Primary command**: `./deploy.sh`

The deploy script handles the complete setup:
- Installs zsh plugin manager (Antidote)
- Downloads iTerm2 shell integration
- Optionally installs macOS packages via Homebrew (using `mac/Brewfile`)
- Adds auto-load lines to `.bashrc` and `.zshrc` to source `shellrc.sh`
- Optionally installs Python packages (xlrd, openpyxl for visidata)
- Installs tmux plugin manager (TPM)
- Optionally installs Linux packages via apt
- Creates symbolic links for all configuration files
- Sets up vim with Vundle plugin manager

**Note**: The script is idempotent - it checks before adding duplicate entries and can be run multiple times safely.

## Architecture

### Core Shell System

The shell configuration uses a modular architecture with three layers:

1. **Entry Point** (`shellrc.sh`): Main configuration file sourced by both `.bashrc` and `.zshrc`
   - Adds custom bin directories to PATH
   - Sources all `.sh` files from `shell.d/` directory
   - Auto-attaches to tmux on SSH sessions
   - Displays system info via fastfetch
   - Shell-specific initialization (zsh: Antidote plugins, P10k prompt, fasd, fzf, zoxide; bash: fzf, fasd, zoxide)

2. **Modular Configs** (`shell.d/`): Shell-agnostic configuration modules
   - `aliases.sh`: Command aliases and replacements (bat for cat, eza for ls, etc.)
   - `exports.sh`: Environment variables
   - `func.sh`: General utility functions
   - `func_pictures.sh`: Image manipulation utilities
   - `func_video.sh`: Video processing utilities
   - `inputrc.sh`: Readline input configuration
   - `keys.sh`: Key bindings and shortcuts
   - `synology.sh`: NAS-specific functions
   - `private.sh`: Private/local overrides (not tracked)

3. **Application Configs** (`config/`): Per-application configuration files
   - Each subdirectory contains config for a specific tool (git, tmux, nvim, bat, fd, etc.)
   - These are symlinked to their expected locations by `deploy.sh`

**Note on bash enhancements:** The setup uses ble.sh (Bash Line Editor) for autosuggestions and syntax highlighting in bash, providing feature parity with zsh plugins. This is initialized early in the bash-specific section of shellrc.sh.

### Key Configuration Files

- **Git** (`config/git/gitconfig`): Uses git-delta as pager with side-by-side diffs, diff3 conflict style
- **Tmux** (`config/tmux/tmux.conf`):
  - Prefix: Ctrl-Space
  - Vim-style keybindings for navigation and copy mode
  - Extensive plugin setup (resurrect, continuum, sessionx, jump, extrakto, catppuccin theme)
  - Smart vim-tmux pane navigation integration
- **Neovim** (`config/nvim/init.vim`): Note that main vim config is in separate repo (`~/vim-config`)

### Tool Preferences

Modern CLI tools are preferred and aliased as replacements:
- `bat` → `cat` (with syntax highlighting)
- `eza` → `ls` (formerly exa)
- `lsd` → additional ls variants with git status
- `dust` → disk usage (reversed like tree)
- `duf` → df (disk free)
- `delta` → git diff pager
- `ripgrep` → grep
- `fd` → find

### Custom Functions & Integrations

- **FZF + fasd**: Enhanced file/directory jumping with fuzzy search
  - `v` - Edit recent files with fzf selector
  - `j` - Jump to recent directories with fzf selector
  - `jf` - Jump to directory containing recent file
  - `o` - Open recent files in default app
- **Trash function**: `rm` is aliased to `copy_to_trash` (preserves original as `del`)

## macOS-Specific

- **Brewfile** (`mac/Brewfile`): Comprehensive list of Homebrew packages and casks
  - Terminal tools: tmux, git, fzf, fasd, ripgrep, fd, bat, eza
  - Productivity apps: Arc, Raycast, Caffeine, SpaceLauncher, Claude Code
  - Development tools: neovim, lazygit, git-delta
  - File management: yazi, nnn, mc, broot
  - System monitoring: btop, bottom, glances, htop
  - Network utilities: nmap, bandwhich, iperf, httpie
  - Media tools: ffmpeg, exiftool, viu, phoenix-slides
  - Data processing: jq, visidata, miller, csvkit, lnav

- **Installation**: Run `mac/mac-install.sh` (prompted by deploy script)

## Custom Scripts

Located in `bin/`:
- `tmux-cht.sh` - Cheat sheet viewer in tmux (bound to prefix+e)
- `docker_backup.sh` - Docker backup utility

- Every script in `bin/`should have a short header comment what it does

## Development Workflow

When modifying configurations:

1. **Testing changes**:
   - For shell configs: `source ~/dotfiles/shellrc.sh` or use `reload` alias
   - For tmux: Prefix+S to reload config
   - For git: Changes are immediate

2. **Adding new shell functions/aliases**:
   - Add to appropriate file in `shell.d/`
   - They'll be automatically sourced on next shell start or reload

3. **Adding new config files**:
   - Place in `config/<app-name>/`
   - Add symlink command to `deploy.sh`

4. **Package management**:
   - macOS: Add to `mac/Brewfile`, then run `brew bundle --file=mac/Brewfile`
   - Linux: Add to packages list in `deploy.sh`

## Shell Compatibility

The setup supports both zsh and bash with shared configuration. Shell-specific code is conditionally loaded in `shellrc.sh` based on `$SHELL` variable.

- **zsh**: Uses Antidote for plugin management, P10k for prompt, advanced completion and syntax highlighting
- **bash**: Uses ble.sh (Bash Line Editor) for autosuggestions and syntax highlighting, bash-completion, fzf integration

## Important Notes

- Pay attention on changes to keep scripts idempotent
- Don't commit any credentials or sensitive data. Warn and ask in such cases.
- The git config contains user-specific name/email that should be updated
- Private/sensitive configs should go in `shell.d/private.sh` (gitignored)
- Vim setup uses external repo at `~/vim-config` with Vundle plugin manager
- Tmux plugins require manual installation: prefix+I after first tmux launch
- Some tools (eza instead of exa) reflect recent package maintenance changes
- For longer functions `shell.d/` add a short description what it does
