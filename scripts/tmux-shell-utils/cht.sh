#!/usr/bin/env bash

languages=$(echo "typescript python flutter bash" | tr " " "\n")
core_utils=$(echo "find xargs sed awk" | tr " " "\n")

selected=$(echo -e "$languages\n$core_utils" | fzf)

read -p "Search: " query
if echo "$languages" | grep -qs "$selected"; then
    echo $(echo "$query" | tr " " "+")
    tmux split-window -p 42 -h "bash -c 'curl cht.sh/$selected/$(echo "$query" | tr " " "+")' | less"
  else
    tmux split-window -p 42 -h "bash -c 'curl cht.sh/$selected~$query' | less"
fi
