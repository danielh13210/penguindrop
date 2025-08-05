#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
source penguindrop-controller/bin/activate
python3 controller.py