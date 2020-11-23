#!/bin/zsh
echo '0' >| ~/.fet/.status/.functions_redocd.status
local following_dirs_num="${#_fet_path_following_dirs[@]}"
if [ $following_dirs_num -gt 0 ]; then
  _fet_path_selected_path=${_fet_path_following_dirs[$following_dirs_num]}
  _fet_path_following_dirs=(${_fet_path_following_dirs[1,-2]})
  if [ -n "$_fet_path_selected_path" ]; then
    _fet_path_previous_dirs+=($PWD)
    function chpwd() {}
    cd $_fet_path_selected_path
    function chpwd() {lsi ././}
  fi
fi
