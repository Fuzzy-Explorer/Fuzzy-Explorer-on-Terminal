#!/bin/zsh
local resolve_table=$(cat ~/.fet/settings/resolve.csv)"\n"$(cat ~/.fet/user/settings/resolve.csv)
local exe_apps=$(echo $resolve_table | grep -E "^${@##*.}" | awk -F", " '{print $2}')
local exe_apps_count=$(echo $exe_apps | wc -l)
if [ $exe_apps_count -gt 1 ]; then
  local selected_app=$(echo $exe_apps | fzf +m --prompt "Apps > " --bind "alt-h:abort,alt-l:accept,left:abort,right:accept,alt-j:down,alt-k:up,alt-c:abort,ESC:abort")
else;
  if [ -n "$exe_apps" ]; then
    local selected_app=$exe_apps
  else;
    local selected_app="vim"
  fi
fi
if [ -n "$selected_app" ]; then
  "$selected_app" "$@"
fi
