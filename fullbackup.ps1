# ========================================================
#  ADB ULTIMATE GOD MODE (v18.9 - PS 5.1 STABLE)
#  - Fix: Triple-Quoting Shield for folders with spaces
#  - Fix: Unified Shell-Escaping for 'du', 'tar', and 'find'
#  - Feature: Real-time Progress vs Expected Size
# ========================================================

# 0. NITRO ENGINE SETUP
$env:ADB_LIBUSB = "1"
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "Jigar Tools v18.9 - Iron Shell Backup"

# 1. Device Selection
$adbDevices = adb devices | Select-String -Pattern "\tdevice$"
if ($adbDevices.Count -eq 0) { Write-Host "`n [ERROR] Device nahi mil raha, Arvind Ji!" -ForegroundColor Red; exit }
$selectedSerial = $adbDevices[0].ToString().Split("`t")[0].Trim()

# 2. System Intelligence
$suCheck = adb -s $selectedSerial shell "which su" 2>$null
$hasRoot = ($suCheck -match "su")
$tarBin = "tar"
if ((adb -s $selectedSerial shell "which busybox") -match "busybox") { $tarBin = "busybox tar" }

# 3. Main Menu & Selection
Write-Host "`n [GOD MODE MENU]" -ForegroundColor Cyan
Write-Host "  [1] FULL NITRO (Everything + APKs)"
Write-Host "  [2] SELECTIVE WEAPONS (Pick your folders)"
$mode = Read-Host "`n Choice"

$targetFoldersString = "sdcard"
$selection = @()
if ($mode -eq "2") {
    Write-Host "`n [SCANNING] Finding folders in /sdcard..." -ForegroundColor Yellow
    $folderData = adb -s $selectedSerial shell "ls -p /sdcard | grep '/$'" | ForEach-Object { $_.TrimEnd('/') }
    Write-Host " [ACTION] SPACEBAR se select (glow) karo, phir ENTER!" -ForegroundColor Magenta
    $selection = $folderData | Out-GridView -Title "Folders Chuno: Space to Select, ENTER to Confirm" -OutputMode Multiple
    if (-not $selection) { Write-Host " [CANCELLED] No selection."; exit }
    
    # Escape spaces for the main tar command
    $quotedFolders = $selection | ForEach-Object { "\`"sdcard/$_\`"" }
    $targetFoldersString = $quotedFolders -join " "
}

# 4. ROBUST DYNAMIC SIZE AUDIT
Write-Host "`n [AUDIT] Calculating true size of payload..." -ForegroundColor Yellow
$totalKB = 0
if ($mode -eq "1") {
    $sizeCmd = if ($hasRoot) { "su -c 'du -sk /sdcard/'" } else { "du -sk /sdcard/" }
    $sizeRaw = adb -s $selectedSerial shell "$sizeCmd" 2>$null
    if ($sizeRaw) { $totalKB = $sizeRaw.Split("`t")[0].Trim() }
} else {
    foreach ($folder in $selection) {
        # Using escaped quotes for remote shell
        $fCmd = if ($hasRoot) { "su -c 'du -sk \`"/sdcard/$folder/\`"'" } else { "du -sk \`"/sdcard/$folder/\`"" }
        $fRaw = adb -s $selectedSerial shell "$fCmd" 2>$null
        if ($fRaw) { $totalKB += [long]($fRaw.Split("`t")[0].Trim()) }
    }
}
$expectedGB = [math]::Round($totalKB / 1MB, 2)
Write-Host " [REPORT] Targeted Payload: $expectedGB GB" -ForegroundColor Magenta

# 5. Destination Setup
$modelName = (adb -s $selectedSerial shell getprop ro.product.model).Trim() -replace '[\\/*?:"<>|]', "_"
$finalFileName = "${modelName}-v18.9-$(Get-Date -Format 'yyyy-MM-dd_HH-mm').tar"
Add-Type -AssemblyName System.Windows.Forms
$fb = New-Object System.Windows.Forms.FolderBrowserDialog
if ($fb.ShowDialog() -ne "OK") { exit }
$finalPath = Join-Path -Path $fb.SelectedPath -ChildPath $finalFileName

# 6. Nitro Execution
Write-Host "`n --------------------------------------------------------"
Write-Host " NITRO STREAM ACTIVE | DESTINATION: $finalPath" -ForegroundColor Green
Write-Host " --------------------------------------------------------"

$shellCmd = ""
if ($mode -eq "1" -and $hasRoot) {
    $apkCmd = 'rm -rf /data/local/tmp/APKS; mkdir -p /data/local/tmp/APKS; pm list packages -3 | cut -f 2 -d ":" | while read pkg; do p=$(pm path $pkg | grep "base.apk" | cut -f 2 -d ":" | head -n 1); if [ -n "$p" ]; then ln -s "$p" "/data/local/tmp/APKS/$pkg.apk"; fi; done'
    adb -s $selectedSerial shell "su -c '$apkCmd'" | Out-Null
    $shellCmd = "su -c '$tarBin -h -cf - sdcard data/local/tmp/APKS'"
} else {
    # Applying Iron Shield Quoting to the main tar command
    $shellCmd = if ($hasRoot) { "su -c '$tarBin -cf - $targetFoldersString'" } else { "$tarBin -cf - $targetFoldersString" }
}

$cmdArgs = "/c adb -s $selectedSerial exec-out `"$shellCmd`" > `"$finalPath`""
$job = Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArgs -PassThru -NoNewWindow

# 7. Speed Monitor
$start = Get-Date
while (-not $job.HasExited) {
    if (Test-Path $finalPath) {
        $size = (Get-Item $finalPath).Length
        $speed = [math]::Round(($size / 1MB) / ((Get-Date) - $start).TotalSeconds, 2)
        $progStatus = "Speed: $speed MB/s | Progress: $([math]::Round($size/1GB, 2)) / $expectedGB GB"
        Write-Progress -Activity "Nitro Streaming" -Status $progStatus
    }
    Start-Sleep -Seconds 2
}

# 8. ASYNC RELEASE & AUDIT
Write-Host "`n [SUCCESS] Stream Finished!" -ForegroundColor Green
Write-Host " [ACTION] Bhai, ab file extract kar sakta hai: $finalFileName" -ForegroundColor Cyan
Write-Host " [SYSTEM] Verifying counts in background..." -ForegroundColor Yellow

$pCount = 0
if ($mode -eq "1") {
    $pCountRaw = (adb -s $selectedSerial shell "find /sdcard -type f | wc -l").Trim()
    if ($pCountRaw -match '^\d+$') { $pCount = [int]$pCountRaw }
} else {
    foreach ($folder in $selection) {
        # Using escaped quotes for find command
        $countRaw = (adb -s $selectedSerial shell "find \`"/sdcard/$folder\`" -type f | wc -l").Trim()
        if ($countRaw -match '^\d+$') { $pCount += [int]$countRaw }
    }
}

Write-Progress -Activity "Final Audit" -Status "Measuring Archive..."
$tCount = (tar -tf "$finalPath" | Measure-Object).Count

if ($tCount -ge ($pCount * 0.85) -and $tCount -gt 0) {
    Write-Host "`n [OK] Integrity Verified! Phone Files: $pCount | Backup Files: $tCount" -ForegroundColor Green
} else {
    Write-Host "`n [!] Integrity Alert! Expected $pCount but found $tCount. Check archive format." -ForegroundColor Red
}

if ($hasRoot) { adb -s $selectedSerial shell "su -c 'rm -rf /data/local/tmp/APKS'" | Out-Null }
Read-Host "`n System Stable. Press Enter to exit..."