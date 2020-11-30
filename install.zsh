#!/bin/zsh
# fzf install
if [ "$(which fzf)" = "fzf not found" ]; then
  echo ''
  read -p "try to install 'fzf'. ok? (y/n) > ";
  if [ "$REPLY" = "y" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
  else
    echo "'fzf' is neeeded."
  fi
else
  echo "Success: already installed 'fzf'"
fi
# lsi install
if [ "$(which lsi)" = "lsi not found" ]; then
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
else
  echo "Success: already installed 'ls-Improved'"
fi
# richcat install
if [ "$(which richcat)" = "richcat not found" ]; then
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
else
  echo "Success: already installed 'richcat'"
fi

echo ''
read -p "try to add 'alias fet='. $HOME/.fet/fet'' to ~/.zshrc. ok? (y/n) > ";
if [ "$REPLY" = "y" ]; then
  alias fet='. $HOME/.fet/fet'
  echo "alias fet='. $HOME/.fet/fet'" >> $HOME/.zshrc
  echo "Success: add 'alias fet='. $HOME/.fet/fet'' to ~/.zshrc"
else
  echo "Please make alias 'alias fet='. $HOME/.fet/fet'' somewhere you want."
fi
echo "install done"
