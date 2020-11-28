#!/bin/zsh
setopt +o nomatch
# Function全部読み込み
local _fet_general_status_list=(endloop goup)
local _fet_function_status_list=()
local _fet_plugins_status_list=()

IFS=$' '
if [ -f "$HOME/.fet/user/build/function_status_list.fet" ]; then
else
  . ~/.fet/fet_build.zsh
fi
if [ -f "$HOME/.fet/user/build/plugins_status_list.fet" ]; then
else
  . ~/.fet/fet_build.zsh
fi
if [ -f "$HOME/.fet/user/build/keybindings.fet" ]; then
else
  . ~/.fet/fet_build.zsh
fi
if [ -f "$HOME/.fet/user/build/infobar_func.fet" ]; then
else
  . ~/.fet/fet_build.zsh
fi
_fet_function_status_list=($(cat ~/.fet/user/build/function_status_list.fet))
_fet_plugins_status_list=($(cat ~/.fet/user/build/plugins_status_list.fet))
_fet_var_keybindings=$(cat ~/.fet/user/build/keybindings.fet)
IFS=$'\n'

# ステータスファイル初期化
for var in $_fet_general_status_list
do
  echo '0' >| ~/.fet/.status/.$var.status
done
local _fet_function_status_sed=()
local _fet_function_status_path=()
for var in $_fet_function_status_list
do
  _fet_function_status_path+=($(echo $var | sed 's:/:/zsh/:'))
  var=$(echo $var | sed 's:/:_:')
  _fet_function_status_sed+=("$var")
  echo '0' >| ~/.fet/.status/.$var.status
done
local _fet_plugins_status_sed=()
local _fet_plugins_status_path=()
for var in $_fet_plugins_status_list
do
  _fet_plugins_status_path+=($(echo $var | sed 's:/:/zsh/:'))
  var=$(echo $var | sed 's:/:_:')
  _fet_plugins_status_sed+=("$var")
  echo '0' >| ~/.fet/.status/.$var.status
done
echo >| ~/.fet/.status/.hidden.status

# 変数宣言
_fet_status_yank_content=''
_fet_status_cut_content=''
_fet_path_previous_dirs=()
_fet_path_following_dirs=()

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

  # infobar
  local _fet_var_infobar=''
  for infobar_func in `cat ~/.fet/user/build/infobar_func.fet`
  do
    if [ -n "$infobar_func" ]; then
      _fet_var_infobar=$(echo $_fet_var_infobar$(. ~/.fet/plugins/$(echo $infobar_func).zsh)'  ')
    fi
  done

  # fzfでのディレクトリの選択
  local _fet_path_selected_path=$(echo $_fet_path_path_list | fzf +m --ansi --height 70% --cycle --preview-window right:40% --info='inline' --layout=reverse --border --prompt="$_fet_var_promp >" --header="$_fet_var_infobar" --bind "$_fet_var_keybindings" --preview="echo {} | cut -f 2 -d ' ' | xargs -rI{a} sh -c 'if [ -f \"{a}\" ]; then ls -ldhG {a}; if [ \"$(which batcat)\" = \"batcat not found\" ]; then cat {a}; else batcat {a} --color=always --style=grid --line-range :100; fi else ls -ldhG {a}; echo; lsi {a}; fi'")
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
    for var in $(seq 1 $(echo ${#_fet_function_status_list[*]}))
    do
      if [ "$_fet_status_no_key" = "no" ]; then
        break
      fi
      local var_sed=${_fet_function_status_sed[var]}
      local var_path=${_fet_function_status_path[var]}
      local status_var=$(cat ~/.fet/.status/.$var_sed.status)
      if [ "$status_var" = '1' ]; then
        echo '0' >| ~/.fet/.status/.$var_sed.status
        . ~/.fet/$var_path.zsh
        _fet_status_no_key='no'
      fi
    done

    ## Plugins status
    for var in $(seq 1 $(echo ${#_fet_plugins_status_list[*]}))
    do
      if [ "$_fet_status_no_key" = "no" ]; then
        break
      fi
      local var_sed=${_fet_plugins_status_sed[var]}
      local var_path=${_fet_plugins_status_path[var]}
      local status_var=$(cat ~/.fet/.status/.$var_sed.status)
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

