# TMUX Custom Keybindings

**Prefix Key:** `C-Space` (instead of default `C-b`)

## Configuration & Session Management

| Key | Action |
|-----|--------|
| `Prefix+S` | Reload tmux configuration |
| `Prefix+b` | Session selector (sessionx plugin) |
| `Prefix+R` | Restore saved session (resurrect plugin) |
| `Prefix+I` | Install new plugins |
| `Prefix+U` | Update plugins |
| `Prefix+Alt+u` | Uninstall plugins not in config |

## Copy Mode & Clipboard

| Key | Action |
|-----|--------|
| `Prefix+i` | Enter copy mode |
| `Prefix+p` | Paste buffer |
| `Prefix+C-r` | Choose buffer (clipboard history) |
| `v` (in copy mode) | Begin selection |
| `y` (in copy mode) | Copy selection and exit |
| `C-u` (in copy mode) | Half page up |
| `C-d` (in copy mode) | Half page down |
| `0` (in copy mode) | Jump to start of line |
| `$` (in copy mode) | Jump to end of line |

## Screen Scrolling (outside copy mode)

| Key | Action |
|-----|--------|
| `Shift+Up` | Scroll half page up |
| `Shift+Down` | Scroll half page down |

## Window Management

| Key | Action |
|-----|--------|
| `Prefix+n` | New window |
| `Prefix+l` | Last window |
| `Prefix+C-w` | Choose tree (window/session selector) |
| `Prefix+C-h` | Previous window |
| `Prefix+C-l` | Next window |
| `Prefix+C-^` or `Prefix+C-6` | Toggle between last active windows |
| `Prefix+D` | Open TODO.md in new window |

## Pane Management

| Key | Action |
|-----|--------|
| `Prefix+v` | Split window horizontally |
| `Prefix+s` | Split window vertically |
| `Prefix+o` | Toggle pane zoom (full screen) |
| `Prefix+c` | Close/kill current pane |
| `Prefix+C-c` | Close all other panes (keep current) |

## Pane Navigation (Vim-aware)

| Key | Action | Notes |
|-----|--------|-------|
| `C-h` | Select left pane | Sends to vim if in vim |
| `C-j` | Select down pane | Sends to vim if in vim |
| `C-k` | Select up pane | Sends to vim if in vim |
| `C-l` | Select right pane | Sends to vim if in vim |

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
| `Prefix+C-t` | Fuzzy search tmux commands | tmux-fzf |
| `Prefix+Tab` | Extract text/path/url from screen | extrakto |
