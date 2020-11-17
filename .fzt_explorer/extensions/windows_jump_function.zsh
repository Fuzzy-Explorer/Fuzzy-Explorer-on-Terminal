# ウィンドウズのディレクトリへのショートカット
alias win='_fzt_explorer_func_windows_shortcut'
function _fzt_explorer_func_windows_shortcut() {
  local dir=""
  local -A pathes 
  IFS=$'\n'
  for _dict in `cat ~/.fzt_explorer/windows_shortcut.setting`
  do
    local _key=$(echo $_dict | awk -F", *" '{print $1}' )
    local _value=$(echo $_dict | awk -F", *" '{print $2}' )
    pathes[$_key]=$_value
  done
  for key in ${(k)pathes}; do
    dir="$key\n$dir"
  done
  dir=$(echo $dir |fzf +m --prompt="Dir > ")
  if [ -n "$dir" ]; then
    cd $pathes[$dir]
  fi
}
