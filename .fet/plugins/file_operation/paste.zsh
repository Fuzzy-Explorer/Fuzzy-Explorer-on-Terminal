#!/bin/zsh
echo '0' >| ~/.fet/.status/.file_operation_paste.status
if [ $_fet_var_yank_content = '' ]; then
else;
  cp -ri "$_fet_var_yank_content" "$PWD/"
  echo "paste complete $_fet_var_yank_content -> $PWD/"
fi
