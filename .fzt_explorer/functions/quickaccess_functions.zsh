# クイックアクセス
function _fzt_explorer_func_quickaccess() {
  echo '0' >| ~/.fzt_explorer/.status/.quickaccess.status
  while :
  do
    local -A _fzt_explorer_var_quickaccess_pathes=()
    local _fzt_explorer_quickaccess_name=""
    IFS=$'\n'
    for _dict in `cat ~/.fzt_explorer/quickaccess.setting`
    do
      local _key=$(echo $_dict | awk -F", *" '{print $1}' )
      local _value=$(echo $_dict | awk -F", *" '{print $2}' )
      _key="$_key"
      if [ -d $_value ]; then
        _fzt_explorer_quickaccess_name="\033[36m\uf07b:   dir\033[0m\t$_key\n$_fzt_explorer_quickaccess_name"
      elif [ -f $_value ]; then
        _fzt_explorer_quickaccess_name="\033[33m\uf15c:  file\033[0m\t$_key\n$_fzt_explorer_quickaccess_name"
      else;
        _fzt_explorer_quickaccess_name="\uf127\033[1;30m:broken\033[0m\t$_key\n$_fzt_explorer_quickaccess_name"
      fi
      _fzt_explorer_var_quickaccess_pathes[$_key]=$_value
    done
    _fzt_explorer_quickaccess_name=$(echo $_fzt_explorer_quickaccess_name | fzf --ansi +m --prompt="QuickAccess > " --bind="DEL:execute-silent(echo '1' >| ~/.fzt_explorer/.status/.delete_quickaccess.status)+accept,alt-h:abort,alt-j:down,alt-k:up,alt-l:accept,alt-c:abort,ESC:abort")
    _fzt_explorer_quickaccess_name=$(echo $_fzt_explorer_quickaccess_name | awk -F"\t" '{print $2}' )
    local _fzt_explorer_var_delete_quickaccess=$(cat ~/.fzt_explorer/.status/.delete_quickaccess.status)
    if [ $_fzt_explorer_var_delete_quickaccess = '1' ]; then
      echo '0' >| ~/.fzt_explorer/.status/.delete_quickaccess.status
      echo "do you want to delete '$_fzt_explorer_quickaccess_name'? (y/n)"
      read -r;
      if [ "$REPLY" = "y" ]; then
        _fzt_explorer_func_delete_quickaccess
      fi
    else;
      if [ -n $_fzt_explorer_quickaccess_name ]; then
        if [ -d $_fzt_explorer_var_quickaccess_pathes[$_fzt_explorer_quickaccess_name] ]; then
          function chpwd() {}
          cd $_fzt_explorer_var_quickaccess_pathes[$_fzt_explorer_quickaccess_name]
          function chpwd() {lsi ././}
          break
        elif [ -f $_fzt_explorer_var_quickaccess_pathes[$_fzt_explorer_quickaccess_name] ]; then
          _fzt_explorer_func_exec $_fzt_explorer_var_quickaccess_pathes[$_fzt_explorer_quickaccess_name]
          break
        else;
          echo "no such file or directory. ($_fzt_explorer_var_quickaccess_pathes[$_fzt_explorer_quickaccess_name])"
          echo "do yo want to delete quickaccess:'$_fzt_explorer_quickaccess_name'? (y/n)"
          read -r;
          if [ "$REPLY" = "y" ]; then
            _fzt_explorer_func_delete_quickaccess
          fi
        fi
      fi
    fi
  done
}

# クイックアクセスの登録
function _fzt_explorer_func_register_quickaccess() {
  echo '0' >| ~/.fzt_explorer/.status/.register_quickaccess.status
  echo 'Please write name of this quickaccess.'
  local name_of_qa=$_fzt_explorer_var_selected_path
  trap 'return' SIGINT
  vared name_of_qa
  name_of_qa=$(echo $name_of_qa | sed 's/,/_/' | sed 's/\t/ /')
  local -A pathes 
  IFS=$'\n'
  for _dict in `cat ~/.fzt_explorer/quickaccess.setting`
  do
    local _key=$(echo $_dict | awk -F", *" '{print $1}' )
    local _value=$(echo $_dict | awk -F", *" '{print $2}' )
    pathes[$_key]=$_value
  done
  pathes[$name_of_qa]=$PWD/$_fzt_explorer_var_selected_path
  echo >| ~/.fzt_explorer/quickaccess.setting
  for key in ${(k)pathes}; do
    echo "$key, ${pathes[$key]}" >> ~/.fzt_explorer/quickaccess.setting
  done
}

# クイックアクセスの削除
function _fzt_explorer_func_delete_quickaccess() {
  local -A pathes 
  IFS=$'\n'
  for _dict in `cat ~/.fzt_explorer/quickaccess.setting`
  do
    local _key=$(echo $_dict | awk -F", *" '{print $1}' )
    local _value=$(echo $_dict | awk -F", *" '{print $2}' )
    pathes[$_key]=$_value
  done
  echo >| ~/.fzt_explorer/quickaccess.setting
  for key in ${(k)pathes}; do
    local _virtual_key="$key"
    if [ $_fzt_explorer_quickaccess_name = $_virtual_key ]; then
    else;
      echo "$key, ${pathes[$key]}" >> ~/.fzt_explorer/quickaccess.setting
    fi
  done
}
