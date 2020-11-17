# コマンド実行モード
function _fzt_explorer_func_shell() {
  echo '0' >| ~/.fzt_explorer/.status/.shell.status
  echo 'please write command...'
  local _fzt_explorer_var_cmd='';
  trap 'return' SIGINT
  vared _fzt_explorer_var_cmd;
  _fzt_explorer_var_previous_dirs+=($PWD)
  _fzt_explorer_var_following_dirs=()
  function chpwd() {}
  eval "$_fzt_explorer_var_cmd"
  function chpwd() {lsi ././}
}

# READMEを表示
function _fzt_explorer_func_hint() {
  echo '0' >| ~/.fzt_explorer/.status/.hint.status
  vim ~/.fzt_explorer/ReadMe -c ":set readonly"
}
