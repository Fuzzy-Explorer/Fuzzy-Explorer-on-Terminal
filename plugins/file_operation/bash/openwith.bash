#!/bin/bash
echo "$_fet_colorcode_yellow"'Please write command...'"$_fet_colorcode_end"
input_cmd='';
trap 'return' SIGINT
read -p "cmd > " input_cmd
"$input_cmd" $_fet_path_selected_path
