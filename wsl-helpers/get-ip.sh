ip -br -json -4 addr show dev eth0 | python3 -c "import json;print(json.loads(input())[0]['addr_info'][0]['local'])"
