# ========================================================
#  ADB SMART RESTORE (v3.4 - GUI EDITION)
#  - Feature: Checkbox Selection GUI
#  - Fix: Titanium Shield Quoting
# ========================================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "Jigar Tools v3.4 - Smart Restore"

# GUI FUNCTION
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
function Show-JigarSelector {
    param([string]$Title, [array]$Items)
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size(500, 600)
    $form.StartPosition = "CenterScreen"
    $listBox = New-Object System.Windows.Forms.CheckedListBox
    $listBox.Location = New-Object System.Drawing.Point(20, 20)
    $listBox.Size = New-Object System.Drawing.Size(440, 450)
    $listBox.CheckOnClick = $true
    foreach ($item in $Items) { [void]$listBox.Items.Add($item) }
    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Location = New-Object System.Drawing.Point(340, 490)
    $btnOK.Text = "RESTORE"
    $btnOK.DialogResult = "OK"
    $form.Controls.AddRange(@($listBox, $btnOK))
    $form.AcceptButton = $btnOK
    if ($form.ShowDialog() -eq "OK") { return $listBox.CheckedItems }
    return $null
}

# 1. SETUP
Write-Host "`n [SYSTEM] Connecting..." -ForegroundColor Cyan
$adbDevices = adb devices | Select-String -Pattern "\tdevice$"
if ($adbDevices.Count -eq 0) { Write-Host " [ERROR] No device!" -ForegroundColor Red; exit }
$selectedSerial = $adbDevices[0].ToString().Split("`t")[0].Trim()

Write-Host "`n [SOURCE] Select Backup Folder..." -ForegroundColor Yellow
Add-Type -AssemblyName System.Windows.Forms
$fb = New-Object System.Windows.Forms.FolderBrowserDialog
if ($fb.ShowDialog() -ne "OK") { exit }
$sourcePath = $fb.SelectedPath
$restoreRoot = if (Test-Path "$sourcePath\sdcard") { "$sourcePath\sdcard" } else { $sourcePath }

# 2. SELECTION
Write-Host "`n [RESTORE MENU]" -ForegroundColor Cyan
Write-Host "  [1] FULL RESTORE"
Write-Host "  [2] SELECTIVE (Checkbox GUI)"
$mode = Read-Host "`n Choice"

$filesToPush = @()

if ($mode -eq "2") {
    Write-Host "`n [GUI] Opening Selector..." -ForegroundColor Yellow
    $dirs = Get-ChildItem -LiteralPath $restoreRoot -Directory | Select-Object -ExpandProperty Name
    $selection = Show-JigarSelector -Title "Restore Folders" -Items $dirs
    if (-not $selection) { exit }
    foreach ($sel in $selection) { $filesToPush += Get-ChildItem -LiteralPath "$restoreRoot\$sel" -Recurse -File }
} else {
    $filesToPush = Get-ChildItem -LiteralPath $restoreRoot -Recurse -File
}

$count = @($filesToPush).Count
if ($count -eq 0) { Write-Host " [ERROR] No files!"; exit }
Write-Host " [LOCKED] Restoring $count files..." -ForegroundColor Green

# 3. RESTORE LOOP
$i = 0
foreach ($file in $filesToPush) {
    $i++
    $percent = [math]::Round(($i / $count) * 100)
    $relPath = $file.FullName.Substring($restoreRoot.Length).Replace('\', '/')
    $remoteFile = "'/sdcard$relPath'"
    $remoteDir = "'/sdcard$($relPath.Substring(0, $relPath.LastIndexOf('/')))'"

    Write-Progress -Activity "Restoring" -Status "$relPath" -PercentComplete $percent
    
    $remoteSize = (adb -s $selectedSerial shell "stat -c %s $remoteFile 2>/dev/null").Trim()
    if ($remoteSize -ne $file.Length) {
        adb -s $selectedSerial shell "mkdir -p $remoteDir" | Out-Null
        adb -s $selectedSerial push "$($file.FullName)" "/sdcard$relPath" | Out-Null
    }
}
Write-Host "`n [SUCCESS] Done." -ForegroundColor Green
Read-Host " Press Enter..."