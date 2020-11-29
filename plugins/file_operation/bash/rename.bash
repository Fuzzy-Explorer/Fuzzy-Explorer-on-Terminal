#!/bin/bash
echo "$_fet_colorcode_yellow""Please write new name of '$_fet_path_selected_path'""$_fet_colorcode_end"
input_newname=$_fet_path_selected_path;
trap 'return' SIGINT
read -p "NEW NAME > " input_newname;
check_not_include_slash=$(echo $input_newname | grep '/')
if [ -n "$check_not_include_slash" ]; then
  echo "Including '/' is not valid."
else
  mv -iT "$PWD/$_fet_path_selected_path" "$PWD/$input_newname"
fi
