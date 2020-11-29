#!/bin/bash
dir=""
declare -A pathes=()
IFS=$'\n'
for _dict in `cat ~/.fet/plugins/windows_extension/windows_shortcut.csv`
do
  _key=$(echo $_dict | awk -F", *" '{print $1}' )
  _value=$(echo $_dict | awk -F", *" '{print $2}' )
  pathes[$_key]=$_value
done
for key in ${(k)pathes}; do
  dir="$key\n$dir"
done
dir=$(echo $dir | grep -v '^\s*$')
dir=$(echo $dir |fzf +m --cycle --height 70% --info='inline' --layout=reverse --border --prompt="Windows Jump > " --bind 'alt-h:abort,alt-j:down,alt-k:up,alt-l:accept,alt-c:abort,ESC:abort,left:abort,down:down,up:up,right:accept')
if [ -n "$dir" ]; then
  . ~/.fet/function/cd.bash $pathes[$dir]
fi
