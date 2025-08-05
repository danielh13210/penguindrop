#!/bin/bash

TARGET="${1}"
FILEPATH="${2}"
FILENAME=$(basename "${FILEPATH}")

echo "Waiting"
STATUS=$(curl -s -X PUT -d "{\"filename\":\"${FILENAME}\"}" "http://${TARGET}:6707/startsend" -H "Content-Type: application/json")
if [ "$?" -ne 0 ]; then
    echo "Failed"
    exit 1
fi
ERRORS=$(echo "$STATUS" | grep "\"error\"")
if [ "$?" -eq 0 ]; then 
    echo "Failed"
    echo "Error: $(python3 -c "import json; print(json.loads('${ERRORS}')['error'])")" >&2
    exit 1
fi

#wait until accept or decline
FAILURES=0
while true; do
    FAIL=false
    STATUS=$(curl -s -X GET "http://${TARGET}:6707/status")
    if [ "$?" -ne 0 ]; then
        FAIL=true
    else
        STATUS=$(echo "$STATUS" | python3 -c "import json, sys; print(json.loads(sys.stdin.read())['status'])")
        if [ "$STATUS" == "ready" ]; then
            break
        elif [ "$STATUS" == "declined" ]; then
            echo "Declined"
            exit 1
        elif [ "$STATUS" == "failed" ]; then
            echo "Failed"
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

sshpass -p target scp -P 6708 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${FILEPATH}" "ubuntu@${TARGET}:/home/ubuntu/${FILENAME}"
if [ "$?" -ne 0 ]; then
    echo "Failed"
fi
STATUS=$(curl -s -X POST "http://${TARGET}:6707/close")
if [ "$?" -ne 0 ]; then
    echo "Failed"
    exit 1
fi
ERRORS=$(echo "$STATUS" | grep "\"error\"")
if [ "$?" -eq 0 ]; then
    echo "Failed"
    echo "Error: $(python3 -c "import json; print(json.loads('${ERRORS}')['error'])")" >&2
    exit 1
fi
echo "Complete"