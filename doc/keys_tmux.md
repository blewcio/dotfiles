# TMUX Custom Keybindings

**Prefix Key:** `C-Space` (instead of default `C-b`)

## Configuration & Session Management

| Key | Action |
|-----|--------|
| `Prefix+S` | Reload tmux configuration |
| `Prefix+I` | Install new plugins |
| `Prefix+U` | Update plugins |
| `Prefix+Alt+u` | Uninstall plugins not in config |

## Copy Mode & Clipboard

| Key | Action |
|-----|--------|
| `Prefix+i` | Enter copy mode |
| `Prefix+]` | Paste buffer (tmux default) |
| `Prefix+C-r` | Choose buffer (clipboard history) |
| `v` (in copy mode) | Begin selection |
| `y` (in copy mode) | Copy selection and exit |
| `C-u` (in copy mode) | Half page up |
| `C-d` (in copy mode) | Half page down |
| `0` (in copy mode) | Jump to start of line |
| `$` (in copy mode) | Jump to end of line |

## Screen Scrolling (in copy mode)

| Key | Action |
|-----|--------|
| `Shift+Up` | Scroll half page up |
| `Shift+Down` | Scroll half page down |

## Sessions

| Key / command | Action |
|---------------|--------|
| `Prefix+C-p` or `tp` | Project sessionizer: pick a project directory, create or switch to its session |
| `tmux-sessionizer <dir>` | Same, for a given directory without the picker |
| `Prefix+C-f` | Switch between running sessions (fzf popup) |
| `Prefix+b` | Back to the previous session |
| `Prefix+(` / `Prefix+)` | Previous / next session (tmux defaults) |
| `Prefix+s` | Session list (tmux default) |
| `Prefix+w` or `Prefix+C-w` | Tree of sessions and windows |
| `Prefix+$` | Rename session (tmux default) |
| `Prefix+d` | Detach (tmux default) |
| `Prefix+C-s` / `Prefix+R` | Save / restore all sessions (resurrect; continuum also saves automatically) |
| `Prefix+C-t` | tmux-fzf menu, including session actions such as kill |
| `ta [name]` | Attach or switch to a session from the shell (fzf pick without a name) |
| `tn [name]` | Create a session named after the current directory or the given name |
| `tm-dev` | Start the "dev" layout (git status, vim, shell) |

Project directories come from `TMUX_PROJECT_DIRS` in `private/shell.d/private.sh` (append `:N` for N levels deep).

## Window Management

| Key | Action |
|-----|--------|
| `Prefix+c` | New window (in the current directory) |
| `Prefix+n` / `Prefix+p` | Next / previous window (tmux defaults) |
| `Prefix+C-h` / `Prefix+C-l` | Previous / next window (repeatable) |
| `Prefix+C-^` | Toggle between last active windows |
| `Prefix+w` or `Prefix+C-w` | Choose tree (window/session selector) |
| `Prefix+D` | Open TODO.md in new window |

## Pane Management

| Key | Action |
|-----|--------|
| `Prefix+v` or `Prefix+%` | Split side by side (current directory) |
| `Prefix+V` or `Prefix+"` | Split stacked (current directory) |
| `Prefix+o` | Next pane (tmux default) |
| `Prefix+z` | Toggle pane zoom (tmux default) |
| `Prefix+x` | Kill current pane, asks first (tmux default) |
| `Prefix+X` | Kill all other panes, asks first |
| `Prefix+s` | Session list (tmux default) |

## Pane Navigation (vim-aware)

| Key | Action | Notes |
|-----|--------|-------|
| `Prefix+h/j/k/l` | Select left / down / up / right pane | Repeatable |
| `C-h/C-j/C-k/C-l` | Move between vim/nvim splits, then into the neighbour tmux pane | Only inside vim/nvim (vim-tmux-navigator); in a shell these keys keep their normal meaning |

## Pane Resizing

| Key | Action |
|-----|--------|
| `Prefix+H` | Resize pane left (10 cells) |
| `Prefix+J` | Resize pane down (10 cells) |
| `Prefix+K` | Resize pane up (10 cells) |
| `Prefix+L` | Resize pane right (10 cells) |

## Plugin Features

| Key | Action | Plugin |
|-----|--------|--------|
| `Prefix+e` | Open cheat sheet | Custom script |
| `Prefix+f` | Jump to text (easymotion-like) | tmux-jump |
| `Prefix+C-f` | Session switcher (fzf popup) | Custom script |
| `Prefix+C-p` | Project sessionizer | Custom script |
| `Prefix+C-t` | Fuzzy search tmux commands | tmux-fzf |
| `Prefix+Tab` | Extract text/path/url from screen | extrakto |
