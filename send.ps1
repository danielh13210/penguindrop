# Get the full Windows path to the script
$sendSHPath = Join-Path "$PSScriptRoot" "send.sh"
$sendSHPath = $sendSHPath -replace '\\', '/'

# Convert it to a WSL path
$wslPath = wsl wslpath "$sendSHPath"


# Call the send.sh script in WSL
$ConvertedPath = "$($args[1])" -replace '\\', '/'
wsl bash "$wslPath" "$($args[0])" $ConvertedPath
