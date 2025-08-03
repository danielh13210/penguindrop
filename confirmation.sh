#!/bin/bash

filename="${1}"
key="${2}"

zenity --question --title="File Sharing" --text="Would you like to recieve the file ${filename}" && result=true || result=false
curl -H "Content-Type: application/json" -d '{"key":"'"${2}"'","accept":'"${result}"'}' http://127.0.0.1:6707/confirm
