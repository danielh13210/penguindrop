#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
if [ ! -d penguindrop-controller ]; then
  python3 -m venv penguindrop-controller || exit 1
source penguindrop-controller/bin/activate
pip3 install flask
fi
if ! docker image ls | grep "^penguindrop-acceptor" > /dev/null; then
  pushd penguindrop-acceptor
  docker build -t penguindrop-acceptor .
  popd
fi
mkdir -p ~/.local/share/penguindrop ~/.config/autostart
grep -v "penguindrop-controller" .gitignore > "$XDG_RUNTIME_DIR/pdsetup-rsync-exclude"
rsync -av --exclude-from="$XDG_RUNTIME_DIR/pdsetup-rsync-exclude" --exclude ".git" --exclude ".gitignore" . ~/.local/share/penguindrop
if ./wsl-helpers/is_wsl.sh; then
  powershell.exe -ExecutionPolicy Bypass -File ./wsl-helpers/autostart-setup.ps1 "$HOME/.local/share/penguindrop/daemon.sh"
else
  cp pdcontroller-server.desktop ~/.config/autostart
fi
