#!/bin/zsh
if (test -d $_fet_path_selected_path); then
  if [ -f "$_fet_path_selected_path/.description.lsi" ]; then
    vim "$_fet_path_selected_path/.description.lsi"
  else
    echo "Dir" >| "$_fet_path_selected_path/.description.lsi"
    vim "$_fet_path_selected_path/.description.lsi"
  fi
else;
  if [ -e "$PWD/.file_description.lsi" ]; then
    local exists_file_desc=$(cat "$PWD/.file_description.lsi" | grep "^\\\\/$_fet_path_selected_path")
    if [ -n "$exists_file_desc" ]; then
    else;
      mkdiri -f "$PWD/$_fet_path_selected_path" "File"
    fi
  else;
    mkdiri -f "$PWD/$_fet_path_selected_path" "File"
  fi
  vim "$PWD/.file_description.lsi" -c /$_fet_path_selected_path
fi
