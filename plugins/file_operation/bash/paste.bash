#!/bin/bash
if [ "$_fet_var_yank_content" = "" ]; then
  :
else
  cp -ri "$_fet_var_yank_content" "$PWD/"
  echo "$_fet_colorcode_yellow""paste complete""$_fet_colorcode_end" "$_fet_var_yank_content -> $PWD/"
fi

if [ "$_fet_var_cut_content" = "" ]; then
  :
else
  mv -i "$_fet_var_cut_content" "$PWD/"
  echo "$_fet_colorcode_yellow""cut paste complete""$_fet_colorcode_end" "$_fet_var_yank_content -> $PWD/"
fi
