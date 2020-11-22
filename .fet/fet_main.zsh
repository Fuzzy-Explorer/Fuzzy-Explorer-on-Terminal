#!/bin/zsh
setopt +o nomatch
# ↓ここに実装する機能の名前を列挙する（forでステータス変数／ファイルが作成される）
local _fet_status_list=(endloop yank paste delete open undocd redocd shell hidden goup description help rename mknew quickaccess register_quickaccess delete_quickaccess goto)
# ステータスファイル初期化
for var in $_fet_status_list
do
  echo '0' >| ~/.fet/.status/.$var.status
done
echo >| ~/.fet/.status/.hidden.status
# 変数宣言
_fet_status_yank_content=''
_fet_path_previous_dirs=()
_fet_path_following_dirs=()
local _fet_var_keybindings=$(cat ~/.fet/keybindings.setting | tr '\n' ',' | sed 's/,$//')
# 引数を調べる
if [ $# -gt 0 ]; then
  if [ -d "$@" ]; then
    _fet_path_selected_path="$@"
    _fet_func_change_directory
  fi
fi
while :
do # -------------ループ開始------------- #
  # 隠しディレクトリ表示の判定
  local _fet_status_hidden=$(( $(cat ~/.fet/.status/.hidden.status | wc -l) % 2 ))
  # ディレクトリ一覧の取得
  if [ $_fet_status_hidden -eq 1 ]; then
    local _fet_path_path_list="../\n`lsi`"
  else;
    local _fet_path_path_list="../\n`lsi -a`"
  fi
  local _fet_var_promp=$(echo $PWD | sed -e "s:$HOME:~:")
  local _fet_var_is_git_dir=$(git rev-parse --git-dir 2> /dev/null)
  if [ -n "$_fet_var_is_git_dir" ]; then
    local _fet_var_git_current_branch=$(echo $(git branch --show-current))
    local _fet_var_git_diff=$(git status --short)
    local _fet_var_git_status=''
    local _fet_var_git_diff_committed=$(echo $(git log origin/$_fet_var_git_current_branch...$_fet_var_git_current_branch | grep "^commit" | wc -l))
    if [ $_fet_var_git_diff_committed -gt 0 ]; then
      _fet_var_git_status=$_fet_var_git_status'\033[1;32m\uf148'"$_fet_var_git_diff_committed"'\033[0m'
    fi
    if [ -n "$_fet_var_git_diff" ]; then
      local _fet_var_git_diff_untrack=$(echo $_fet_var_git_diff | grep "^??" | wc -l)
      local _fet_var_git_diff_mod=$(echo $_fet_var_git_diff | grep "^ M" | wc -l)
      local _fet_var_git_diff_added=$(echo $_fet_var_git_diff | grep "^M " | wc -l)
      if [ $_fet_var_git_diff_added -gt 0 ]; then
        _fet_var_git_status=$_fet_var_git_status'\033[1;32m+'"$_fet_var_git_diff_added"'\033[0m'
      fi
      if [ $_fet_var_git_diff_mod -gt 0 ]; then
        _fet_var_git_status=$_fet_var_git_status'\033[1;33m!'"$_fet_var_git_diff_mod"'\033[0m'
      fi
      if [ $_fet_var_git_diff_untrack -gt 0 ]; then
        _fet_var_git_status=$_fet_var_git_status'\033[1;31m?'"$_fet_var_git_diff_untrack"'\033[0m'
      fi
    fi
    _fet_var_git_current_branch=$(echo '\uf1d3'  $_fet_var_git_current_branch $_fet_var_git_status)
  fi
  # fzfでのディレクトリの選択
  local _fet_path_selected_path=$(echo $_fet_path_path_list | fzf --height 50% --preview-window right:40% --ansi +m --prompt="$_fet_var_promp >" --cycle --info="inline" --header="$_fet_var_git_current_branch" --bind "$_fet_var_keybindings" --preview="echo {} | cut -f 2 -d ' ' | xargs -rI{a} sh -c 'if [ -f \"{a}\" ]; then ls -ldhG {a}; batcat {a} --color=always --style=grid --line-range :100; else ls -ldhG {a}; echo; lsi {a}; fi'")
  _fet_status_endloop=$(cat ~/.fet/.status/.endloop.status)
  # 動作の分岐
  if [ $_fet_status_endloop = '0' ]; then
    # 選択したファイルの文字列を整形する（../はそのまま）
    if [ "$_fet_path_selected_path" = '../' ]; then
    else;
      _fet_path_selected_path=`echo $_fet_path_selected_path | sed 's/\x1b\[[0-9;]*m//g' | awk -F"── " '{print $2}' | awk -F" / " '{print $1}'`
    fi
    # 全ステータス読み込み
    for var in $_fet_status_list
    do
      local _fet_status_$var=$(cat ~/.fet/.status/.$var.status)
    done
    # 上にいくか，その場でとどまるかを制御
    if [ -n "$_fet_path_selected_path" ]; then
    elif [ "$_fet_status_goup" = '0' ]; then
      _fet_path_selected_path="./"
    elif [ "$_fet_status_goup" = '1' ]; then
      echo '0' >| ~/.fet/.status/.goup.status
      _fet_path_selected_path="../"
    fi
    # キーバインドの関数実行
    if [ $_fet_status_yank = '1' ]; then
      . ~/.fet/plugins/file_operation/yank.zsh
    elif [ $_fet_status_paste = '1' ]; then
      . ~/.fet/plugins/file_operation/paste.zsh
    elif [ $_fet_status_delete = '1' ]; then
      _fet_func_delete
    elif [ $_fet_status_rename = '1' ]; then
      _fet_func_rename
    elif [ $_fet_status_open = '1' ]; then
      _fet_func_open
    elif [ $_fet_status_undocd = '1' ]; then
      . ~/.fet/function/fet_undocd.zsh
    elif [ $_fet_status_redocd = '1' ]; then
      . ~/.fet/function/fet_redocd.zsh
    elif [ $_fet_status_shell = '1' ]; then
      _fet_func_shell
    elif [ $_fet_status_description = '1' ]; then
      . ~/.fet/function/description.zsh
    elif [ $_fet_status_help = '1' ]; then
      . ~/.fet/function/fet_help.zsh
    elif [ $_fet_status_mknew = '1' ]; then
      _fet_func_mknew
    elif [ $_fet_status_quickaccess = '1' ]; then
      _fet_func_quickaccess
    elif [ $_fet_status_register_quickaccess = '1' ]; then
      _fet_func_register_quickaccess
    elif [ $_fet_status_goto = '1' ]; then
      . ~/.fet/function/fet_goto.zsh
    else;
      if (test -d $_fet_path_selected_path); then
        . ~/.fet/function/fet_cd.zsh
      else;
        # vim "$_fet_path_selected_path"
        . ~/.fet/function/fet_execute.zsh
      fi
    fi
  else;
    break
  fi
done
_fet_func_destruction
lsi ././

# ウィンドウズのディレクトリへのショートカット
alias win='_fet_func_windows_shortcut'
function _fet_func_windows_shortcut() {
  local dir=""
  local -A pathes 
  IFS=$'\n'
  for _dict in `cat ~/.fet/windows_shortcut.setting`
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

# メモリ開放
function _fet_func_destruction() {
  unset _fet_path_selected_path
  unset _fet_path_previous_dirs
  unset _fet_path_following_dirs
  unset _fet_var_yank_content
}

# ファイル削除
function _fet_func_delete() {
  echo '0' >| ~/.fet/.status/.delete.status
  rm -ri $PWD/$_fet_path_selected_path
}

# ファイル名リネーム
function _fet_func_rename() {
  echo '0' >| ~/.fet/.status/.rename.status
  echo "please write new name of '$_fet_path_selected_path'"
  local _fet_var_newname=$_fet_path_selected_path;
  trap 'return' SIGINT
  vared _fet_var_newname;
  local _fet_var_check_not_include_slash=$(echo $_fet_var_newname | grep '/')
  if [ -n "$_fet_var_check_not_include_slash" ]; then
    echo "Including '/' is not valid."
  else;
    mv -iT "$PWD/$_fet_path_selected_path" "$PWD/$_fet_var_newname"
  fi
}

# アプリを指定して開く
function _fet_func_open() {
  echo '0' >| ~/.fet/.status/.open.status
  echo 'please write command...'
  local _fet_var_cmd='';
  trap 'return' SIGINT
  vared _fet_var_cmd;
  "$_fet_var_cmd" $_fet_path_selected_path
}

# コマンド実行モード
function _fet_func_shell() {
  echo '0' >| ~/.fet/.status/.shell.status
  echo 'please write command...'
  local _fet_var_cmd='';
  trap 'return' SIGINT
  vared _fet_var_cmd;
  _fet_path_previous_dirs+=($PWD)
  _fet_path_following_dirs=()
  function chpwd() {}
  eval "$_fet_var_cmd"
  function chpwd() {lsi ././}
}

# 新しくファイルかディレクトリを作る
function _fet_func_mknew() {
  echo '0' >| ~/.fet/.status/.mknew.status
  echo "Make dir or file.\nPlease write new dir or file name. (If last char is /, make dir.)"
  local _fet_var_new_mk_name=''
  trap 'return' SIGINT
  vared _fet_var_new_mk_name;
  _fet_var_new_mk_name=$(echo $_fet_var_new_mk_name | grep -v -E "^/")
  if [ -n "$_fet_var_new_mk_name" ]; then
    local _fet_var_check_file_dir=$(echo $_fet_var_new_mk_name | grep -E "/$")
    if [ -n "$_fet_var_check_file_dir" ]; then
      mkdir $_fet_var_check_file_dir
    else;
      touch $_fet_var_new_mk_name
    fi
  fi
}

# クイックアクセス
function _fet_func_quickaccess() {
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
}

# クイックアクセスの登録
function _fet_func_register_quickaccess() {
  echo '0' >| ~/.fet/.status/.register_quickaccess.status
  echo 'Please write name of this quickaccess.'
  local name_of_qa=$_fet_path_selected_path
  trap 'return' SIGINT
  vared name_of_qa
  name_of_qa=$(echo $name_of_qa | sed 's/,/_/' | sed 's/\t/ /')
  local -A pathes 
  IFS=$'\n'
  for _dict in `cat ~/.fet/quickaccess.setting`
  do
    local _key=$(echo $_dict | awk -F", *" '{print $1}' )
    local _value=$(echo $_dict | awk -F", *" '{print $2}' )
    pathes[$_key]=$_value
  done
  pathes[$name_of_qa]=$PWD/$_fet_path_selected_path
  echo >| ~/.fet/quickaccess.setting
  for key in ${(k)pathes}; do
    echo "$key, ${pathes[$key]}" >> ~/.fet/quickaccess.setting
  done
}

# クイックアクセスの削除
function _fet_func_delete_quickaccess() {
  local -A pathes 
  IFS=$'\n'
  for _dict in `cat ~/.fet/quickaccess.setting`
  do
    local _key=$(echo $_dict | awk -F", *" '{print $1}' )
    local _value=$(echo $_dict | awk -F", *" '{print $2}' )
    pathes[$_key]=$_value
  done
  echo >| ~/.fet/quickaccess.setting
  for key in ${(k)pathes}; do
    local _virtual_key="$key"
    if [ $_fet_quickaccess_name = $_virtual_key ]; then
    else;
      echo "$key, ${pathes[$key]}" >> ~/.fet/quickaccess.setting
    fi
  done
}

