#!/usr/bin/python3
import subprocess
import requests
discovery=subprocess.check_output(['avahi-browse','-rt','_penguindrop._sub._http._tcp'],text=True).splitlines()
headers=[]
for i in range(len(discovery)):
  if discovery[i].startswith('='):
    headers.append(i)
for i in headers:
  addr=discovery[i+2]
  addr=addr[addr.index('[')+1:addr.index(']')]
  if ':' in addr: # IPv6
    continue
  port=discovery[i+3]
  port=port[port.index('[')+1:port.index(']')]
  name=requests.get('http://'+addr+':'+port+'/name').json()['name']
  print(name,addr+':'+port)
