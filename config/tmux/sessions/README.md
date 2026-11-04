# Session layouts

`bin/tmux-sessionizer` runs a layout script once, right after it creates a new
session. It looks for `<project>.sh` (folder name, dots replaced by `_`), then
`default.sh`, in `~/dotfiles/private/tmux-sessions/` first and in this directory
second. The first match wins; sessions that already exist are left alone.

Layouts live here instead of inside the projects, so a cloned repository can
never run code on your machine just because you opened it.

The script gets two environment variables: `SESSION` (the tmux session name) and
`DIR` (the project directory). Example, `default.sh`:

```bash
#!/usr/bin/env bash
tmux rename-window -t "$SESSION:1" editor
tmux send-keys -t "$SESSION:editor" "$EDITOR ." C-m
tmux new-window -d -t "$SESSION" -n shell -c "$DIR"
tmux new-window -d -t "$SESSION" -n git -c "$DIR" "git status; $SHELL"
```
