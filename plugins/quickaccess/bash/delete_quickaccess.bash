#!/bin/bash
echo '0' >| ~/.fet/.status/.quickaccess_delete_quickaccess.status
declare -A pathes=()
IFS=$'\n'
for _dict in `cat ~/.fet/user/data/quickaccess.csv`
do
  _key=$(echo $_dict | awk -F", *" '{print $1}' )
  _value=$(echo $_dict | awk -F", *" '{print $2}' )
  pathes[$_key]=$_value
done
echo >| ~/.fet/user/data/quickaccess.csv
for key in ${(k)pathes}; do
  _virtual_key="$key"
  if [ $_fet_quickaccess_name = $_virtual_key ]; then
    :
  else
    echo "$key, ${pathes[$key]}" >> ~/.fet/user/data/quickaccess.csv
  fi
done
