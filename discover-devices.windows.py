#!/usr/bin/python3
import subprocess
import requests
discovery=subprocess.check_output(['powershell.exe','-Command','$p = Start-Process dns-sd -ArgumentList "-B _http._tcp,_penguindrop local" -PassThru -NoNewWindow -RedirectStandardOutput "out.txt"; Start-Sleep -Seconds 3; Stop-Process -Id $p.Id -Force; Get-Content out.txt; Remove-Item out.txt'],text=True).splitlines()
discovery=discovery[2:]
instances=set()
for entry in discovery:
  entry=entry.split()
  instance=entry[-1]
  instances.add(instance)
hosts={}
for instance in instances:
  discovery=subprocess.check_output(['powershell.exe','-Command',f'$p = Start-Process dns-sd -ArgumentList "-L {instance} _http._tcp local" -PassThru -NoNewWindow -RedirectStandardOutput "out.txt"; Start-Sleep -Seconds 3; Stop-Process -Id $p.Id -Force; Get-Content out.txt; Remove-Item out.txt'],text=True).splitlines()
  discovery=discovery[1:]
  result_groups=[]
  for entry in discovery:
    if entry[0]==' ':
      result_groups[-1].append(entry)
    else:
      result_groups.append([entry.split()[6]])
  for group in result_groups:
    splits=group[0].split(':')
    host=':'.join(splits[:-1])
    port=splits[-1]
    sshport=group[1][9:]
    hosts[host]=(port,sshport)
ip_hosts={}
for host,ports in hosts.items():
  discovery=subprocess.check_output(['powershell.exe','-Command',f'$p = Start-Process dns-sd -ArgumentList "-G v4 {host}" -PassThru -NoNewWindow -RedirectStandardOutput "out.txt"; Start-Sleep -Seconds 3; Stop-Process -Id $p.Id -Force; Get-Content out.txt; Remove-Item out.txt'],text=True).splitlines()
  discovery=discovery[1:]
  for entry in discovery:
    ip=entry.split()[5]
    ip_hosts[ip]=ports
for addr,(port,sshport) in ip_hosts.items():
  name=requests.get('http://'+addr+':'+port+'/name').json()['name']
  print(name,addr+':'+port,addr+':'+sshport)

