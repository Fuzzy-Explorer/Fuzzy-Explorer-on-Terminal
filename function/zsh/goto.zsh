#!/bin/zsh
echo "$_fet_colorcode_yellow"'Please write Path'"$_fet_colorcode_end"
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  echo '(or drag file/directory from Windows Explorer.)\n'
fi
local input_path=''
trap 'return' SIGINT
vared -p "GOTO PATH > " input_path
local ubuntu_path=$(eval "echo $input_path")
if [ -d "$ubuntu_path" ]; then
  . ~/.fet/function/cd.zsh "$ubuntu_path"
  # function chpwd() {}
  # cd "$ubuntu_path"
  # function chpwd() {lsi ././}
else;
  if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    local windows_path=$(eval 'wslpath -u "$input_path"')
    if [ -d "$windows_path" ]; then
      . ~/.fet/function/cd.zsh "$windows_path"
      # function chpwd() {}
      # cd "$windows_path"
      # function chpwd() {lsi ././}
    else;
      echo 'no such directory.'
    fi
  else;
    echo 'no such directory.'
  fi
fi
