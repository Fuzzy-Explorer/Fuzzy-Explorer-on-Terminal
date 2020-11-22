#!/bin/zsh
local -A pathes=()
IFS=$'\n'
for _dict in `cat ~/.fet/user/data/quickaccess_quickaccess.csv`
do
  local _key=$(echo $_dict | awk -F", *" '{print $1}' )
  local _value=$(echo $_dict | awk -F", *" '{print $2}' )
  pathes[$_key]=$_value
done
echo >| ~/.fet/user/data/quickaccess.csv
for key in ${(k)pathes}; do
  local _virtual_key="$key"
  if [ $_fet_quickaccess_name = $_virtual_key ]; then
  else;
    echo "$key, ${pathes[$key]}" >> ~/.fet/user/data/quickaccess.csv
  fi
done
