#!/bin/bash
echo '0' >| ~/.fet/.status/.quickaccess_delete_quickaccess.status
while :
do
  declare -A _fet_var_quickaccess_pathes=()
  _fet_quickaccess_name=""
  IFS=$'\n'
  if [ -f "~/.fet/user/data/quickaccess.csv" ]; then
    :
  else
    touch ~/.fet/user/data/quickaccess.csv
  fi
  for _dict in `cat ~/.fet/user/data/quickaccess.csv`
  do
    _key=$(echo $_dict | awk -F", *" '{print $1}' )
    _value=$(echo $_dict | awk -F", *" '{print $2}' )
    _key="$_key"
    if [ -d $_value ]; then
      _fet_quickaccess_name="\033[36m\uf07b:   dir\033[0m\t$_key\n$_fet_quickaccess_name"
    elif [ -f $_value ]; then
      _fet_quickaccess_name="\033[33m\uf15c:  file\033[0m\t$_key\n$_fet_quickaccess_name"
    else
      _fet_quickaccess_name="\uf127\033[1;30m:broken\033[0m\t$_key\n$_fet_quickaccess_name"
    fi
    _fet_var_quickaccess_pathes[$_key]=$_value
  done
  _fet_quickaccess_name=$(echo $_fet_quickaccess_name | grep -v '^\s*$')
  _fet_quickaccess_name=$(echo -e "$_fet_quickaccess_name" | fzf --cycle --height 70% --info='inline' --layout=reverse --border --ansi +m --prompt="QuickAccess > " --bind="DEL:execute-silent(echo '1' >| ~/.fet/.status/.quickaccess_delete_quickaccess.status)+accept,alt-h:abort,alt-j:down,alt-k:up,alt-l:accept,alt-c:abort,ESC:abort,left:abort,down:down,up:up,right:accept")
  _fet_quickaccess_name=$(echo $_fet_quickaccess_name | awk -F"\t" '{print $2}' )
  _fet_var_delete_quickaccess=$(cat ~/.fet/.status/.quickaccess_delete_quickaccess.status)
  if [ "$_fet_var_delete_quickaccess" = '1' ]; then
    echo "$_fet_colorcode_yellow""Do you want to delete quickaccess""$_fet_colorcode_end""='$_fet_quickaccess_name'?$_fet_colorcode_end ($_fet_colorcode_green"'y'"$_fet_colorcode_end"'/'"$_fet_colorcode_red"'n'"$_fet_colorcode_end"')'
    read -r;
    if [ "$REPLY" = "y" ]; then
      . ~/.fet/plugins/quickaccess/functions/delete_quickaccess.bash
    else
      echo '0' >| ~/.fet/.status/.quickaccess_delete_quickaccess.status
    fi
  else
    if [ -n "$_fet_quickaccess_name" ]; then
      if [ -d "$_fet_var_quickaccess_pathes[$_fet_quickaccess_name]" ]; then
        . ~/.fet/function/cd.bash $_fet_var_quickaccess_pathes[$_fet_quickaccess_name]
        break
      elif [ -f $_fet_var_quickaccess_pathes[$_fet_quickaccess_name] ]; then
        . ~/.fet/function/execute.bash $_fet_var_quickaccess_pathes[$_fet_quickaccess_name]
        break
      else
        echo "no such file or directory. ($_fet_var_quickaccess_pathes[$_fet_quickaccess_name])"
        echo "$_fet_colorcode_yellow""Do you want to delete quickaccess""$_fet_colorcode_end""='$_fet_quickaccess_name'?$_fet_colorcode_end ($_fet_colorcode_green"'y'"$_fet_colorcode_end"'/'"$_fet_colorcode_red"'n'"$_fet_colorcode_end"')'
        read -r;
        if [ "$REPLY" = "y" ]; then
          . ~/.fet/plugins/quickaccess/functions/delete_quickaccess.bash
        else
          echo '0' >| ~/.fet/.status/.quickaccess_delete_quickaccess.status
        fi
      fi
    else
      break
    fi
  fi
done
