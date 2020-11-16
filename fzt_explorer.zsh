alias fe='_fzt_explorer'
function _fzt_explorer() {
  # クイックアクセス　作成時か削除時かctrl-cするとホームに飛ぶ
  # クイックアクセス　リネーム欲しい
  setopt +o nomatch
  # ↓ここに実装する機能の名前を列挙する（forでステータス変数／ファイルが作成される）
  local _fzt_explorer_var_status_list=(endloop yank paste delete open undocd redocd shell hidden goup description hint rename mknew quickaccess register_quickaccess delete_quickaccess goto)
  # ステータスファイル初期化
  for var in $_fzt_explorer_var_status_list
  do
    echo '0' >| ~/.fzt_explorer/.status/.$var.status
  done
  echo >| ~/.fzt_explorer/.status/.hidden.status
  # 変数宣言
  _fzt_explorer_var_yank_content=''
  _fzt_explorer_var_previous_dirs=()
  _fzt_explorer_var_following_dirs=()
  local _fzt_explorer_var_keybindings=$(cat ~/.fzt_explorer/keybindings.setting | tr '\n' ',' | sed 's/,$//')
  # 引数を調べる
  if [ $# -gt 0 ]; then
    if [ -d "$@" ]; then
      _fzt_explorer_var_selected_path="$@"
      _fzt_explorer_func_change_directory
    fi
  fi
  while :
  do # -------------ループ開始------------- #
    # 隠しディレクトリ表示の判定
    local _fzt_explorer_var_hidden=$(( $(cat ~/.fzt_explorer/.status/.hidden.status | wc -l) % 2 ))
    # ディレクトリ一覧の取得
    if [ $_fzt_explorer_var_hidden -eq 1 ]; then
      local _fzt_explorer_var_dir_list="../\n`lsi`"
    else;
      local _fzt_explorer_var_dir_list="../\n`lsi -a`"
    fi
    # fzfでのディレクトリの選択
    local _fzt_explorer_var_selected_path=$(echo $_fzt_explorer_var_dir_list | fzf --height 50% --preview-window right:40% --ansi +m --prompt="$PWD >" --bind "$_fzt_explorer_var_keybindings" --preview="echo {} | cut -f 2 -d ' ' | xargs -rI{a} sh -c 'if [ -f \"{a}\" ]; then ls -ldhG {a}; batcat {a} --color=always --style=grid --line-range :100; else ls -ldhG {a}; echo; lsi {a}; fi'")
    # local _fzt_explorer_var_selected_path=$(echo $_fzt_explorer_var_dir_list | fzf --height 50% --preview-window right:40% --ansi +m --prompt="$PWD >" --bind "$_fzt_explorer_var_keybindings" --preview="echo {} | cut -f 2 -d ' ' | xargs -rI{a} sh -c 'if [ -f \"{a}\" ]; then ls -ldhG {a}; richcat {a} -w 30; else ls -ldhG {a}; echo; lsi {a}; fi'")
    _fzt_explorer_var_endloop=$(cat ~/.fzt_explorer/.status/.endloop.status)
    # 動作の分岐
    if [ $_fzt_explorer_var_endloop = '0' ]; then
      # 選択したファイルの文字列を整形する（../はそのまま）
      if [ "$_fzt_explorer_var_selected_path" = '../' ]; then
      else;
        _fzt_explorer_var_selected_path=`echo $_fzt_explorer_var_selected_path | sed 's/\x1b\[[0-9;]*m//g' | awk -F"── " '{print $2}' | awk -F" / " '{print $1}'`
      fi
      # 全ステータス読み込み
      for var in $_fzt_explorer_var_status_list
      do
        local _fzt_explorer_var_$var=$(cat ~/.fzt_explorer/.status/.$var.status)
      done
      # 上にいくか，その場でとどまるかを制御
      if [ -n "$_fzt_explorer_var_selected_path" ]; then
      elif [ "$_fzt_explorer_var_goup" = '0' ]; then
        _fzt_explorer_var_selected_path="./"
      elif [ "$_fzt_explorer_var_goup" = '1' ]; then
        echo '0' >| ~/.fzt_explorer/.status/.goup.status
        _fzt_explorer_var_selected_path="../"
      fi
      # キーバインドの関数実行
      if [ $_fzt_explorer_var_yank = '1' ]; then
        _fzt_explorer_func_yank
      elif [ $_fzt_explorer_var_paste = '1' ]; then
        _fzt_explorer_func_paste
      elif [ $_fzt_explorer_var_delete = '1' ]; then
        _fzt_explorer_func_delete
      elif [ $_fzt_explorer_var_rename = '1' ]; then
        _fzt_explorer_func_rename
      elif [ $_fzt_explorer_var_open = '1' ]; then
        _fzt_explorer_func_open
      elif [ $_fzt_explorer_var_undocd = '1' ]; then
        _fzt_explorer_func_undocd
      elif [ $_fzt_explorer_var_redocd = '1' ]; then
        _fzt_explorer_func_redocd
      elif [ $_fzt_explorer_var_shell = '1' ]; then
        _fzt_explorer_func_shell
      elif [ $_fzt_explorer_var_description = '1' ]; then
        _fzt_explorer_func_description
      elif [ $_fzt_explorer_var_hint = '1' ]; then
        _fzt_explorer_func_hint
      elif [ $_fzt_explorer_var_mknew = '1' ]; then
        _fzt_explorer_func_mknew
      elif [ $_fzt_explorer_var_quickaccess = '1' ]; then
        _fzt_explorer_func_quickaccess
      elif [ $_fzt_explorer_var_register_quickaccess = '1' ]; then
        _fzt_explorer_func_register_quickaccess
      elif [ $_fzt_explorer_var_goto = '1' ]; then
        _fzt_explorer_func_goto
      else;
        if (test -d $_fzt_explorer_var_selected_path); then
          _fzt_explorer_func_change_directory
        else;
          _fzt_explorer_func_exec $_fzt_explorer_var_selected_path
        fi
      fi
    else;
      break
    fi
  done
  _fzt_explorer_func_destruction
  lsi ././
}

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

# ディレクトリを選択したときに呼ばれる関数（ディレクトリ移動）
function _fzt_explorer_func_change_directory() {
  _fzt_explorer_var_previous_dirs+=($PWD)
  _fzt_explorer_var_following_dirs=()
  function chpwd() {}
  cd $_fzt_explorer_var_selected_path
  function chpwd() {lsi ././}
}

# メモリ開放
function _fzt_explorer_func_destruction() {
  unset _fzt_explorer_var_selected_path
  unset _fzt_explorer_var_previous_dirs
  unset _fzt_explorer_var_following_dirs
  unset _fzt_explorer_var_yank_content
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

# READMEを表示
function _fzt_explorer_func_hint() {
  echo '0' >| ~/.fzt_explorer/.status/.hint.status
  vim ~/.fzt_explorer/ReadMe -c ":set readonly"
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
