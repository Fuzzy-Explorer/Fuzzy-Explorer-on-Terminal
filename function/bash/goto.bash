#!/bin/bash
echo "$_fet_colorcode_yellow"'Please write Path'"$_fet_colorcode_end"
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  echo '(or drag file/directory from Windows Explorer.)\n'
fi
input_path=''
trap 'return' SIGINT
read -p "GOTO PATH > " input_path
ubuntu_path=$(eval "echo $input_path")
if [ -d "$ubuntu_path" ]; then
  . ~/.fet/function/cd.bash "$ubuntu_path"
else
  if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    windows_path=$(eval 'wslpath -u "$input_path"')
    if [ -d "$windows_path" ]; then
      . ~/.fet/function/cd.bash "$windows_path"
    else
      echo 'no such directory.'
    fi
  else
    echo 'no such directory.'
  fi
fi
