# Terminal Keybindings Reference

Keys are for zsh unless marked otherwise. `A-` is Alt/Option, `C-` is Ctrl. Sources: *Default* is the shell's own binding, *Custom* is set in this repo, anything else is the plugin that provides it.

## Cursor & Word Movement

| Key | Action | Source |
|-----|--------|--------|
| `C-a` | Jump to beginning of line | Default |
| `C-e` | Jump to end of line | Default |
| `C-f` / `C-b` | Move forward / backward 1 character | Default |
| `A-f` / `A-b` | Move forward / backward one word | Default |
| `A-Right` / `A-Left` | Move forward / backward one word | Custom |
| `C-Right` / `C-Left` | Move forward / backward one word | Default |

## Text Selection (zsh only)

| Key | Action | Source |
|-----|--------|--------|
| `Shift+Left` / `Shift+Right` | Select backward / forward by character | Custom |
| `Shift+Alt+Left` / `Shift+Alt+Right` | Select backward / forward by word | Custom |
| `Shift+Up` / `Shift+Alt+Up` / `Shift+Alt+Down` | Select entire line | Custom |
| `Shift+Down` | Deselect | Custom |
| `C-x C-x` | Swap cursor and mark | Default |

## Delete, Undo & Transpose

| Key | Action | Notes |
|-----|--------|-------|
| `C-u` | Delete entire line | |
| `C-w` | Delete 1 word before cursor | |
| `A-d` | Delete 1 word forward | |
| `A-k` | Delete forward to end of line | **Remapped from C-k** (C-k used for tmux) |
| `C-d` | Delete 1 character forward | On an empty line: log out |
| `C-h` | Delete 1 character backward | |
| `A-t` | Swap words | |
| `C-_` | Undo changes in the command line | Default |
| `C-x C-u` | Undo (same as `C-_`) | Default |

## Copy & Paste

| Key | Action | Source |
|-----|--------|--------|
| `C-o` | Copy line to the system clipboard | copybuffer |
| `C-y` | Paste erased text | Default |
| `A-y` | Flip through the yank ring | Default |
| `C-q` | Park the command line and restore it after the next command | Default |
| `A-q` | Same as `C-q` | Default |

## History

| Key | Action | Source |
|-----|--------|--------|
| `C-r` | Fuzzy search command history | fzf |
| `Up` / `Down` | History search on the text already typed | history-substring-search |
| `A-p` / `A-n` | History search backward / forward by typed prefix | Default |
| `C-p` / `C-n` | Previous / next history entry | Default |
| `C-s` | Search history forward | Custom |
| `C-g` | Abort current input or history search | Default |
| `A-.` | Insert last argument of the previous command | Default |

## Completion & Expansion

| Key | Action | Source |
|-----|--------|--------|
| `Tab` | Fuzzy completion menu | fzf-tab |
| `Shift+Tab` | Previous entry in the completion menu | Default |
| `Space` | Expand an abbreviation (`abbr`) | zsh-abbr |
| `!!` | Repeat last command (e.g. `sudo !!`) | Default |
| `!!vi` | Repeat last command starting with "vi" | Default |
| `!$` | Last argument of previous command | Default |
| `!^` | First argument of previous command | Default |

## Files & Directories

| Key | Action | Source |
|-----|--------|--------|
| `C-t` | Fuzzy file search, inserts the path | fzf |
| `A-c` | Fuzzy directory search and `cd` | fzf |
| `A--` | `cd -` (previous directory) | Custom |
| `-` | `cd -` (alias) | Oh-My-Zsh |

## Editor & Modes

| Key | Action | Source |
|-----|--------|--------|
| `C-x C-e` | Edit command line in vim (`$EDITOR`); save and quit to run it | Custom (bash: Default) |
| `C-x C-v` | Toggle vi key bindings on and off (Esc for normal mode) | Custom (bash: edit in `$EDITOR`) |

## Command Shortcuts (zsh only)

| Key | Action | Source |
|-----|--------|--------|
| `Esc Esc` | Put `sudo` in front of the command line | sudo |
| `Enter` on an empty line | Run `ls -lh .`, or `git status -u .` in a git repo | magic-enter |
| `A-l` | Run `ls`, keep the current command line | Default |
| `A-h` | Show the man page of the command being typed | Default |
| `A-?` | Show where the command being typed comes from | Default |

## Terminal & Process Control

| Key | Action |
|-----|--------|
| `C-l` | Clear terminal |
| `C-c` | Stop current process |
| `C-z` | Pause current process |

## Fasd + FZF Commands

| Command | Action |
|---------|--------|
| `v [search]` | Edit recent files with fzf selector |
| `j [search]` | Jump to recent directories with fzf selector |
| `jf [search]` | Jump to directory containing recent file |
| `o [search]` | Open recent files in default app |

## German Keyboard Remappings

| Key | Maps To |
|-----|---------|
| `ß` | `/` |
| `¿` | `\` |
| `ü` | `~` |
| `Ü` | `^` |
| `ö` | `[` |
| `ä` | `]` |
| `Ö` | `{` |
| `Ä` | `}` |

---

**Note:** Keybindings may vary between bash and zsh. Text selection with Shift+Arrow keys is zsh-only.
