#!/bin/bash
ip -br -f inet a | awk '$2 == "UP" {print $3}' | while read ip_connection; do
    ip_addr=$(echo "$ip_connection" | cut -d '/' -f1)
    nmap -sT -oG - --open -p 6707 --exclude "${ip_addr}" "$ip_connection" | awk '/Host:/{print $2}' | uniq | while read ip; do
        curl -s http://$ip:6707/privacy | python3 -c "import json,sys;exit(int(json.loads(sys.stdin.read())['privacy_mode']))" && echo -n "$ip "
        curl -s http://$ip:6707/name | python3 -c "import json,sys;print(json.loads(sys.stdin.read())['name'])"
    done
done
