#!/bin/bash
set -e

OUTDIR="${1:-./airgap-bundle}"
mkdir -p "$OUTDIR/bin" "$OUTDIR/vim-bundle" "$OUTDIR/dotfiles"

echo "Collecting binaries..."
for bin in chezmoi fzf rg zoxide vault; do
    BINPATH=$(which "$bin" 2>/dev/null)
    if [ -n "$BINPATH" ]; then
        cp "$BINPATH" "$OUTDIR/bin/"
        echo "  ✓ $bin"
    else
        echo "  ✗ $bin not found, skipping"
    fi
done

echo "Collecting Vundle and plugins..."
if [ -d ~/.config/vim/bundle ]; then
    cp -r ~/.config/vim/bundle/* "$OUTDIR/vim-bundle/"
    echo "  ✓ vim plugins"
else
    echo "  ✗ vim bundle not found"
fi

echo "Collecting dotfiles source..."
cp -r ~/.local/share/chezmoi/* "$OUTDIR/dotfiles/"
echo "  ✓ chezmoi source"

echo "Creating tarball..."
tar czf airgap-bundle.tar.gz -C "$OUTDIR" .
rm -rf "$OUTDIR"

echo ""
echo "Done: airgap-bundle.tar.gz ($(du -h airgap-bundle.tar.gz | cut -f1))"
