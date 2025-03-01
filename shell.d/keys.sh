# My cheat sheet with key bindings
keys() {
  echo "\031[0;90m" "C-x C-e   Edit command in VIM"
  echo "\033[0;90m" "C-x C-o   Override mode"
  echo "\033[0;90m" "C-x C-v   VIM mode"
  echo ""
  echo "\033[0;90m" "A-h       cd $HOME"
  echo "\033[0;90m" "A-a       cd -"
  echo "\033[0;90m" "A-l       la"
  echo "\033[0;90m" "A-.       cd .."
  echo "\033[0;90m" "A-l       la"
  echo "\033[0;90m" "A-c       fzf based cd"
  echo "\033[0;90m" "A-i       fzf search of a file"
  echo ""
  echo "\033[0;90m" "C-a       Jump to beginning of line"
  echo "\033[0;90m" "C-e       Jump to end of line"
  echo "\033[0;90m" "C-f       Move (1 char) forward"
  echo "\033[0;90m" "C-b       Move (1 char) backward"
  echo "\033[0;90m" "A-b       Move (1 word) back"
  echo "\033[0;90m" "A-f       Move (1 word) forward"
  echo ""
  echo "\033[0;90m" "C-u       Delete entire line"
  echo "\033[0;90m" "C-d       Delete (1 char) forward"
  echo "\033[0;90m" "C-h       Delete (1 char) backward"
  echo "\033[0;90m" "C-w       Delete (1 word) before cursor"
  echo "\033[0;90m" "A-d       Delete (1 word) forward"
  echo "\033[0;90m" "C-k (now a-k) Delete forward to end of line. Remapped due to pane jumps."
  echo "\033[0;90m" "A-t       Swap words"
  echo "\033[0;90m" "C-t       Swap characters"
  echo "\033[0;90m" "C-_       Undo changes in terminal line"
  echo ""
  echo "\033[0;90m" "C-o       Copy line to clipboard"
  echo "\033[0;90m" "C-y       Paste erased text"
  echo "\033[0;90m" "A-y       Flip through yank ring"
  echo "\033[0;90m" "C-q       Clear command line and insert text after next command"
  echo "\033[0;90m" "C-l       Clear terminal"
  echo ""
  echo "\033[0;90m" "C-c       Stop current process"
  echo "\033[0;90m" "C-z       Pause current process"
  echo "\033[0;90m" "C-d       Log out of the current terminal"
  echo ""
  echo "\033[0;90m" "C-p       Move up (in the history)"
  echo "\033[0;90m" "C-n       Move down (in the history)"
  echo "\033[0;90m" "C-r       Research command history"
  echo "\033[0;90m" "C-g       Close command history"
  echo ""
  echo "\033[0;90m" "A-.       Last argument from prev command"
  echo "\033[0;90m" "-         Previous working directory (cd -)"
  echo "\033[0;90m" "!!        Repeat last command (sudo !!)"
  echo "\033[0;90m" "!!vi      Repeat last command starting with vi"
  echo "\033[0;90m" "!$        Last argument of previous command"
  echo "\033[0;90m" "!^        First argument of previous command"
}


