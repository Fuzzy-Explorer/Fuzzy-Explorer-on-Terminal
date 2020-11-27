#!/bin/bash
if [ "$#" -gt 0 ]; then
  selected_file="$@"
else
  selected_file="$_fet_path_selected_path"
fi
resolve_table=$(cat ~/.fet/settings/resolve.csv)"\n"$(cat ~/.fet/user/settings/resolve.csv)
exe_apps=$(echo $resolve_table | grep -E "^${selected_file##*.}" | awk -F", " '{print $2}')
exe_apps_count=$(echo $exe_apps | wc -l)
if [ "$exe_apps_count" -gt 1 ]; then
  selected_app=$(echo $exe_apps | fzf +m --prompt "Apps > " --bind "alt-h:abort,alt-l:accept,left:abort,right:accept,alt-j:down,alt-k:up,alt-c:abort,ESC:abort")
else
  if [ -n "$exe_apps" ]; then
    selected_app=$exe_apps
  else
    selected_app="vim"
  fi
fi
if [ -n "$selected_app" ]; then
  "$selected_app" "$selected_file"
fi
