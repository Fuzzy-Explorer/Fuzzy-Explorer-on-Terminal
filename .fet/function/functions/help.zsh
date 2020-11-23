#!/bin/zsh
echo '0' >| ~/.fet/.status/.functions_help.status
richcat ~/.fet/ReadMe.md -w 0.9 | fzf --height=80% --ansi --bind "alt-h:abort,alt-j:down,alt-k:up,alt-l:abort,alt-c:abort,ESC:abort"
