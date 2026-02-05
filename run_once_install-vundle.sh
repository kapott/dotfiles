#!/bin/bash

VUNDLE_DIR="${HOME}/.config/vim/bundle/Vundle.vim"

if [ ! -d "$VUNDLE_DIR" ]; then
    if curl -s --connect-timeout 3 https://github.com > /dev/null 2>&1; then
        echo "Installing Vundle..."
        git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"
        vim +PluginInstall +qall
        echo "Vundle and plugins synced."
    else
        echo "WARNING: No internet - skipping Vundle install"
        echo "Copy Vundle manually to $VUNDLE_DIR"
    fi
else
    echo "Installing Vim plugins..."
    vim +PluginInstall +qall
fi
