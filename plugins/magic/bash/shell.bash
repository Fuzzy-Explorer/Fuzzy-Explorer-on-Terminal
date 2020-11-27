#!/bin/bash
echo "$_fet_colorcode_yellow"'Please write command...'"$_fet_colorcode_end"
_fet_var_cmd='';
trap 'return' SIGINT
read -p "cmd > " _fet_var_cmd;
_fet_path_previous_dirs+=($PWD)
_fet_path_following_dirs=()
function chpwd() {
  :
}
eval "$_fet_var_cmd"
function chpwd() {
  lsi ././
}
