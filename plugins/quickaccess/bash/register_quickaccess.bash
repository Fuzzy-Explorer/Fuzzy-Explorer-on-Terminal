#!/bin/bash
echo "$_fet_colorcode_yellow"'Please write name of this quickaccess.'"$_fet_colorcode_end"
input_qaname=$_fet_path_selected_path
trap 'return' SIGINT
read -p "QA NAME > " input_qaname
input_qaname=$(echo $input_qaname | sed 's/,/_/' | sed 's/\t/ /')
declare -A pathes=()
IFS=$'\n'
if [ -f "~/.fet/user/data/quickaccess.csv" ]; then
  :
else
  touch ~/.fet/user/data/quickaccess.csv
fi
for _dict in `cat ~/.fet/user/data/quickaccess.csv`
do
  _key=$(echo $_dict | awk -F", *" '{print $1}' )
  _value=$(echo $_dict | awk -F", *" '{print $2}' )
  pathes[$_key]=$_value
done
pathes[$input_qaname]=$PWD/$_fet_path_selected_path
echo >| ~/.fet/user/data/quickaccess.csv
for key in ${(k)pathes}; do
  echo "$key, ${pathes[$key]}" >> ~/.fet/user/data/quickaccess.csv
done
