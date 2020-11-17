# ディレクトリを選択したときに呼ばれる関数（ディレクトリ移動）
function _fzt_explorer_func_change_directory() {
  _fzt_explorer_var_previous_dirs+=($PWD)
  _fzt_explorer_var_following_dirs=()
  function chpwd() {}
  cd $_fzt_explorer_var_selected_path
  function chpwd() {lsi ././}
}

# 戻る
function _fzt_explorer_func_undocd() {
  echo '0' >| ~/.fzt_explorer/.status/.undocd.status
  local _fzt_explorer_var_previous_dirs_num="${#_fzt_explorer_var_previous_dirs[@]}"
  if [ $_fzt_explorer_var_previous_dirs_num -gt 0 ]; then
    _fzt_explorer_var_selected_path=${_fzt_explorer_var_previous_dirs[$_fzt_explorer_var_previous_dirs_num]}
    unset _fzt_explorer_var_previous_dirs[$_fzt_explorer_var_previous_dirs_num]
    _fzt_explorer_var_previous_dirs=(${_fzt_explorer_var_previous_dirs[@]})
    if [ -n "$_fzt_explorer_var_selected_path" ]; then
      _fzt_explorer_var_following_dirs+=($PWD)
      function chpwd() {}
      cd $_fzt_explorer_var_selected_path
      function chpwd() {lsi ././}
    fi
  fi
}

# 進む
function _fzt_explorer_func_redocd() {
  echo '0' >| ~/.fzt_explorer/.status/.redocd.status
  local _fzt_explorer_var_following_dirs_num="${#_fzt_explorer_var_following_dirs[@]}"
  if [ $_fzt_explorer_var_following_dirs_num -gt 0 ]; then
    _fzt_explorer_var_selected_path=${_fzt_explorer_var_following_dirs[$_fzt_explorer_var_following_dirs_num]}
    unset _fzt_explorer_var_following_dirs[$_fzt_explorer_var_following_dirs_num]
    _fzt_explorer_var_following_dirs=(${_fzt_explorer_var_following_dirs[@]})
    if [ -n "$_fzt_explorer_var_selected_path" ]; then
      _fzt_explorer_var_previous_dirs+=($PWD)
      function chpwd() {}
      cd $_fzt_explorer_var_selected_path
      function chpwd() {lsi ././}
    fi
  fi
}

# GoTo（パスジャンプ）
function _fzt_explorer_func_goto() {
  echo '0' >| ~/.fzt_explorer/.status/.goto.status
  echo 'Please write Path or drag file/directory from Windows Explorer.'
  local _fzt_explorer_var_goto_path=''
  trap 'return' SIGINT
  vared _fzt_explorer_var_goto_path
  _fzt_explorer_var_goto_fzt_path=$(eval "echo $_fzt_explorer_var_goto_path")
  if [ -d "$_fzt_explorer_var_goto_fzt_path" ]; then
    function chpwd() {}
    cd "$_fzt_explorer_var_goto_fzt_path"
    function chpwd() {lsi ././}
  else;
    local _fzt_explorer_var_goto_win_path=$(eval 'fztpath -u "$_fzt_explorer_var_goto_path"')
    if [ -d "$_fzt_explorer_var_goto_win_path" ]; then
      function chpwd() {}
      cd "$_fzt_explorer_var_goto_win_path"
      function chpwd() {lsi ././}
    else;
      echo 'no such directory.'
    fi
  fi
}
