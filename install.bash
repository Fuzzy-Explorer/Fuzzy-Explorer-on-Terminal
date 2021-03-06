#!/bin/bash
# fzf install
if [ -n "$(which fzf)" ]; then
  echo "Success: already installed 'fzf'"
else
  echo ''
  read -p "try to install 'fzf'. ok? (y/n) > ";
  if [ "$REPLY" = "y" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
  else
    echo "'fzf' is neeeded."
  fi
fi
# lsi install
if [ -n "$(which lsi)" ]; then
  echo "Success: already installed 'ls-Improved'"
else
  if [ -n "$(which pip)" ]; then
    echo ''
    read -p "try to install 'ls-Improved'. ok? (y/n) > ";
    if [ "$REPLY" = "y" ]; then
      pip install ls-Improved
    else
      echo "'Failure: ls-Improved' is neeeded."
      exit 1
    fi
  else
    echo "Failure: try 'pip install ls-Improved', but not found pip"
    exit 1
  fi
fi
# richcat install
if [ -n "$(which richcat)" ]; then
  echo "Success: already installed 'richcat'"
else
  if [ -n "$(which pip)" ]; then
    echo ''
    read -p "try to install 'richcat'. ok? (y/n) > ";
    if [ "$REPLY" = "y" ]; then
      pip install richcat
    else
      echo "'Failure: richcat' is neeeded."
      exit 1
    fi
  else
    echo "Failure: try 'pip install richcat', but not found pip"
    exit 1
  fi
fi

echo ''
read -p "try to add 'alias fet='. $HOME/.fet/fet'' to ~/.bashrc. ok? (y/n) > ";
if [ "$REPLY" = "y" ]; then
  alias fet='. $HOME/.fet/fet'
  echo "alias fet='. $HOME/.fet/fet'" >> $HOME/.bashrc
  echo "Success: add 'alias fet='. $HOME/.fet/fet'' to ~/.bashrc"
else
  echo "Please make alias 'alias fet='. $HOME/.fet/fet'' somewhere you want."
fi
echo "install done"
