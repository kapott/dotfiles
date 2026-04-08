# SSH agent via systemd user service
set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"

source /usr/share/cachyos-fish-config/cachyos-config.fish
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.config/emacs/bin
# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
