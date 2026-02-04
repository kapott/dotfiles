# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if [ -d "/opt/homebrew" ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

unset rc

# Activate mise for tool version management
if command -v mise &> /dev/null; then
    eval "$(mise activate bash)"
fi
