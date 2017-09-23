#!/bin/bash

# copy all the <config-files> to <cf-dir>
# cd to LinuxConfigs before execute this file.
# this file must be in "~/LinuxConfigs/"

if [ `uname` != "Linux" ]; then
    echo 'Is Not in Linux.'
    exit
fi

if [[ $(cd `dirname "$0"`;pwd) != ~/LinuxConfigs ]]; then
    echo 'Is Not in ~/LinuxConfigs'
    exit
fi

# cf-vim
cp ../.vimrc                  ./cf-vim/
cp ../.vim/.ycm_extra_conf.py ./cf-vim/
cp ../.vim/mySnippets/*       ./cf-vim/mySnippets/
cp ../.vim/autoload/*         ./cf-vim/autoload/


# cf-zsh
cp ../.zshrc      ./cf-zsh/
cp ../.zprofile   ./cf-zsh/
cp ../.Xmodmap    ./cf-zsh/
cp ../.Xresources ./cf-zsh/
cp ../.gitconfig  ./cf-zsh/
cp ../.xinitrc    ./cf-zsh/


# cf-i3
cp ../.config/i3/*             ./cf-i3/i3/
cp ../.config/i3status/config  ./cf-i3/i3status/
cp ../MyApps/ToggleTouchPad.py ./cf-i3/