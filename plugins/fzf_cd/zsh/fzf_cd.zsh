#!/bin/zsh
local dir=''
dir=$(find ${1:-.} -path '*/\.*' -prune \
                -o -type d -print 2> /dev/null | sort | fzf +m --prompt="Dir > " --bind="alt-h:abort,alt-j:down,alt-k:up,alt-l:accept,alt-c:abort,left:abort,right:accept" --preview "{basename {}; echo; lsi {} -t;}") &&
. ~/.fet/function/cd.zsh "$dir"
