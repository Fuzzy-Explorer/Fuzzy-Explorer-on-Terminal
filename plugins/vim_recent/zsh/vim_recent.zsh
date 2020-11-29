#!/bin/zsh
local BUFFER=$(tac "$HOME/.vim_recent" | awk '!a[$0]++' | sed "s:$HOME:~:" | fzf +m --query "$1" --prompt="Vim Recent > " --preview "echo {} | xargs -rI{a} sh -c 'basename {a}; batcat {a} --color=always --style=grid --line-range :100;'" --bind "alt-h:abort,alt-j:down,alt-k:up,alt-l:accept,ctrl-j:preview-down,ctrl-k:preview-up,alt-i:toggle-preview,alt-c:abort,alt-b:preview:echo {} | cut -f 2 -d ' ' | xargs -rI{a} sh -c 'if [ -f {a} ]; then ls -ldhG {a}; echo; richcat {a} -w $(echo $(tput cols) \* 0.46 | bc); else ls -ldhG {a}; echo; lsi {a}; fi'")
if [ -n "$BUFFER" ]; then
  BUFFER="vim $BUFFER"
  eval $BUFFER
fi
