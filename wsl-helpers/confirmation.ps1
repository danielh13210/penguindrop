$FileName=$($args[0])
$Key=$($args[1])
$SourceComputerName=$($args[2])

Import-Module BurntToast

# Create text elements
$t1 = New-BTText -Content 'File Sharing'
$t2 = New-BTText -Content "$SourceComputerName would like to share you $FileName"

# Create binding and visual
$binding = New-BTBinding -Children $t1, $t2
$visual = New-BTVisual -BindingGeneric $binding

$EncodedKey = [System.Web.HttpUtility]::UrlEncode($Key)

# Create buttons
$btn1 = New-BTButton -Content 'Accept' -Arguments "http://localhost:6707/confirm.html?key=$EncodedKey&accepted=true"
$btn2 = New-BTButton -Content 'Decline' -Arguments "http://localhost:6707/confirm.html?key=$EncodedKey&accepted=false"


# Wrap buttons in actions
$actions = New-BTAction -Buttons $btn1,$btn2

# Create toast content with visual and actions
$content = New-BTContent -Visual $visual -Actions $actions

# Submit the toast
Submit-BTNotification -Content $content
