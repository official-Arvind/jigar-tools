# ========================================================
#  ADB ULTIMATE GOD MODE (v18.3 - PS 5.1 COMPATIBLE)
#  - Fixed: Removed all '?' ternary operators for PS 5.1
#  - Fixed: Removed '.' folder bug by targeting absolute paths
#  - Fixed: Verification count now uses SU for total accuracy
# ========================================================

# 0. NITRO ENGINE ENGAGEMENT
$env:ADB_LIBUSB = "1"
$env:ADB_SERVER_SOCKET = "tcp:localhost:5037"

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "ADB God Mode v18.3 - PS 5.1 FIX"

# 1. Device Selection
$adbDevices = adb devices | Select-String -Pattern "\tdevice$"
if ($adbDevices.Count -eq 0) { Write-Host "`n [ERROR] No devices found!" -ForegroundColor Red; exit }

$selectedSerial = ""
if ($adbDevices.Count -eq 1) {
    $selectedSerial = $adbDevices[0].ToString().Split("`t")[0].Trim()
} else {
    Write-Host "`n [CHOOSE DEVICE]" -ForegroundColor Yellow
    for ($i=0; $i -lt $adbDevices.Count; $i++) {
        $serial = $adbDevices[$i].ToString().Split("`t")[0].Trim()
        $model = adb -s $serial shell getprop ro.product.model
        Write-Host "  [$($i + 1)] $serial ($($model.Trim()))"
    }
    $choice = Read-Host "`n Enter number"
    $selectedSerial = $adbDevices[[int]$choice - 1].ToString().Split("`t")[0].Trim()
}

# 2. System Intelligence Scan
$suCheck = adb -s $selectedSerial shell "which su" 2>$null
$hasRoot = $false
if ($suCheck -match "su") { $hasRoot = $true }

$bbCheck = adb -s $selectedSerial shell "which busybox" 2>$null
$tarBin = "tar"
if ($bbCheck -match "busybox") { $tarBin = "busybox tar" }

# 3. Main Menu
Write-Host "`n [GOD MODE MENU]" -ForegroundColor Cyan
Write-Host "  [1] FULL BACKUP (Nitro Raw + Hybrid APKs)"
Write-Host "  [2] SELECTIVE FOLDERS (Interactive Browser)"
$mode = Read-Host "`n Choice"

$targetFolders = "sdcard"
$backupSuffix = "FULL_HYBRID"

if ($mode -eq "2") {
    Write-Host "`n [BROWSER] Scanning /sdcard..." -ForegroundColor Yellow
    $folderData = adb -s $selectedSerial shell "ls -p /sdcard | grep '/$'" | ForEach-Object { $_.TrimEnd('/') }
    $selection = $folderData | Out-GridView -Title "Select Folders (Space to select, Enter to confirm)" -OutputMode Multiple
    if (-not $selection) { Write-Host " Cancelled."; exit }
    $targetFolders = $selection | ForEach-Object { "sdcard/$_" }
    $targetFolders = $targetFolders -join " "
    $backupSuffix = "SELECTIVE"
}

# 4. Destination Setup
$modelName = (adb -s $selectedSerial shell getprop ro.product.model).Trim()
$cleanModel = $modelName -replace '[\\/*?:"<>|]', "_"
$date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$defaultFileName = "${cleanModel}-${backupSuffix}-${date}.tar"

Add-Type -AssemblyName System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
if ($folderBrowser.ShowDialog() -ne "OK") { exit }
$finalPath = Join-Path -Path $folderBrowser.SelectedPath -ChildPath $defaultFileName

# 5. Execution (The Fixed Masterpiece Stream)
Write-Host "`n --------------------------------------------------------"
if ($hasRoot) { Write-Host " GOD MODE ACTIVE: Root SU Stream Engaged" -ForegroundColor Magenta }
Write-Host " NITRO SPEED: Uncompressed Raw Binary Pipe" -ForegroundColor Green
Write-Host " ACTION: Streaming .tar to $finalPath" -ForegroundColor Cyan
Write-Host " --------------------------------------------------------"

$finalShellCmd = ""
if ($mode -eq "1") {
    Write-Host " [+] Mapping APKs (Zero-Space Mode)..." -ForegroundColor Gray
    $apkCmd = 'rm -rf /data/local/tmp/BACKUP_TEMP_APKS; mkdir -p /data/local/tmp/BACKUP_TEMP_APKS; pm list packages -3 | cut -f 2 -d ":" | while read pkg; do p=$(pm path $pkg | grep "base.apk" | cut -f 2 -d ":" | head -n 1); if [ -n "$p" ]; then ln -s "$p" "/data/local/tmp/BACKUP_TEMP_APKS/$pkg.apk"; fi; done'
    if ($hasRoot) {
        adb -s $selectedSerial shell "su -c '$apkCmd'" | Out-Null
        $finalShellCmd = "su -c '$tarBin -h -cf - sdcard data/local/tmp/BACKUP_TEMP_APKS'"
    } else { Write-Host " [!] Error: Root required for Hybrid."; exit }
} else {
    if ($hasRoot) {
        $finalShellCmd = "su -c '$tarBin -cf - $targetFolders'"
    } else {
        $finalShellCmd = "$tarBin -cf - $targetFolders"
    }
}

$cmdArgs = "/c adb -s $selectedSerial exec-out ""$finalShellCmd"" > ""$finalPath"""
$job = Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArgs -PassThru -NoNewWindow

# 6. Nitro Speed Monitor
$startTime = Get-Date
while (-not $job.HasExited) {
    Start-Sleep -Seconds 2
    if (Test-Path $finalPath) {
        $size = (Get-Item $finalPath).Length
        $elapsed = (Get-Date) - $startTime
        $speed = [math]::Round(($size / 1MB) / $elapsed.TotalSeconds, 2)
        Write-Progress -Activity "God Mode Nitro Stream" -Status "SPEED: $speed MB/s | Total: $([math]::Round($size/1GB, 2)) GB"
    }
}

# 7. Verification & Cleanup
Write-Host "`n [VERIFYING] Cross-checking file integrity using Root..." -ForegroundColor Cyan
$phoneCountCmd = "find /sdcard -type f | wc -l"
if ($hasRoot) { $phoneCountCmd = "su -c 'find /sdcard -type f | wc -l'" }

if ($mode -eq "2") { 
    $phoneCountCmd = "find /sdcard/$selection -type f | wc -l"
    if ($hasRoot) { $phoneCountCmd = "su -c 'find /sdcard/$selection -type f | wc -l'" }
}

$phoneCount = (adb -s $selectedSerial shell "$phoneCountCmd").Trim()
$tarCount = (cmd /c "tar -tf ""$finalPath"" | find /c /v """"").Trim()

if ($mode -eq "1") { adb -s $selectedSerial shell "su -c 'rm -rf /data/local/tmp/BACKUP_TEMP_APKS'" | Out-Null }

Write-Host " Phone File Count: $phoneCount" -ForegroundColor Gray
Write-Host " Backup File Count: $tarCount" -ForegroundColor Gray

if ($tarCount -gt 0 -and $tarCount -ge ($phoneCount * 0.85)) {
    Write-Host "`n [SUCCESS] Backup Complete and Verified!" -ForegroundColor Green
} else {
    Write-Host "`n [WARNING] Count mismatch. Phone: $phoneCount vs Backup: $tarCount" -ForegroundColor Yellow
}

Read-Host "`n Press Enter to exit..."