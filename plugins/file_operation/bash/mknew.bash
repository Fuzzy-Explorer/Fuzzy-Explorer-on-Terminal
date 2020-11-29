#!/bin/bash
echo "Make dir or file."
echo "$_fet_colorcode_yellow""Please write new dir or file name.$_fet_colorcode_end (If last char is /, make dir.)"
input_new_mkname=''
trap 'return' SIGINT
read -p "NAME > " input_new_mkname;
input_new_mkname=$(echo $input_new_mkname | grep -v -E "^/")
if [ -n "$input_new_mkname" ]; then
  _fet_var_check_file_dir=$(echo $input_new_mkname | grep -E "/$")
  if [ -n "$_fet_var_check_file_dir" ]; then
    mkdir $_fet_var_check_file_dir
  else
    touch $input_new_mkname
  fi
fi
