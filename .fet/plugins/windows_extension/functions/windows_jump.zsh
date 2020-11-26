#!/bin/zsh
local dir=""
local -A pathes=()
IFS=$'\n'
for _dict in `cat ~/.fet/plugins/windows_extension/windows_shortcut.csv`
do
  local _key=$(echo $_dict | awk -F", *" '{print $1}' )
  local _value=$(echo $_dict | awk -F", *" '{print $2}' )
  pathes[$_key]=$_value
done
for key in ${(k)pathes}; do
  dir="$key\n$dir"
done
dir=$(echo $dir | grep -v '^\s*$')
dir=$(echo $dir |fzf +m --cycle --prompt="Windows Jump > " --bind 'alt-h:abort,alt-j:down,alt-k:up,alt-l:accept,alt-c:abort,ESC:abort')
if [ -n "$dir" ]; then
  cd $pathes[$dir]
fi
