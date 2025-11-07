$WshShell = New-Object -ComObject WScript.Shell

# Define shortcut path and target
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\pdserver.lnk"
$targetPath = "powershell.exe"
$arguments = "-WindowStyle Hidden -Command wsl.exe bash $($args[0])"

# Create the shortcut
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.Arguments = $arguments
$shortcut.WorkingDirectory = "$env:USERPROFILE"
$shortcut.Save()
