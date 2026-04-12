#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
if [ ! -d penguindrop-controller ]; then
  python3 -m venv penguindrop-controller || exit 1
  source penguindrop-controller/bin/activate
  pip3 install -r requirements.txt
fi
if ! docker image ls | grep "^penguindrop-acceptor" > /dev/null; then
  pushd penguindrop-acceptor
  docker build -t penguindrop-acceptor .
  popd
fi
mkdir -p ~/.local/share/penguindrop ~/.config/autostart
grep -v "penguindrop-controller" .gitignore > "$XDG_RUNTIME_DIR/pdsetup-rsync-exclude"
rsync -av --exclude-from="$XDG_RUNTIME_DIR/pdsetup-rsync-exclude" --exclude ".git" --exclude ".gitignore" --exclude "requirements.txt" . ~/.local/share/penguindrop
if ./wsl-helpers/is_wsl.sh; then
  powershell.exe -ExecutionPolicy Bypass -File ./wsl-helpers/autostart-setup.ps1 "$HOME/.local/share/penguindrop/daemon-wrapper.sh"
  sed -i 's/{{DISTRO_NAME}}/'"${WSL_DISTRO_NAME}"'/g' ~/.local/share/penguindrop/wsl-helpers/netsh-setup.ps1
  appdata=$(cmd.exe /c echo %APPDATA% 2>/dev/null | tr -d '\r')
  mkdir -p ~/.config/pd-ssh-tunnel $(wslpath "$appdata\.config\pd-ssh-tunnel")
  [ ! -f ~/.config/pd-ssh-tunnel/forwarding ] && ssh-keygen -t rsa -b 2048 -f ~/.config/pd-ssh-tunnel/forwarding -N "" -q
  cp ~/.config/pd-ssh-tunnel/forwarding $(wslpath "$appdata\.config\pd-ssh-tunnel/forwarding")
  echo 'command="",no-pty,permitopen="localhost:6709"'" $(cut -d ' ' -f-2 ~/.config/pd-ssh-tunnel/forwarding.pub) WSL tunneling key" >> ~/.ssh/authorized_keys
else
  cp pdcontroller-server.desktop ~/.config/autostart
fi
