#!/bin/bash

TARGET="${1}"
FILEPATH="${2}"
if "$(dirname ${BASH_SOURCE[0]})/wsl-helpers/is_wsl.sh" && [ "${FILEPATH:0:1}" != "/" ]; then
  FILEPATH=$(echo "${FILEPATH}" | tr '\\' '/')
  FILEPATH=$(wslpath "${FILEPATH}")
fi
FILENAME=$(basename "${FILEPATH}")

function cancel () {
    STATUS=$(curl -s -X POST "http://${TARGET}:6707/close")
    if [ "$?" -ne 0 ]; then
        echo -en "\rFailed"
        exit 1
    fi
    ERRORS=$(echo "$STATUS" | grep "\"error\"")
    if [ "$?" -eq 0 ]; then
        echo -en "\rFailed"
        echo "Error: $(python3 -c "import json; print(json.loads('${ERRORS}')['error'])")" >&2
        exit 1
    fi
    echo -en "\rCancelled"
    exit 0
}

trap 'echo' EXIT

echo -en "\rWaiting"
STATUS=$(curl -s -X PUT -d "{\"filename\":\"${FILENAME}\",\"name\":\"$(hostname)\"}" "http://${TARGET}:6707/startsend" -H "Content-Type: application/json")
if [ "$?" -ne 0 ]; then
    echo -en "\rFailed"
    exit 1
fi
ERRORS=$(echo "$STATUS" | grep "\"error\"")
if [ "$?" -eq 0 ]; then 
    echo -en "\rFailed"
    echo "Error: $(python3 -c "import json; print(json.loads('${ERRORS}')['error'])")" >&2
    exit 1
fi

#wait until accept or decline
trap cancel INT
FAILURES=0
while true; do
    FAIL=false
    STATUS_JSON=$(curl -s -X GET "http://${TARGET}:6707/status")
    if [ "$?" -ne 0 ]; then
        FAIL=true
    else
        STATUS=$(echo "$STATUS_JSON" | python3 -c "import json, sys; print(json.loads(sys.stdin.read())['status'])")
        if [ "$STATUS" == "ready" ]; then
            break
        elif [ "$STATUS" == "declined" ]; then
            echo -en "\rDeclined"
            exit 1
        elif [ "$STATUS" == "failed" ]; then
            echo -en "\rFailed"
            exit 1
        fi
    fi

    if $FAIL; then
        ((FAILURES++))
        if [ $FAILURES -ge 5 ]; then
            echo "Failed to check status too many times. Exiting." >&2
            exit 1
        fi
        sleep 0.5
        continue
    fi

    sleep 0.5
done

echo -en "\rSending"
[ -f /tmp/penguindrop-key ] && rm /tmp/penguindrop-key
[ -f /tmp/penguindrop-key.pub ] && rm /tmp/penguindrop-key.pub
ssh-keygen -t rsa -b 2048 -f /tmp/penguindrop-key -N "" >/dev/null 2>/dev/null
STATUS=$(curl -s -X PUT -d '{"key":"'"$(cat /tmp/penguindrop-key.pub)"'"}' "http://${TARGET}:6707/pubkey" -H "Content-Type: application/json")
if [ "$?" -ne 0 ]; then
    echo -en "\rFailed"
    exit 1
fi
if echo "$STATUS" | grep "^{\"error\"" &>/dev/null; then
    echo -en "\rFailed"
    echo "Error: $(python3 -c "import json; print(json.loads('${STATUS}')['error'])")" >&2
    exit 1
fi
scp -r -i /tmp/penguindrop-key -P 6708 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${FILEPATH}" "ubuntu@${TARGET}:/home/ubuntu/${FILENAME}"
if [ "$?" -ne 0 ]; then
    echo -en "\rFailed"
else
    rm /tmp/penguindrop-key
fi
STATUS=$(curl -s -X POST "http://${TARGET}:6707/close")
if [ "$?" -ne 0 ]; then
    echo -en "\rFailed"
    exit 1
fi
ERRORS=$(echo "$STATUS" | grep "\"error\"")
if [ "$?" -eq 0 ]; then
    echo -en "\rFailed"
    echo "Error: $(python3 -c "import json; print(json.loads('${ERRORS}')['error'])")" >&2
    exit 1
fi
echo -en "\rComplete"
