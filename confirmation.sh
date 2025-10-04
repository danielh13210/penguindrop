#!/bin/bash

filename="${1}"
key="${2}"
name="${3}"
KILLED=false

mktemp 
notify-send -i email -A "accept"=Accept -A "decline"=Decline -e "PenguinDrop: Accept file?" "Accept file ${filename} from ${name}?" >  /tmp/accepted &
ZPID=$!
trap "kill $ZPID;KILLED=true" INT TERM
wait $ZPID
if [ "$KILLED" = false ]; then
    if [ "$(</tmp/accepted)" == "accept" ]; then
        result=true
    else
        result=false
    fi
    curl -H "Content-Type: application/json" -d '{"key":"'"${key}"'","accept":'"${result}"'}' "http://127.0.0.1:6707/confirm"
fi
if [ -f /tmp/accepted ]; then
  rm /tmp/accepted
fi
