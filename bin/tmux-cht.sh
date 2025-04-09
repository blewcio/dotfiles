#!/bin/bash
read -p "Help query (e.g. bash print): " query

query=$selected/$(echo $query | tr ' ' '+')

tmux neww bash -c "curl -s cht.sh/$query | less"
tmux rename-window "cht.sh $query"
