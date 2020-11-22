#!/bin/zsh
echo '0' >| ~/.fet/.status/.magic_shell.status
echo 'please write command...'
local _fet_var_cmd='';
trap 'return' SIGINT
vared _fet_var_cmd;
_fet_path_previous_dirs+=($PWD)
_fet_path_following_dirs=()
function chpwd() {}
eval "$_fet_var_cmd"
function chpwd() {lsi ././}
