# ファイルを選択したときに呼ばれる関数（ファイル実行）
function _fzt_explorer_func_exec() {
  local _fzt_explorer_var_extensions_table=$(cat ~/.fzt_explorer/extensions.setting)
  local _fzt_explorer_var_apps=$(echo $_fzt_explorer_var_extensions_table | grep -E "^${@##*.}" | awk -F", " '{print $2}')
  local _fzt_explorer_var_apps_count=$(echo $_fzt_explorer_var_apps | wc -l)
  if [ $_fzt_explorer_var_apps_count -gt 1 ]; then
    local _fzt_explorer_var_selected_app=$(echo $_fzt_explorer_var_apps | fzf +m --prompt "Apps > " --bind "alt-h:abort,alt-l:accept,left:abort,right:accept,alt-j:down,alt-k:up,alt-c:abort,ESC:abort")
  else;
    if [ -n "$_fzt_explorer_var_apps" ]; then
      local _fzt_explorer_var_selected_app=$_fzt_explorer_var_apps
    else;
      local _fzt_explorer_var_selected_app="vim"
    fi
  fi
  if [ -n "$_fzt_explorer_var_selected_app" ]; then
    "$_fzt_explorer_var_selected_app" $@
  fi
}

# ファイルヤンク
function _fzt_explorer_func_yank() {
  echo '0' >| ~/.fzt_explorer/.status/.yank.status
  _fzt_explorer_var_yank_content=$PWD/$_fzt_explorer_var_selected_path
  echo $PWD/$_fzt_explorer_var_selected_path | win32yank.exe -i
  echo "yank complete $_fzt_explorer_var_yank_content"
}

# ファイルペースト
function _fzt_explorer_func_paste() {
  echo '0' >| ~/.fzt_explorer/.status/.paste.status
  if [ $_fzt_explorer_var_yank_content = '' ]; then
  else;
    cp -ri "$_fzt_explorer_var_yank_content" "$PWD/"
    echo "paste complete $_fzt_explorer_var_yank_content -> $PWD/"
  fi
}

# ファイル削除
function _fzt_explorer_func_delete() {
  echo '0' >| ~/.fzt_explorer/.status/.delete.status
  rm -ri $PWD/$_fzt_explorer_var_selected_path
}

# ファイル名リネーム
function _fzt_explorer_func_rename() {
  echo '0' >| ~/.fzt_explorer/.status/.rename.status
  echo "please write new name of '$_fzt_explorer_var_selected_path'"
  local _fzt_explorer_var_newname=$_fzt_explorer_var_selected_path;
  trap 'return' SIGINT
  vared _fzt_explorer_var_newname;
  local _fzt_explorer_var_check_not_include_slash=$(echo $_fzt_explorer_var_newname | grep '/')
  if [ -n "$_fzt_explorer_var_check_not_include_slash" ]; then
    echo "Including '/' is not valid."
  else;
    mv -iT "$PWD/$_fzt_explorer_var_selected_path" "$PWD/$_fzt_explorer_var_newname"
  fi
}

# アプリを指定して開く
function _fzt_explorer_func_open() {
  echo '0' >| ~/.fzt_explorer/.status/.open.status
  echo 'please write command...'
  local _fzt_explorer_var_cmd='';
  trap 'return' SIGINT
  vared _fzt_explorer_var_cmd;
  "$_fzt_explorer_var_cmd" $_fzt_explorer_var_selected_path
}

# mkdiriの関数
function _fzt_explorer_func_description() {
  echo '0' >| ~/.fzt_explorer/.status/.description.status
  if (test -d $_fzt_explorer_var_selected_path); then
    vim "$_fzt_explorer_var_selected_path/.description.lsi"
  else;
    if [ -e "$PWD/.file_description.lsi" ]; then
      local _fzt_explorer_var_exist_file_desc=$(cat "$PWD/.file_description.lsi" | grep "^\\\\/$_fzt_explorer_var_selected_path")
      if [ -n "$_exist_file_desc" ]; then
      else;
        mkdiri -f "$PWD/$_fzt_explorer_var_selected_path" "DESCRIPTION"
      fi
    else;
      mkdiri -f "$PWD/$_fzt_explorer_var_selected_path" "DESCRIPTION"
    fi
    vim "$PWD/.file_description.lsi" -c /$_fzt_explorer_var_selected_path
  fi
}

# 新しくファイルかディレクトリを作る
function _fzt_explorer_func_mknew() {
  echo '0' >| ~/.fzt_explorer/.status/.mknew.status
  echo "Make dir or file.\nPlease write new dir or file name. (If last char is /, make dir.)"
  local _fzt_explorer_var_new_mk_name=''
  trap 'return' SIGINT
  vared _fzt_explorer_var_new_mk_name;
  _fzt_explorer_var_new_mk_name=$(echo $_fzt_explorer_var_new_mk_name | grep -v -E "^/")
  if [ -n "$_fzt_explorer_var_new_mk_name" ]; then
    local _fzt_explorer_var_check_file_dir=$(echo $_fzt_explorer_var_new_mk_name | grep -E "/$")
    if [ -n "$_fzt_explorer_var_check_file_dir" ]; then
      mkdir $_fzt_explorer_var_check_file_dir
    else;
      touch $_fzt_explorer_var_new_mk_name
    fi
  fi
}

