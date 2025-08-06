#!/bin/bash

filename="${1}"
key="${2}"
KILLED=false

zenity --question --title="File Sharing" --text="Would you like to recieve the file ${filename}" &
ZPID=$!
trap "kill $ZPID;KILLED=true" INT TERM
wait $ZPID
$KILLED || curl -H "Content-Type: application/json" -d '{"key":${2}"'","accept":'"${result}"'}' http://127.0.0.1:6707/confirm"'"