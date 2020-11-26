#!/bin/zsh
local _fet_var_is_git_dir=$(git rev-parse --git-dir 2> /dev/null)
if [ -n "$_fet_var_is_git_dir" ]; then
  local _fet_var_git_current_branch=$(echo $(git branch --show-current))
  local _fet_var_git_diff=$(git status --short)
  local _fet_var_git_status=''
  local _fet_var_git_diff_committed=$(echo $(git log origin/$_fet_var_git_current_branch...$_fet_var_git_current_branch | grep "^commit" | wc -l))
  if [ $_fet_var_git_diff_committed -gt 0 ]; then
    _fet_var_git_status=$_fet_var_git_status'\033[1;32m\uf148'"$_fet_var_git_diff_committed"'\033[0m'
  fi
  if [ -n "$_fet_var_git_diff" ]; then
    local _fet_var_git_diff_untrack=$(echo $_fet_var_git_diff | grep "^??" | wc -l)
    local _fet_var_git_diff_mod=$(echo $_fet_var_git_diff | grep -e "^ M" -e "^ D" | wc -l)
    local _fet_var_git_diff_added=$(echo $_fet_var_git_diff | grep -e "^M " -e "^D "| wc -l)
    if [ $_fet_var_git_diff_added -gt 0 ]; then
      _fet_var_git_status=$_fet_var_git_status'\033[1;32m+'"$_fet_var_git_diff_added"'\033[0m'
    fi
    if [ $_fet_var_git_diff_mod -gt 0 ]; then
      _fet_var_git_status=$_fet_var_git_status'\033[1;33m!'"$_fet_var_git_diff_mod"'\033[0m'
    fi
    if [ $_fet_var_git_diff_untrack -gt 0 ]; then
      _fet_var_git_status=$_fet_var_git_status'\033[1;31m?'"$_fet_var_git_diff_untrack"'\033[0m'
    fi
  fi
  _fet_var_git_current_branch=$(echo '\uf1d3'  $_fet_var_git_current_branch $_fet_var_git_status)
else
  _fet_var_git_current_branch=''
fi
echo $_fet_var_git_current_branch
