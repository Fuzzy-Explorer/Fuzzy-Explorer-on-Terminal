#!/bin/bash
_fet_var_yank_content=$PWD/$_fet_path_selected_path
_fet_var_cut_content=''
has_win32yank=$(which win32yank.exe)
if [ -n "$has_win32yank" ]; then
  echo $PWD/$_fet_path_selected_path | win32yank.exe -i
fi
echo "$_fet_colorcode_yellow""yank complete""$_fet_colorcode_end" "$_fet_var_yank_content"

