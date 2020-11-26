#!/bin/zsh
which richcat
if [ "`which richcat`" = "richcat not found" ]; then
  cat ~/.fet/ReadMe.md | fzf --height=80% --ansi --bind "alt-h:abort,alt-j:down,alt-k:up,alt-l:abort,alt-c:abort,ESC:abort"
else
  richcat ~/.fet/ReadMe.md -w 0.9 | fzf --height=80% --ansi --bind "alt-h:abort,alt-j:down,alt-k:up,alt-l:abort,alt-c:abort,ESC:abort"
fi
