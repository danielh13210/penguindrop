#!/bin/bash

if [ -f "${XDG_RUNTIME_DIR}/penguindrop_key" ]; then
    curl -s -X POST "http://localhost:6707/set_privacy" -d "{\"key\": \"$(cat "${XDG_RUNTIME_DIR}/penguindrop_key")\",\"privacy_mode\":${1}}" -H "Content-Type: application/json"
fi