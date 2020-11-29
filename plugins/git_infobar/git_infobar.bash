#!/bin/bash
_fet_var_is_git_dir=$(git rev-parse --git-dir 2> /dev/null)
if [ -n "$_fet_var_is_git_dir" ]; then
  _fet_var_git_current_branch=$(echo $(git branch --show-current))
  _fet_var_git_diff=$(git status --short)
  _fet_var_git_status=''
  _fet_var_git_diff_committed=$(echo $(git log origin/$_fet_var_git_current_branch...$_fet_var_git_current_branch | grep "^commit" | wc -l))
  if [ $_fet_var_git_diff_committed -gt 0 ]; then
    _fet_var_git_status=$_fet_var_git_status"$_fet_colorcode_green"'↑'"$_fet_var_git_diff_committed""$_fet_colorcode_end"
  fi
  if [ -n "$_fet_var_git_diff" ]; then
    _fet_var_git_diff_untrack=$(echo $_fet_var_git_diff | grep "^??" | wc -l)
    _fet_var_git_diff_mod=$(echo $_fet_var_git_diff | grep -e "^ M" -e "^ D" | wc -l)
    _fet_var_git_diff_added=$(echo $_fet_var_git_diff | grep -e "^M " -e "^D "| wc -l)
    if [ $_fet_var_git_diff_added -gt 0 ]; then
      _fet_var_git_status="$_fet_var_git_status""$_fet_colorcode_green"+"$_fet_var_git_diff_added""$_fet_colorcode_end"
    fi
    if [ $_fet_var_git_diff_mod -gt 0 ]; then
      _fet_var_git_status="$_fet_var_git_status""$_fet_colorcode_yellow"!"$_fet_var_git_diff_mod""$_fet_colorcode_end"
    fi
    if [ $_fet_var_git_diff_untrack -gt 0 ]; then
      _fet_var_git_status="$_fet_var_git_status""$_fet_colorcode_red"?"$_fet_var_git_diff_untrack""$_fet_colorcode_end"
    fi
  fi
  _fet_var_git_current_branch="$(echo 'GIT'  $_fet_var_git_current_branch $_fet_var_git_status)"
else
  _fet_var_git_current_branch=''
fi
echo -e "$_fet_var_git_current_branch"
