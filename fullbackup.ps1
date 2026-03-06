# ========================================================
#  ADB ULTIMATE GOD MODE (v19.2 - SMART GUI EDITION)
#  - Feature: Smart Units (Auto MB/GB formatting)
#  - Feature: Jigar Selector GUI (Checkboxes)
#  - Fix: Titanium Shield Quoting for spaces
# ========================================================

# 0. CUSTOM GUI & UTILS
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
    $listBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    foreach ($item in $Items) { [void]$listBox.Items.Add($item) }

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Location = New-Object System.Drawing.Point(340, 490)
    $btnOK.Text = "START NITRO"
    $btnOK.DialogResult = "OK"
    $btnOK.BackColor = [System.Drawing.Color]::DarkCyan
    $btnOK.ForeColor = [System.Drawing.Color]::White

    $form.Controls.AddRange(@($listBox, $btnOK))
    $form.AcceptButton = $btnOK
    if ($form.ShowDialog() -eq "OK") { return $listBox.CheckedItems }
    return $null
}

function Format-Bytes {
    param([double]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    return "{0:N2} KB" -f ($Bytes / 1KB)
}

# 1. SETUP
$env:ADB_LIBUSB = "1"
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "Jigar Tools v19.2 - Smart Backup"

$adbDevices = adb devices | Select-String -Pattern "\tdevice$"
if ($adbDevices.Count -eq 0) { Write-Host "`n [ERROR] Device connect karo!" -ForegroundColor Red; exit }
$selectedSerial = $adbDevices[0].ToString().Split("`t")[0].Trim()

# 2. INTELLIGENCE
$suCheck = adb -s $selectedSerial shell "which su" 2>$null
$hasRoot = ($suCheck -match "su")
$tarBin = "tar"
if ((adb -s $selectedSerial shell "which busybox") -match "busybox") { $tarBin = "busybox tar" }

# 3. MENU
Write-Host "`n [GOD MODE MENU]" -ForegroundColor Cyan
Write-Host "  [1] FULL NITRO (Everything + APKs)"
Write-Host "  [2] SELECTIVE (Checkbox GUI)"
$mode = Read-Host "`n Choice"

$targetFoldersString = "sdcard"
$selection = @()

if ($mode -eq "2") {
    Write-Host "`n [SCANNING] Loading folders..." -ForegroundColor Yellow
    $folderData = adb -s $selectedSerial shell "ls -p /sdcard | grep '/$'" | ForEach-Object { $_.TrimEnd('/') }
    
    $selection = Show-JigarSelector -Title "Select Folders" -Items $folderData
    if (-not $selection) { exit }
    
    # Titanium Shield Quoting
    $quotedFolders = $selection | ForEach-Object { "'sdcard/$_'" }
    $targetFoldersString = $quotedFolders -join " "
}

# 4. SMART AUDIT (MB/GB Logic)
Write-Host "`n [AUDIT] Calculating payload..." -ForegroundColor Yellow
$totalKB = 0
if ($mode -eq "1") {
    $sizeCmd = if ($hasRoot) { "su -c 'du -sk /sdcard/'" } else { "du -sk /sdcard/" }
    $sizeRaw = adb -s $selectedSerial shell "$sizeCmd" 2>$null
    if ($sizeRaw) { $totalKB = $sizeRaw.Split("`t")[0].Trim() }
} else {
    foreach ($folder in $selection) {
        $fCmd = if ($hasRoot) { "su -c 'du -sk ""/sdcard/$folder/""'" } else { "du -sk ""/sdcard/$folder/""" }
        $fRaw = adb -s $selectedSerial shell "$fCmd" 2>$null
        if ($fRaw) { $totalKB += [long]($fRaw.Split("`t")[0].Trim()) }
    }
}

$totalBytes = $totalKB * 1024
$displayTotal = Format-Bytes $totalBytes
Write-Host " [REPORT] Target Size: $displayTotal" -ForegroundColor Magenta

# 5. DESTINATION
$modelName = (adb -s $selectedSerial shell getprop ro.product.model).Trim() -replace '[\\/*?:"<>|]', "_"
$finalFileName = "${modelName}-v19.2-$(Get-Date -Format 'yyyy-MM-dd_HH-mm').tar"
Add-Type -AssemblyName System.Windows.Forms
$fb = New-Object System.Windows.Forms.FolderBrowserDialog
if ($fb.ShowDialog() -ne "OK") { exit }
$finalPath = Join-Path -Path $fb.SelectedPath -ChildPath $finalFileName

# 6. EXECUTION
Write-Host "`n --------------------------------------------------------"
Write-Host " NITRO STREAM ACTIVE | DESTINATION: $finalPath" -ForegroundColor Green
Write-Host " --------------------------------------------------------"

$shellCmd = ""
if ($mode -eq "1" -and $hasRoot) {
    $apkCmd = 'rm -rf /data/local/tmp/APKS; mkdir -p /data/local/tmp/APKS; pm list packages -3 | cut -f 2 -d ":" | while read pkg; do p=$(pm path $pkg | grep "base.apk" | cut -f 2 -d ":" | head -n 1); if [ -n "$p" ]; then ln -s "$p" "/data/local/tmp/APKS/$pkg.apk"; fi; done'
    adb -s $selectedSerial shell "su -c '$apkCmd'" | Out-Null
    $shellCmd = "su -c '$tarBin -h -cf - sdcard data/local/tmp/APKS'"
} else {
    $shellCmd = if ($hasRoot) { "su -c '$tarBin -cf - $targetFoldersString'" } else { "$tarBin -cf - $targetFoldersString" }
}

$cmdArgs = "/c adb -s $selectedSerial exec-out `"$shellCmd`" > `"$finalPath`""
$job = Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArgs -PassThru -NoNewWindow

# 7. MONITOR (Smart Display)
$start = Get-Date
$lastSize = 0
$stallCounter = 0
while (-not $job.HasExited) {
    if (Test-Path $finalPath) {
        $currSize = (Get-Item $finalPath).Length
        
        # Stall Detector
        if ($currSize -eq $lastSize -and $currSize -gt 0) {
            $stallCounter++
            if ($stallCounter -ge 15) { Stop-Process -Id $job.Id -Force; break }
        } else {
            $stallCounter = 0
            $speed = [math]::Round(($currSize / 1MB) / ((Get-Date) - $start).TotalSeconds, 2)
            $dispCurr = Format-Bytes $currSize
            
            # Clean Non-Bloated Progress
            Write-Progress -Activity "Nitro Streaming" -Status "Speed: $speed MB/s | $dispCurr / $displayTotal"
        }
        $lastSize = $currSize
    }
    Start-Sleep -Seconds 1
}

# 8. VERIFY
Write-Host "`n [SUCCESS] Stream Finished!" -ForegroundColor Green
Write-Host " [ACTION] Extract: $finalFileName" -ForegroundColor Cyan
Write-Host " [SYSTEM] Verifying..." -ForegroundColor Yellow

$pCount = 0
if ($mode -eq "1") {
    $pRaw = (adb -s $selectedSerial shell "find /sdcard -type f | wc -l").Trim()
    if ($pRaw -match '^\d+$') { $pCount = [int]$pRaw }
} else {
    foreach ($folder in $selection) {
        $cRaw = (adb -s $selectedSerial shell "find \`"/sdcard/$folder\`" -type f | wc -l").Trim()
        if ($cRaw -match '^\d+$') { $pCount += [int]$cRaw }
    }
}

$tCount = (tar -tf "$finalPath" | Measure-Object).Count

if ($tCount -ge ($pCount * 0.90)) {
    Write-Host "`n [OK] Verified! Phone: $pCount | Backup: $tCount" -ForegroundColor Green
} else {
    Write-Host "`n [!] Mismatch. Phone: $pCount | Backup: $tCount" -ForegroundColor Red
}

if ($hasRoot) { adb -s $selectedSerial shell "su -c 'rm -rf /data/local/tmp/APKS'" | Out-Null }
Read-Host "`n Done. Press Enter..."