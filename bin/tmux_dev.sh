#!/usr/bin/env bash

SESSION="dev"

# Create a new session if it doesn't exist
tmux has-session -t $SESSION 2>/dev/null
if [ $? != 0 ]; then
  tmux new-session -d -s $SESSION -n editor

  # Window 1: Initial pane (will be left pane)
  tmux send-keys -t $SESSION:1 'git status' C-m

  # Split vertically (creates left and right panes)
  tmux split-window -h -t $SESSION:1

  # Resize left pane to 30% of screen width
  tmux resize-pane -t $SESSION:1.1 -x 30%

  # Split the right pane horizontally (creates top-right and bottom-right)
  tmux split-window -v -t $SESSION:1.2

  # Resize to make top-right pane bigger (65% of right side)
  tmux resize-pane -t $SESSION:1.2 -y 65%

  # Send commands to panes
  tmux send-keys -t $SESSION:1.2 'vim' C-m
  tmux send-keys -t $SESSION:1.3 'ls -la' C-m

  # Select the left pane as default
  tmux select-pane -t $SESSION:1.2
fi

# Attach to session
tmux attach -t $SESSION
