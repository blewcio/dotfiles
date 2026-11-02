# Internal: show a markdown cheat sheet in a pager (scroll with j/k, search with /)
_show_doc() {
  local file="$1"
  if [ ! -t 1 ]; then
    cat "$file"
  elif command -v glow &> /dev/null; then
    glow --pager "$file"
  elif command -v bat &> /dev/null; then
    bat --style=plain --paging=always "$file"
  else
    ${PAGER:-less} "$file"
  fi
}

# Show the terminal key bindings cheat sheet (scroll, / to search)
keys() {
  local keys_file="$HOME/dotfiles/doc/keys_terminal.md"

  if [ -f "$keys_file" ]; then
    _show_doc "$keys_file"
  else
    echo "Error: Keybindings file not found at $keys_file"
    return 1
  fi
}

# Show the tmux key bindings cheat sheet (scroll, / to search)
keys_tmux() {
  local keys_file="$HOME/dotfiles/doc/keys_tmux.md"

  if [ -f "$keys_file" ]; then
    _show_doc "$keys_file"
  else
    echo "Error: TMUX keybindings file not found at $keys_file"
    return 1
  fi
}


