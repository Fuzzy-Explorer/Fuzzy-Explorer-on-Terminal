#!/bin/zsh
setopt +o nomatch
# Function全部読み込み
local _fet_general_status_list=(endloop goup)
local _fet_function_status_list=()
local _fet_plugins_status_list=()
# local _fet_plugins_name_list=($(ls ~/.fet/plugins))
# local -A _fet_func_keybind_dict=()
# IFS=$'\n'
# local function_init="$HOME/.fet/function/init.fet"
# if [ -f "$function_init" ]; then
#   for setfunc in $(cat $function_init | grep "^setfunc")
#   do
#     local _setfunc_func=$(echo $setfunc | cut -f 2 -d ':')
#     local _setfunc_keybind=$(echo $setfunc | cut -f 3 -d ':')
#     if [ -n "$(echo $setfunc | grep "^setfunc-nostatus")" ]; then
#     else
#       _fet_function_status_list+=($_setfunc_func)
#     fi
#     _fet_func_keybind_dict["$_setfunc_func"]=$_setfunc_keybind
#   done
# fi
# for plugin in $_fet_plugins_name_list
# do
#   local plugin_init="$HOME/.fet/plugins/$plugin/init.fet"
#   if [ -f "$plugin_init" ]; then
#     for setfunc in $(cat $plugin_init | grep "^setfunc")
#     do
#       local _setfunc_func=$(echo $setfunc | cut -f 2 -d ':')
#       local _setfunc_keybind=$(echo $setfunc | cut -f 3 -d ':')
#       _fet_plugins_status_list+=($_setfunc_func)
#       _fet_func_keybind_dict["$_setfunc_func"]=$_setfunc_keybind
#     done
#   fi
# done
#
# IFS=$' '
# # .fetrc読み込み
# local _fetrc=$(cat ~/.fetrc)
# ## keybinding
# local _fet_var_keybindings='ESC:execute-silent(echo 1 >| ~/.fet/.status/.endloop.status)+abort'
# local _fetrc_bindkeys=($(echo $_fetrc | grep "^bindkey" | tr '\n' ' '))
# for _fetrc_bindkey in $_fetrc_bindkeys
# do
#   local _fetrc_key=$(echo $_fetrc_bindkey | cut -f 2 -d ':')
#   local _fetrc_func=$(echo $_fetrc_bindkey | cut -f 3 -d ':')
#   _fetrc_func=$_fet_func_keybind_dict["$_fetrc_func"]
#   _fet_var_keybindings=$_fet_var_keybindings,$_fetrc_key:$_fetrc_func
# done

IFS=$' '
_fet_function_status_list=($(cat ~/.fet/user/build/function_status_list.fet))
_fet_plugins_status_list=($(cat ~/.fet/user/build/plugins_status_list.fet))
_fet_var_keybindings=$(cat ~/.fet/user/build/keybindings.fet)
IFS=$'\n'

# ステータスファイル初期化
for var in $_fet_general_status_list
do
  echo '0' >| ~/.fet/.status/.$var.status
done
for var in $_fet_function_status_list
do
  var=$(echo $var | sed 's:/:_:')
  echo '0' >| ~/.fet/.status/.$var.status
done
for var in $_fet_plugins_status_list
do
  var=$(echo $var | sed 's:/:_:')
  echo '0' >| ~/.fet/.status/.$var.status
done
echo >| ~/.fet/.status/.hidden.status

# 変数宣言
_fet_status_yank_content=''
_fet_path_previous_dirs=()
_fet_path_following_dirs=()

# 引数を調べる
if [ $# -gt 0 ]; then
  if [ -d "$@" ]; then
    _fet_path_selected_path="$@"
    _fet_func_change_directory
  fi
fi

# -------------------------------------------------------- #
# ---------------------- ループ開始 ---------------------- #
# -------------------------------------------------------- #
while :
do
  # 隠しディレクトリ表示の判定
  local _fet_status_hidden=$(( $(cat ~/.fet/.status/.hidden.status | wc -l) % 2 ))

  # ディレクトリ一覧の取得
  if [ $_fet_status_hidden -eq 1 ]; then
    local _fet_path_path_list="../\n`lsi`"
  else;
    local _fet_path_path_list="../\n`lsi -a`"
  fi

  # プロンプト文字列
  local _fet_var_promp=$(echo $PWD | sed -e "s:$HOME:~:")

  # GIT Info bar
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
      local _fet_var_git_diff_mod=$(echo $_fet_var_git_diff | grep -e "^ M" -e "^ D" | wc -l)
      local _fet_var_git_diff_added=$(echo $_fet_var_git_diff | grep -e "^M " -e "^D "| wc -l)
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
  else
    _fet_var_git_current_branch=''
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
    ## General status
    for var in $_fet_general_status_list
    do
      local _fet_status_$var=$(cat ~/.fet/.status/.$var.status)
    done
    ### 上の階層に移動するかどうか
    if [ -n "$_fet_path_selected_path" ]; then
    elif [ "$_fet_status_goup" = '0' ]; then
      _fet_path_selected_path="./"
    elif [ "$_fet_status_goup" = '1' ]; then
      echo '0' >| ~/.fet/.status/.goup.status
      _fet_path_selected_path="../"
    fi

    local _fet_status_no_key='yes'
    ## Function status
    for var in $_fet_function_status_list
    do
      if [ "$_fet_status_no_key" = "no" ]; then
        break
      fi
      local var_sed=$(echo $var | sed 's:/:_:')
      local var_path=$var
      local status_var=$(cat ~/.fet/.status/.$var_sed.status)
      # local _fet_status_$var_sed=$(cat ~/.fet/.status/.$var_sed.status)
      # local status_var=_fet_status_$var_sed
      # status_var=$(eval echo \"\$$status_var\")
      if [ "$status_var" = '1' ]; then
        echo '0' >| ~/.fet/.status/.$var_sed.status
        . ~/.fet/function/$var_path.zsh
        _fet_status_no_key='no'
      fi
    done

    ## Plugins status
    for var in $_fet_plugins_status_list
    do
      if [ "$_fet_status_no_key" = "no" ]; then
        break
      fi
      local var_sed=$(echo $var | sed 's:/:_:')
      local var_path=$(echo $var | sed 's:/:/functions/:')
      local status_var=$(cat ~/.fet/.status/.$var_sed.status)
      # local _fet_status_$var_sed=$(cat ~/.fet/.status/.$var_sed.status)
      # local status_var=_fet_status_$var_sed
      # status_var=$(eval echo \"\$$status_var\")
      if [ "$status_var" = '1' ]; then
        echo '0' >| ~/.fet/.status/.$var_sed.status
        . ~/.fet/plugins/$var_path.zsh
        _fet_status_no_key='no'
      fi
    done

    ## cd or execute
    if [ $_fet_status_no_key = 'yes' ]; then
      if (test -d $_fet_path_selected_path); then
        . ~/.fet/function/cd.zsh
      else;
        . ~/.fet/function/execute.zsh
      fi
    fi
  else;
    break
  fi
done
. ~/.fet/function/destruction.zsh
lsi ././

