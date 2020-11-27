#!/bin/bash
selected_dir=''
if [ $# -gt 0 ]; then
  selected_dir="$@"
else
  selected_dir="$_fet_path_selected_path"
fi
_fet_path_previous_dirs+=($PWD)
_fet_path_following_dirs=()
function chpwd() {
  :
}
cd "$selected_dir"
function chpwd() {
  lsi ././
}
