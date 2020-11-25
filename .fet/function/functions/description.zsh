#!/bin/zsh
# echo '0' >| ~/.fet/.status/.functions_description.status
if (test -d $_fet_path_selected_path); then
  vim "$_fet_path_selected_path/.description.lsi"
else;
  if [ -e "$PWD/.file_description.lsi" ]; then
    local exists_file_desc=$(cat "$PWD/.file_description.lsi" | grep "^\\\\/$_fet_path_selected_path")
    if [ -n "$exists_file_desc" ]; then
    else;
      mkdiri -f "$PWD/$_fet_path_selected_path" "DESCRIPTION"
    fi
  else;
    mkdiri -f "$PWD/$_fet_path_selected_path" "DESCRIPTION"
  fi
  vim "$PWD/.file_description.lsi" -c /$_fet_path_selected_path
fi
