# TMUX Keybindings Analysis: Custom vs Default

## Prefix Key

| Binding | Default | Custom | Notes |
|---------|---------|--------|-------|
| Prefix | `C-b` | **`C-Space`** | Changed for easier reach |

## Core Configuration

| Action | Default | Custom | Status |
|--------|---------|--------|--------|
| Reload config | `:source-file ~/.tmux.conf` | **`Prefix+S`** | Custom addition |
| Command prompt | `Prefix+:` | `Prefix+:` | ✓ Default preserved |

## Window Management

| Action | Default | Custom | Status |
|--------|---------|--------|--------|
| New window | `Prefix+c` | **`Prefix+n`** | Changed (c repurposed) |
| Kill window | `Prefix+&` | `Prefix+&` | ✓ Default preserved |
| Last window | `Prefix+l` | `Prefix+l` | ✓ Default preserved |
| Previous window | `Prefix+p` | **`Prefix+C-h`** | Custom vim-style |
| Next window | `Prefix+n` | **`Prefix+C-l`** | Custom vim-style (n repurposed) |
| Choose tree | `Prefix+w` | **`Prefix+C-w`** | Modified binding |
| Toggle last windows | `Prefix+l` (duplicates last-window) | **`Prefix+C-^`, `Prefix+C-6`** | Alternative bindings added |
| Select window 0-9 | `Prefix+0-9` | `Prefix+0-9` | ✓ Default preserved |

## Pane Management

| Action | Default | Custom | Status |
|--------|---------|--------|--------|
| Split horizontal | `Prefix+"` | **`Prefix+s`** | Changed to vim-style |
| Split vertical | `Prefix+%` | **`Prefix+v`** | Changed to vim-style |
| Kill pane | `Prefix+x` (with confirm) | **`Prefix+c`** | Changed (no confirm mention) |
| Kill all others | - | **`Prefix+C-c`** | Custom addition |
| Zoom/toggle fullscreen | `Prefix+z` | **`Prefix+o`** | Changed |
| Break pane | `Prefix+!` | `Prefix+!` | ✓ Default preserved |
| Display pane numbers | `Prefix+q` | `Prefix+q` | ✓ Default preserved |

## Pane Navigation

| Action | Default | Custom | Status |
|--------|---------|--------|--------|
| Select left pane | `Prefix+←` | **`C-h`** (no prefix) | Vim-style, vim-aware |
| Select down pane | `Prefix+↓` | **`C-j`** (no prefix) | Vim-style, vim-aware |
| Select up pane | `Prefix+↑` | **`C-k`** (no prefix) | Vim-style, vim-aware |
| Select right pane | `Prefix+→` | **`C-l`** (no prefix) | Vim-style, vim-aware |
| Last pane | `Prefix+;` | `Prefix+;` | ✓ Default preserved |

## Pane Resizing

| Action | Default | Custom | Status |
|--------|---------|--------|--------|
| Resize left | `Prefix+C-←` | **`Prefix+H`** | Vim-style (10 cells) |
| Resize down | `Prefix+C-↓` | **`Prefix+J`** | Vim-style (10 cells) |
| Resize up | `Prefix+C-↑` | **`Prefix+K`** | Vim-style (10 cells) |
| Resize right | `Prefix+C-→` | **`Prefix+L`** | Vim-style (10 cells) |
| Resize left (1 cell) | `Prefix+M-←` | - | Not configured |
| Resize down (1 cell) | `Prefix+M-↓` | - | Not configured |
| Resize up (1 cell) | `Prefix+M-↑` | - | Not configured |
| Resize right (1 cell) | `Prefix+M-→` | - | Not configured |

## Copy Mode

| Action | Default | Custom | Status |
|--------|---------|--------|--------|
| Enter copy mode | `Prefix+[` | **`Prefix+i`** | Changed (vim-inspired) |
| Paste buffer | `Prefix+]` | **`Prefix+p`** | Changed (vim p for paste) |
| Choose buffer | `Prefix+=` | **`Prefix+C-r`** | Changed (vim register style) |
| List all buffers | `Prefix+#` | `Prefix+#` | ✓ Default preserved |

### Copy Mode (while in copy mode)

| Action | Default (emacs) | Custom (vi mode) | Status |
|--------|-----------------|------------------|--------|
| Begin selection | - | **`v`** | Vi mode enabled |
| Copy selection | `M-w` | **`y`** | Vi mode enabled |
| Half page up | - | **`C-u`** | Vi mode enabled |
| Half page down | - | **`C-d`** | Vi mode enabled |
| Start of line | `C-a` | **`0`** | Vi mode enabled |
| End of line | `C-e` | **`$`** | Vi mode enabled |

## Scrolling (outside copy mode)

| Action | Default | Custom | Status |
|--------|---------|--------|--------|
| Scroll up | - | **`Shift+Up`** | Custom addition |
| Scroll down | - | **`Shift+Down`** | Custom addition |

## Session Management

| Action | Default | Custom | Status |
|--------|---------|--------|--------|
| Detach | `Prefix+d` | `Prefix+d` | ✓ Default preserved |
| Choose session | `Prefix+s` | - | Removed (s repurposed) |
| Rename session | `Prefix+$` | `Prefix+$` | ✓ Default preserved |

## Plugin Bindings (All Custom)

| Binding | Action | Plugin |
|---------|--------|--------|
| `Prefix+I` | Install plugins | tpm |
| `Prefix+U` | Update plugins | tpm |
| `Prefix+Alt+u` | Uninstall plugins | tpm |
| `Prefix+R` | Restore session | tmux-resurrect |
| `Prefix+b` | Session selector | tmux-sessionx |
| `Prefix+f` | Jump to text | tmux-jump |
| `Prefix+C-t` | Tmux command search | tmux-fzf |
| `Prefix+Tab` | Extract text from screen | extrakto |
| `Prefix+e` | Cheat sheet | Custom script |
| `Prefix+D` | Open TODO.md | Custom script |

## Summary Statistics

**Changed from defaults:** 18 bindings
**Custom additions:** 14 bindings
**Default preserved:** 11+ bindings
**Repurposed keys:**
- `c` (was new-window, now kill-pane)
- `n` (was next-window, now new-window)
- `s` (was choose-session, now split-horizontal)

## Philosophy

Your configuration follows these patterns:

1. **Vim-centric**: Heavy use of `hjkl` for navigation, `v` for visual selection, `y` for yank
2. **No-prefix navigation**: Pane switching with `C-h/j/k/l` without prefix (vim-aware)
3. **Consistent resizing**: Capital letters `HJKL` for larger movements (10 cells)
4. **Ergonomic prefix**: `C-Space` instead of `C-b` for easier reach
5. **Mnemonic splits**: `v` for vertical, `s` for horizontal (matches vim)
6. **Plugin-heavy**: Extensive use of plugins for fuzzy finding and session management

## Potential Conflicts

1. **`Prefix+s` removed**: Default "choose session" is no longer available (replaced with split)
   - Alternative: Use `Prefix+b` (sessionx plugin) for better session selection
2. **`C-l` overloaded**: Used for both pane navigation and clear screen in shell
   - Workaround: In shell, use `Prefix+C-l` or type `clear`
3. **`Prefix+c` changed**: Veterans expecting "new window" will kill panes instead
   - Alternative: Use `Prefix+n` for new window
