#!/bin/zsh
# echo '0' >| ~/.fet/.status/.file_operation_openwith.status
echo 'please write command...'
local input_cmd='';
trap 'return' SIGINT
vared input_cmd;
"$input_cmd" $_fet_path_selected_path
