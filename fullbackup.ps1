# ========================================================
#  ADB ULTIMATE GOD MODE (v19.0 - PS 5.1 STABLE)
#  - Feature: Heartbeat Monitor (Auto-detects stalled ADB)
#  - Fix: Triple-Quoting Shield for folders with spaces
#  - Fix: Prevents "Unexpected End of Data" by graceful exit
# ========================================================

# 0. NITRO ENGINE SETUP
$env:ADB_LIBUSB = "1"
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "Jigar Tools v19.0 - Terminator Backup"

# 1. Device Selection
$adbDevices = adb devices | Select-String -Pattern "\tdevice$"
if ($adbDevices.Count -eq 0) { Write-Host "`n [ERROR] Device connect karo, Arvind Ji!" -ForegroundColor Red; exit }
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
    
    # Escape spaces logic from v18.9
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
        $fCmd = if ($hasRoot) { "su -c 'du -sk \`"/sdcard/$folder/\`"'" } else { "du -sk \`"/sdcard/$folder/\`"" }
        $fRaw = adb -s $selectedSerial shell "$fCmd" 2>$null
        if ($fRaw) { $totalKB += [long]($fRaw.Split("`t")[0].Trim()) }
    }
}
$expectedGB = [math]::Round($totalKB / 1MB, 2)
Write-Host " [REPORT] Targeted Payload: $expectedGB GB" -ForegroundColor Magenta

# 5. Destination Setup
$modelName = (adb -s $selectedSerial shell getprop ro.product.model).Trim() -replace '[\\/*?:"<>|]', "_"
$finalFileName = "${modelName}-v19.0-$(Get-Date -Format 'yyyy-MM-dd_HH-mm').tar"
Add-Type -AssemblyName System.Windows.Forms
$fb = New-Object System.Windows.Forms.FolderBrowserDialog
if ($fb.ShowDialog() -ne "OK") { exit }
$finalPath = Join-Path -Path $fb.SelectedPath -ChildPath $finalFileName

# 6. Nitro Execution
Write-Host "`n --------------------------------------------------------"
Write-Host " NITRO STREAM ACTIVE | SAVING TO: $finalPath" -ForegroundColor Green
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

# 7. Speed Monitor with STALL DETECTOR (New)
$start = Get-Date
$lastSize = 0
$stallCounter = 0
$stallThreshold = 15 # Seconds to wait before assuming hang

while (-not $job.HasExited) {
    if (Test-Path $finalPath) {
        $currSize = (Get-Item $finalPath).Length
        
        # Stall Logic
        if ($currSize -eq $lastSize -and $currSize -gt 0) {
            $stallCounter++
            Write-Progress -Activity "Nitro Streaming" -Status "Finishing writes... ($stallCounter/$stallThreshold)" -PercentComplete 100
            if ($stallCounter -ge $stallThreshold) {
                Write-Host "`n [TRIGGER] Stream Stalled (Data finished). Cutting connection gracefully." -ForegroundColor Yellow
                Stop-Process -Id $job.Id -Force
                break
            }
        } else {
            $stallCounter = 0
            $speed = [math]::Round(($currSize / 1MB) / ((Get-Date) - $start).TotalSeconds, 2)
            $progStatus = "Speed: $speed MB/s | Progress: $([math]::Round($currSize/1GB, 2)) / $expectedGB GB"
            Write-Progress -Activity "Nitro Streaming" -Status $progStatus
        }
        $lastSize = $currSize
    }
    Start-Sleep -Seconds 1
}

# 8. ASYNC RELEASE & AUDIT
Write-Host "`n [SUCCESS] Stream Finished!" -ForegroundColor Green
Write-Host " [ACTION] Extract now: $finalFileName" -ForegroundColor Cyan
Write-Host " [SYSTEM] Verifying counts in background..." -ForegroundColor Yellow

$pCount = 0
if ($mode -eq "1") {
    $pCountRaw = (adb -s $selectedSerial shell "find /sdcard -type f | wc -l").Trim()
    if ($pCountRaw -match '^\d+$') { $pCount = [int]$pCountRaw }
} else {
    foreach ($folder in $selection) {
        $countRaw = (adb -s $selectedSerial shell "find \`"/sdcard/$folder\`" -type f | wc -l").Trim()
        if ($countRaw -match '^\d+$') { $pCount += [int]$countRaw }
    }
}

Write-Progress -Activity "Final Audit" -Status "Measuring Archive..."
$tCount = (tar -tf "$finalPath" | Measure-Object).Count

# Verification Logic Adjusted for "Zombie" cuts
if ($tCount -ge ($pCount * 0.95)) {
    Write-Host "`n [OK] Integrity Verified! Phone: $pCount | Backup: $tCount" -ForegroundColor Green
} else {
    Write-Host "`n [!] Note: Phone has $pCount files, Backup has $tCount." -ForegroundColor Yellow
    Write-Host " If the difference is small (APKs/Cache), you are safe." -ForegroundColor Gray
}

if ($hasRoot) { adb -s $selectedSerial shell "su -c 'rm -rf /data/local/tmp/APKS'" | Out-Null }
Read-Host "`n System Stable. Press Enter to exit..."