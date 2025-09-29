# Define script content that clears the cache
$clearScript = @'
$cachePath = Join-Path $env:USERPROFILE "AppData\Roaming\stremio\stremio-server\stremio-cache"
if (Test-Path $cachePath) {
    Remove-Item -Path $cachePath\* -Recurse -Force -ErrorAction SilentlyContinue
}
'@

# Path to store the actual cleanup script
$scriptPath = "$env:ProgramData\Clear-StremioCache.ps1"
Set-Content -Path $scriptPath -Value $clearScript -Force -Encoding UTF8

# Define scheduled task action
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# Trigger: at user logon
$trigger = New-ScheduledTaskTrigger -AtLogOn

# Task settings
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest

$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries)

# Register the task
Register-ScheduledTask -TaskName "Clear Stremio Cache" -InputObject $task -Force
