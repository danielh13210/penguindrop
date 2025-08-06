#!/bin/bash
ip -br -f inet a | awk '$2 == "UP" {print $3}' | while read ip_connection; do
    ip_addr=$(echo "$ip_connection" | cut -d '/' -f1)
    nmap_output=$(nmap -sT -oG - -p 6707 "$ip_connection")
    echo "$nmap_output" | grep -P "Host:.*Ports: 6707/open/tcp" | awk '{print $2}' | uniq | grep -v "$ip_addr" | while read ip; do
        curl -s http://$ip:6707/privacy | python3 -c "import json,sys;exit(int(json.loads(sys.stdin.read())['privacy_mode']))" && echo -n "$ip "
        curl -s http://$ip:6707/name | python3 -c "import json,sys;print(json.loads(sys.stdin.read())['name'])"
    done
done