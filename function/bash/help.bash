#!/bin/bash
if [ -n "`which richcat`" ]; then
  richcat ~/.fet/help.md -w 0.9 | fzf --height=80% --ansi --bind "alt-h:abort,alt-j:down,alt-k:up,alt-l:abort,alt-c:abort,ESC:abort"
else
  cat ~/.fet/help.md | fzf --height=80% --ansi --info='inline' --layout=reverse --border --cycle --bind "alt-h:abort,alt-j:down,alt-k:up,alt-l:abort,alt-c:abort,ESC:abort,left:abort,down:down,up:up,right:abort"
fi
