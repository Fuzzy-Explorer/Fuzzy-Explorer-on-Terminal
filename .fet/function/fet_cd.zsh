#!/bin/zsh
_fet_path_previous_dirs+=($PWD)
_fet_path_following_dirs=()
function chpwd() {}
cd "$_fet_path_selected_path"
function chpwd() {lsi ././}
