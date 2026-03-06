# ========================================================
#  JIGAR TOOLS: PARANOID VERIFIER (v3.4 - GUI EDITION)
#  - Feature: Checkbox Selection GUI
#  - Fix: Titanium Shield Quoting
# ========================================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "Jigar Tools v3.4 - Paranoid Verify"

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
    $btnOK.Text = "AUDIT"
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

Write-Host "`n [SOURCE] Select PC Folder to Verify..." -ForegroundColor Yellow
Add-Type -AssemblyName System.Windows.Forms
$fb = New-Object System.Windows.Forms.FolderBrowserDialog
if ($fb.ShowDialog() -ne "OK") { exit }
$localTarget = $fb.SelectedPath
$remoteBase = "/sdcard"
if ($localTarget -match "sdcard") {
    $rel = $localTarget.Substring($localTarget.IndexOf("sdcard") + 6).Replace('\', '/')
    $remoteBase = "/sdcard$rel"
}

# 2. SELECTION
Write-Host "`n [AUDIT MENU]" -ForegroundColor Cyan
Write-Host "  [1] VERIFY EVERYTHING"
Write-Host "  [2] SELECTIVE (GUI)"
$mode = Read-Host "`n Choice"

$itemsToScan = @()

if ($mode -eq "2") {
    Write-Host "`n [GUI] Opening Selector..." -ForegroundColor Yellow
    $dirs = Get-ChildItem -LiteralPath $localTarget -Directory | Select-Object -ExpandProperty Name
    $selection = Show-JigarSelector -Title "Verify Folders" -Items $dirs
    if (-not $selection) { exit }
    foreach ($sel in $selection) { $itemsToScan += Get-ChildItem -LiteralPath "$localTarget\$sel" -Recurse -File }
} else {
    $itemsToScan = Get-ChildItem -LiteralPath $localTarget -Recurse -File
}

$totalFiles = @($itemsToScan).Count
Write-Host "`n [LOCKED] Auditing $totalFiles files." -ForegroundColor Cyan

# 3. AUDIT LOOP
$valid = 0
$i = 0
foreach ($file in $itemsToScan) {
    $i++
    $percent = [math]::Round(($i / $totalFiles) * 100)
    $relPath = $file.FullName.Substring($localTarget.Length).Replace('\', '/')
    $remoteFile = "'$remoteBase$relPath'".Replace('//','/')

    Write-Progress -Activity "Verifying" -Status "$relPath" -PercentComplete $percent

    $rs = (adb -s $selectedSerial shell "stat -c %s $remoteFile 2>/dev/null").Trim()
    if ($rs -eq $file.Length) { $valid++ }
    else { Write-Host " [MISMATCH] $relPath" -ForegroundColor Red }
}
Write-Host "`n [REPORT] Verified Clean: $valid / $totalFiles" -ForegroundColor Green
Read-Host " Press Enter..."