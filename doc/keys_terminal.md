# Terminal Keybindings Reference

## Custom Filesystem Operations

| Key | Action | Source |
|-----|--------|--------|
| `A-.` | cd .. (parent directory) | Custom |
| `A-*` | ls (list files) | Custom |
| `A-c` | fzf-based cd (fuzzy directory search) | fzf |
| `A-i` | fzf file search | fzf |
| `C-t` | fzf file widget | fzf |

## Word Navigation

| Key | Action | Source |
|-----|--------|--------|
| `A-b` | Move backward one word | Default |
| `A-f` | Move forward one word | Default |

## Text Selection (ZSH only)

| Key | Action |
|-----|--------|
| `Shift+Left` | Select backward by character |
| `Shift+Right` | Select forward by character |
| `Shift+Up` | Select entire line |
| `Shift+Down` | Deselect region |
| `Shift+Alt+Left` | Select backward by word |
| `Shift+Alt+Right` | Select forward by word |

## Editor Integration

| Key | Action |
|-----|--------|
| `C-x C-e` | Edit command in VIM |
| `C-x C-o` | Override mode |
| `C-x C-v` | VIM mode |

## Cursor Navigation

| Key | Action |
|-----|--------|
| `C-a` | Jump to beginning of line |
| `C-e` | Jump to end of line |
| `C-f` | Move forward 1 character |
| `C-b` | Move backward 1 character |

## Text Deletion & Editing

| Key | Action | Notes |
|-----|--------|-------|
| `C-u` | Delete entire line | |
| `C-d` | Delete 1 character forward | |
| `C-h` | Delete 1 character backward | |
| `C-w` | Delete 1 word before cursor | |
| `A-d` | Delete 1 word forward | |
| `A-k` | Delete forward to end of line | **Remapped from C-k** (C-k used for tmux) |
| `A-t` | Swap words | |
| `C-t` | Swap characters | |
| `C-_` | Undo changes in terminal line | |

## Copy & Paste

| Key | Action |
|-----|--------|
| `C-o` | Copy line to clipboard |
| `C-y` | Paste erased text |
| `A-y` | Flip through yank ring |
| `C-q` | Clear command line and insert text after next command |

## Display & Process Control

| Key | Action |
|-----|--------|
| `C-l` | Clear terminal |
| `C-c` | Stop current process |
| `C-z` | Pause current process |
| `C-d` | Log out of current terminal |

## History Navigation

| Key | Action | Notes |
|-----|--------|-------|
| `C-p` | Move up in history | |
| `C-n` | Move down in history | |
| `C-r` | Search command history | Uses fzf-history-widget in zsh |
| `C-g` | Close command history | |

## Shell Shortcuts & Expansion

| Key | Action |
|-----|--------|
| `A-.` | Last argument from previous command |
| `-` | Previous working directory (cd -) |
| `!!` | Repeat last command (e.g., sudo !!) |
| `!!vi` | Repeat last command starting with "vi" |
| `!$` | Last argument of previous command |
| `!^` | First argument of previous command |

## Fasd + FZF Integration

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
