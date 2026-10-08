#!/bin/bash

if ./wsl-helpers/is_wsl.sh; then
  python3 discover-devices.windows.py
else
  python3 discover-devices.py
fi 
