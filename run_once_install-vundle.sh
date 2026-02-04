#!/bin/bash

VUNDLE_DIR="${HOME}/.config/vim/bundle/Vundle.vim"

if [ ! -d "$VUNDLE_DIR" ]; then
    echo "Installing Vundle..."
    git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"
    vim +PluginInstall +qall
    echo "Vundle installed and plugins synced."
else
    echo "Vundle already installed."
fi
