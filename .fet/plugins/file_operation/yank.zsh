#!/bin/zsh
echo '0' >| ~/.fet/.status/.yank.status
_fet_var_yank_content=$PWD/$_fet_path_selected_path
local has_win32yank=$(which win32yank.exe)
if [ -n $has_win32yank ]; then
  echo $PWD/$_fet_path_selected_path | win32yank.exe -i
fi
echo "yank complete $_fet_var_yank_content"

