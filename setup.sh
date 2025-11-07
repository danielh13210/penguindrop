#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
python3 -m venv penguindrop-controller || exit 1
source penguindrop-controller/bin/activate
pip3 install flask
pushd penguindrop-acceptor
docker build -t penguindrop-acceptor .
popd
