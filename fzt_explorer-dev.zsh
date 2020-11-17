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

# メモリ開放
function _fzt_explorer_func_destruction() {
  # https://befool.co.jp/blog/jiska/bash-is-function-exists/
  unset _fzt_explorer_var_selected_path
  unset _fzt_explorer_var_previous_dirs
  unset _fzt_explorer_var_following_dirs
  unset _fzt_explorer_var_yank_content
}
