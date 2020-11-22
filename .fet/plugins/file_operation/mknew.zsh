#!/bin/zsh
echo '0' >| ~/.fet/.status/.file_operation_mknew.status
echo "Make dir or file.\nPlease write new dir or file name. (If last char is /, make dir.)"
local input_new_mkname=''
trap 'return' SIGINT
vared input_new_mkname;
input_new_mkname=$(echo $input_new_mkname | grep -v -E "^/")
if [ -n "$input_new_mkname" ]; then
  local _fet_var_check_file_dir=$(echo $input_new_mkname | grep -E "/$")
  if [ -n "$_fet_var_check_file_dir" ]; then
    mkdir $_fet_var_check_file_dir
  else;
    touch $input_new_mkname
  fi
fi
