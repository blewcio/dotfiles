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
   - `history.sh`: Shell history configuration (config-style file, like `exports.sh`/`inputrc.sh` — not a functions file)
   - `inputrc.sh`: Readline input configuration
   - `keys.sh`: Key bindings and shortcuts
   - `synology.sh`: NAS-specific functions
   - `private.sh`: Optional local-only override file (gitignored, not synced anywhere). Most private config now lives in the `private` submodule instead — see Submodules below.

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

## Submodules

The repo uses 7 git submodules — running `git submodule update --init --recursive` (or `./deploy.sh`, which now initializes all of them) after cloning is required before things work correctly:

- `private`: private/sensitive shell config (`private/shell/*.sh`, sourced by `shellrc.sh`) and private Claude Code skills (`private/skills/`, merged in by `bin/link-skills`). May not be accessible to everyone who clones this repo — `deploy.sh` skips it gracefully if so.
- `vim-config`: full Neovim/Vim config with Vundle, symlinked to `~/.vimrc`/`~/.config/nvim`.
- `config/{bat,btop,delta,lsd,yazi}/themes`: upstream Catppuccin theme repos, symlinked into each tool's config directory by `deploy.sh`.

## Agents / Claude Code Integration

The `ai/` directory is the source of truth for Claude Code / OpenCode configuration, deployed by `deploy.sh` and `bin/link-skills`:

- `ai/CLAUDE.md` → symlinked to `~/.claude/CLAUDE.md` and `~/.config/opencode/AGENTS.md` (single source, plain symlink — Bob's global instructions live here, not in this file).
- `ai/agents/` → symlinked whole-directory to `~/.claude/agents` (agent definitions, including `ai/agents/product-team/`).
- `ai/skills/` → individual skill directories are symlinked into `~/.claude/skills/` (and mirrored to `~/.config/opencode/skills/`) by `bin/link-skills`, which also merges in `private/skills/`. This is a separate script (not a plain `ln -sf` in `deploy.sh`) because skills need per-item merging from two sources; `CLAUDE.md`/`ai/` don't, since they only have one source. Run `bin/link-skills` manually to pick up newly added skills without a full `deploy.sh` run.

**Product Team Workflow**: an autonomous 6-agent system for running full dev lifecycles (concept → design → architecture → planning → development → delivery), defined across `ai/agents/product-team/` and `ai/skills/product-team/`. Full docs: `ai/PRODUCT-TEAM.md`.

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

Located in `bin/`, added to `PATH` by `shellrc.sh`.

- **Naming convention**: `kebab-case`, no file extension (e.g. `tmux-cht`, `pic-sort-by-date`) — they're meant to be typed like ordinary commands. Exception: `fasd`, a vendored third-party script kept under its upstream name because other integrations look it up by that exact name.
- Every script should have a short header comment explaining what it does — that's the source of truth for what each one does; run `funcs` (or `describe_function <name>` / `fhelp <name>`) to list and inspect them rather than looking here, since this file won't be kept in sync with additions.
- `link-skills` is the one script called from `deploy.sh` itself (symlinks skills into `~/.claude/skills/` and `~/.config/opencode/skills/` — see Agents / Claude Code Integration below).

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
- Private/sensitive configs belong in the `private` submodule (see Submodules); `shell.d/private.sh` is only for local-only tweaks that shouldn't be tracked anywhere, even privately
- Tmux plugins require manual installation: prefix+I after first tmux launch
- Some tools (eza instead of exa) reflect recent package maintenance changes
- For longer functions `shell.d/` add a short description what it does
