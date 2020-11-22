#!/bin/zsh
echo '0' >| ~/.fet/.status/.quickaccess.status
while :
do
  local -A _fet_var_quickaccess_pathes=()
  local _fet_quickaccess_name=""
  IFS=$'\n'
  for _dict in `cat ~/.fet/quickaccess.setting`
  do
    local _key=$(echo $_dict | awk -F", *" '{print $1}' )
    local _value=$(echo $_dict | awk -F", *" '{print $2}' )
    _key="$_key"
    if [ -d $_value ]; then
      _fet_quickaccess_name="\033[36m\uf07b:   dir\033[0m\t$_key\n$_fet_quickaccess_name"
    elif [ -f $_value ]; then
      _fet_quickaccess_name="\033[33m\uf15c:  file\033[0m\t$_key\n$_fet_quickaccess_name"
    else;
      _fet_quickaccess_name="\uf127\033[1;30m:broken\033[0m\t$_key\n$_fet_quickaccess_name"
    fi
    _fet_var_quickaccess_pathes[$_key]=$_value
  done
  _fet_quickaccess_name=$(echo $_fet_quickaccess_name | fzf --ansi +m --prompt="QuickAccess > " --bind="DEL:execute-silent(echo '1' >| ~/.fet/.status/.delete_quickaccess.status)+accept,alt-h:abort,alt-j:down,alt-k:up,alt-l:accept,alt-c:abort,ESC:abort")
  _fet_quickaccess_name=$(echo $_fet_quickaccess_name | awk -F"\t" '{print $2}' )
  local _fet_var_delete_quickaccess=$(cat ~/.fet/.status/.delete_quickaccess.status)
  if [ $_fet_var_delete_quickaccess = '1' ]; then
    echo '0' >| ~/.fet/.status/.delete_quickaccess.status
    echo "do you want to delete '$_fet_quickaccess_name'? (y/n)"
    read -r;
    if [ "$REPLY" = "y" ]; then
      _fet_func_delete_quickaccess
    fi
  else;
    if [ -n $_fet_quickaccess_name ]; then
      if [ -d $_fet_var_quickaccess_pathes[$_fet_quickaccess_name] ]; then
        function chpwd() {}
        _fet_path_previous_dirs+=($PWD)
        _fet_path_following_dirs=()
        cd $_fet_var_quickaccess_pathes[$_fet_quickaccess_name]
        function chpwd() {lsi ././}
        break
      elif [ -f $_fet_var_quickaccess_pathes[$_fet_quickaccess_name] ]; then
        _fet_func_exec $_fet_var_quickaccess_pathes[$_fet_quickaccess_name]
        break
      else;
        echo "no such file or directory. ($_fet_var_quickaccess_pathes[$_fet_quickaccess_name])"
        echo "do yo want to delete quickaccess:'$_fet_quickaccess_name'? (y/n)"
        read -r;
        if [ "$REPLY" = "y" ]; then
          _fet_func_delete_quickaccess
        fi
      fi
    fi
  fi
done
