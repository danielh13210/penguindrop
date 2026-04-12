#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
source penguindrop-controller/bin/activate
if ./wsl-helpers/is_wsl.sh; then
    appdata=$(cmd.exe /c echo %APPDATA% 2>/dev/null | tr -d '\r')
    ssh.exe -i "$appdata\.config\pd-ssh-tunnel\forwarding" -NT -L 0.0.0.0:6707:localhost:6709 $USER@localhost &
    gunicorn -w 1 -b 127.0.0.1:6709 controller:app # WSL, bind to localhost because we'll need an ssh tunnel to access it from other machines
else
    gunicorn -w 1 -b 0.0.0.0:6707 controller:app # native linux, bind to all interfaces so it can be accessed from other machines on the network
fi