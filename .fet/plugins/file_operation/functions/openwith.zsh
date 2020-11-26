#!/bin/zsh
echo 'please write command...'
local input_cmd='';
trap 'return' SIGINT
vared input_cmd;
"$input_cmd" $_fet_path_selected_path
