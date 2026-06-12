$sandboxDir = Join-Path $env:TEMP "JigarSandbox_Test"
if (Test-Path $sandboxDir) { Remove-Item $sandboxDir -Recurse -Force }
New-Item -ItemType Directory -Path $sandboxDir | Out-Null
Copy-Item "d:\Desktop\jigar-tools\Jigar_Tools_Setup.bat" $sandboxDir
Copy-Item "d:\Desktop\jigar-tools\JigarSmartSync.ps1" $sandboxDir
Copy-Item "d:\Desktop\jigar-tools\JigarSmartRestore.ps1" $sandboxDir
Set-Content -Path (Join-Path $sandboxDir ".version") -Value "v0.1"

# We must bypass UAC check in the sandbox file.
$batPath = Join-Path $sandboxDir "Jigar_Tools_Setup.bat"
$batContent = Get-Content $batPath
$batContent = $batContent -replace 'goto :Relaunch', 'rem goto :Relaunch'
$batContent = $batContent -replace 'Start-Process cmd', 'rem Start-Process cmd'
# Create dummy shortcut so it skips setup
$dummyLnk = Join-Path $sandboxDir "Jigar Tools.lnk"
New-Item -ItemType File -Path $dummyLnk | Out-Null
$batContent = $batContent -replace 'set "SHORTCUT=.*"', ("set `"SHORTCUT=$dummyLnk`"")
Set-Content -Path $batPath -Value $batContent

Write-Host "Running bat..."
"4`nY`n5" | & cmd /c $batPath
Write-Host "Done"
