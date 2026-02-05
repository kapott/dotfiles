#!/bin/bash
set -e

BUNDLE="${1:-airgap-bundle.tar.gz}"

if [ ! -f "$BUNDLE" ]; then
    echo "Usage: $0 <airgap-bundle.tar.gz>"
    exit 1
fi

TMPDIR=$(mktemp -d)
tar xzf "$BUNDLE" -C "$TMPDIR"

echo "Installing binaries..."
mkdir -p ~/.local/bin
for bin in "$TMPDIR"/bin/*; do
    cp "$bin" ~/.local/bin/
    chmod +x ~/.local/bin/$(basename "$bin")
    echo "  ✓ $(basename "$bin")"
done

if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo "  ⚠ Add ~/.local/bin to your PATH"
fi

echo "Installing dotfiles..."
mkdir -p ~/.local/share/chezmoi
cp -r "$TMPDIR"/dotfiles/* ~/.local/share/chezmoi/
echo "  ✓ chezmoi source"

echo "Installing vim plugins..."
mkdir -p ~/.config/vim/bundle
cp -r "$TMPDIR"/vim-bundle/* ~/.config/vim/bundle/
echo "  ✓ vim plugins"

rm -rf "$TMPDIR"

echo ""
echo "Done. Now run:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "  chezmoi init"
echo "  chezmoi apply"
