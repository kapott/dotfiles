# Initialize zoxide (z command replacement)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash --cmd c)"
else
    echo "Warning: zoxide not installed"
fi
