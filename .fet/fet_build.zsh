#!/bin/zsh
local _fet_function_status_list=()
local _fet_plugins_status_list=()
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
for plugin in $(echo $_fet_plugins_name_list | tr ' ' '\n')
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
# config読み込み
local config=$(cat ~/.fet/config)
## keybinding読み込み
local _fet_var_keybindings='ESC:execute-silent(echo 1 >| ~/.fet/.status/.endloop.status)+abort'
local config_bindkeys=($(echo $config | grep "^bindkey" | tr '\n' ' '))
for config_bindkey in $config_bindkeys
do
  local config_key=$(echo $config_bindkey | cut -f 2 -d ':')
  local config_func=$(echo $config_bindkey | cut -f 3 -d ':')
  config_func=$_fet_func_keybind_dict["$config_func"]
  _fet_var_keybindings=$_fet_var_keybindings,$config_key:$config_func
done
## infobar
echo >| ~/.fet/user/build/infobar_func.fet
local config_infobars=($(echo $config | grep "^infobar" | tr '\n' ' '))
local config_infobar_func=''
for config_infobar in $config_infobars
do
  config_infobar_func=$(echo $config_infobar | cut -f 2 -d ':' | sed 's:/:/functions/:')
  echo $config_infobar_func >> ~/.fet/user/build/infobar_func.fet
done

# 存在しないパスを解決する
if [ -d "~/.fet/user/data" ]; then
else
  mkdir ~/.fet/user/data
fi

echo $_fet_function_status_list >| ~/.fet/user/build/function_status_list.fet
echo $_fet_plugins_status_list >| ~/.fet/user/build/plugins_status_list.fet
echo $_fet_var_keybindings >| ~/.fet/user/build/keybindings.fet

echo "build successfully!"
