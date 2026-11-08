# Herdr Keybindings

**Prefix Key:** `Ctrl+Space` (same as tmux). Config: `config/herdr/config.toml`. Press `prefix ?` in herdr for the full, current list; `/` filters it.

Keys marked *custom* differ from herdr's defaults.

## Navigation

| Key | Action |
|-----|--------|
| `prefix g` | Go-to picker: jump to any agent or terminal, grouped by workspace (`/` searches) |
| `prefix w` | Workspace picker |
| `prefix o` | Open the target of the latest notification |
| `prefix h/j/k/l` | Focus the pane left / down / up / right |
| `prefix tab` / `prefix shift+tab` | Next / previous pane |

## Tabs & Workspaces

| Key | Action |
|-----|--------|
| `prefix c` | New tab |
| `prefix n` / `prefix p` | Next / previous tab |
| `prefix 1`..`9` | Jump to tab by number |
| `prefix shift+t` | Rename tab |
| `prefix shift+x` | Close tab |
| `prefix shift+n` | New workspace |
| `prefix shift+w` | Rename workspace |
| `prefix shift+d` | Close workspace |

## Panes

| Key | Action |
|-----|--------|
| `prefix v` | Split side by side |
| `prefix shift+v` | Split stacked *(custom, matches tmux `Prefix+V`)* |
| `prefix z` | Zoom the pane |
| `prefix x` | Close the pane |
| `prefix shift+h/j/k/l` | Swap the pane with its neighbour |
| `prefix r` | Resize mode |
| `prefix shift+p` | Rename pane |
| `prefix b` | Toggle the sidebar |

## Scrollback & Copy

| Key | Action |
|-----|--------|
| Mouse wheel / PageUp | Scroll |
| `prefix i` | Copy mode *(custom, matches tmux; herdr default is `prefix [`)* |
| `prefix e` | Open the pane's scrollback in `$EDITOR` |

In copy mode: `h/j/k/l`, `w/b/e`, `{` `}`, `Ctrl-u`/`Ctrl-d`; `v`, Space or `V` start a selection. Mouse drags copy on select.

## Session & Config

| Key | Action |
|-----|--------|
| `prefix q` | Detach (agents keep running); reattach with `herdr` |
| `prefix shift+r` | Reload config |
| `prefix s` | Settings |
| `prefix ?` | Show all active bindings |

## Not available (compared to tmux)

No `F12` nested toggle, no sessionizer (`Prefix+C-p`), no vim-aware `C-h/j/k/l`. If clicks or the wheel stop working in a tab after a long time, detach with `prefix q` and run `herdr` again.
