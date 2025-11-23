# My cheat sheet with key bindings
keys() {
  local keys_file="$HOME/dotfiles/doc/keys_terminal.md"

  if [ -f "$keys_file" ]; then
    # Use bat if available for syntax highlighting, otherwise use cat
    if command -v bat &> /dev/null; then
      bat --style=plain --paging=never "$keys_file"
    else
      cat "$keys_file"
    fi
  else
    echo "Error: Keybindings file not found at $keys_file"
    return 1
  fi
}

# TMUX custom keybindings cheat sheet
keys_tmux() {
  local keys_file="$HOME/dotfiles/doc/keys_tmux.md"

  if [ -f "$keys_file" ]; then
    # Use glow for nice markdown rendering, fallback to bat, then cat
    if command -v glow &> /dev/null; then
      glow "$keys_file"
    elif command -v bat &> /dev/null; then
      bat --style=plain --paging=never "$keys_file"
    else
      cat "$keys_file"
    fi
  else
    echo "Error: TMUX keybindings file not found at $keys_file"
    return 1
  fi
}


