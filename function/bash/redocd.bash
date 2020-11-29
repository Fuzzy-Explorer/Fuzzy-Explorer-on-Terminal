#!/bin/bash
following_dirs_num="${#_fet_path_following_dirs[@]}"
if [ "$following_dirs_num" -gt 0 ]; then
  _fet_path_selected_path=${_fet_path_following_dirs[$(expr $following_dirs_num - 1)]}
  unset _fet_path_following_dirs[$(expr $following_dirs_num - 1)]
  _fet_path_following_dirs=(${_fet_path_following_dirs[@]})
  if [ -n "$_fet_path_selected_path" ]; then
    _fet_path_previous_dirs+=($PWD)
    function chpwd() {
      :
    }
    cd $_fet_path_selected_path
    function chpwd() {
      lsi ././
    }
  fi
fi
