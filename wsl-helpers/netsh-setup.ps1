# Ensure WSL distro is started
wsl -d "{{DISTRO_NAME}}" -e /bin/true

# Loop until WSL reports a valid IP
$WSLIP = ""
$success = $false

for ($i = 0; $i -lt 10; $i++) {
    $WSLIP = (wsl -d "{{DISTRO_NAME}}" -- ~/.local/share/penguindrop/wsl-helpers/get-ip.sh).Trim()
    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($WSLIP)) {
        $success = $true
        break
    }
    Write-Output "Attempt $($i+1): No IP yet, retrying..."
    Start-Sleep -Seconds 2
}

#if failed exit with failure code
if (-not $success) {
    exit 1
}

netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=6707
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=6708
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=6707 connectaddress=$WSLIP connectport=6707
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=6708 connectaddress=$WSLIP connectport=6708
exit 0