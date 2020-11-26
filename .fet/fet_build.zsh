#!/bin/zsh
local _fet_plugins_name_list=($(ls ~/.fet/plugins))
local -A _fet_func_keybind_dict=()
local function_init="$HOME/.fet/function/init.fet"
IFS=$'\n'

# setfunc読み込み
## function読み込み
if [ -f "$function_init" ]; then
  for setfunc in $(cat $function_init | grep "^setfunc")
  do
    local _setfunc_func=$(echo $setfunc | cut -f 2 -d ':')
    local _setfunc_keybind=$(echo $setfunc | cut -f 3 -d ':')
    if [ -n "$(echo $setfunc | grep "^setfunc-nostatus")" ]; then
    else
      _fet_function_status_list+=($_setfunc_func)
    fi
    _fet_func_keybind_dict["$_setfunc_func"]=$_setfunc_keybind
  done
fi
## plugins読み込み
for plugin in $_fet_plugins_name_list
do
  local plugin_init="$HOME/.fet/plugins/$plugin/init.fet"
  if [ -f "$plugin_init" ]; then
    for setfunc in $(cat $plugin_init | grep "^setfunc")
    do
      local _setfunc_func=$(echo $setfunc | cut -f 2 -d ':')
      local _setfunc_keybind=$(echo $setfunc | cut -f 3 -d ':')
      _fet_plugins_status_list+=($_setfunc_func)
      _fet_func_keybind_dict["$_setfunc_func"]=$_setfunc_keybind
    done
  fi
done

IFS=$' '
# .fetrc読み込み
local _fetrc=$(cat ~/.fetrc)
## keybinding読み込み
local _fet_var_keybindings='ESC:execute-silent(echo 1 >| ~/.fet/.status/.endloop.status)+abort'
local _fetrc_bindkeys=($(echo $_fetrc | grep "^bindkey" | tr '\n' ' '))
for _fetrc_bindkey in $_fetrc_bindkeys
do
  local _fetrc_key=$(echo $_fetrc_bindkey | cut -f 2 -d ':')
  local _fetrc_func=$(echo $_fetrc_bindkey | cut -f 3 -d ':')
  _fetrc_func=$_fet_func_keybind_dict["$_fetrc_func"]
  _fet_var_keybindings=$_fet_var_keybindings,$_fetrc_key:$_fetrc_func
done

# ビルド
echo $_fet_function_status_list >| ~/.fet/user/build/function_status_list.fet
echo $_fet_plugins_status_list >| ~/.fet/user/build/plugins_status_list.fet
echo $_fet_var_keybindings >| ~/.fet/user/build/keybindings.fet
