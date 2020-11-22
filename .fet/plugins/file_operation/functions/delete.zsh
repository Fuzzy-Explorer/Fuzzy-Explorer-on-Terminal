#!/bin/zsh
echo '0' >| ~/.fet/.status/.file_operation_delete.status
rm -ri $PWD/$_fet_path_selected_path
