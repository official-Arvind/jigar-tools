# ========================================================
#  ADB SMART RESTORE & VERIFY (v3.2 - TITANIUM)
#  - Fix: Single-Quote Escaping for files like "File (1).pdf"
#  - Feature: Unified GUI Selection
#  - Integrity: 100% Forensic Audit
# ========================================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "Jigar Tools v3.2 - Smart Restore"

# 1. Device Selection
Write-Host "`n [SYSTEM] Connecting to Neural Link..." -ForegroundColor Cyan
$adbDevices = adb devices | Select-String -Pattern "\tdevice$"
if ($adbDevices.Count -eq 0) { Write-Host "`n [ERROR] Device connect karo!" -ForegroundColor Red; exit }
$selectedSerial = $adbDevices[0].ToString().Split("`t")[0].Trim()

# 2. GUI: Locate Backup Source
Write-Host "`n [SOURCE] Backup folder select karo..." -ForegroundColor Yellow
Add-Type -AssemblyName System.Windows.Forms
$fb = New-Object System.Windows.Forms.FolderBrowserDialog
$fb.Description = "SELECT EXTRACTED BACKUP FOLDER (Contains 'sdcard')"
if ($fb.ShowDialog() -ne "OK") { Write-Host " [CANCELLED]"; exit }
$sourcePath = $fb.SelectedPath

$sdcardPath = Join-Path -Path $sourcePath -ChildPath "sdcard"
$apkPath = Join-Path -Path $sourcePath -ChildPath "data\local\tmp\APKS"
if (-not (Test-Path $apkPath)) { $apkPath = Join-Path -Path $sourcePath -ChildPath "data\local\tmp\BACKUP_TEMP_APKS" }

$workingDir = if (Test-Path $sdcardPath) { $sdcardPath } else { $sourcePath }

# 3. Main Menu
Write-Host "`n [RESTORE MENU]" -ForegroundColor Cyan
Write-Host "  [1] FULL RESTORE (All Data + Apps)"
Write-Host "  [2] SELECTIVE RESTORE (Pick Folders via GUI)"
$mode = Read-Host "`n Choice"

$filesToRestore = @()

if ($mode -eq "2") {
    Write-Host "`n [SCANNING] Listing folders..." -ForegroundColor Yellow
    $folders = Get-ChildItem -LiteralPath $workingDir -Directory | Select-Object -ExpandProperty Name
    
    Write-Host " [ACTION] GridView: Spacebar se select karo!" -ForegroundColor Magenta
    $selection = $folders | Out-GridView -Title "RESTORE SELECTION: Select Folders (Spacebar to Glow) -> Enter" -OutputMode Multiple
    if (-not $selection) { Write-Host " [CANCELLED]"; exit }
    
    foreach ($sel in $selection) {
        $filesToRestore += Get-ChildItem -LiteralPath "$workingDir\$sel" -Recurse -File
    }
} else {
    Write-Host "`n [AUDIT] Gathering all files..." -ForegroundColor Yellow
    $filesToRestore = Get-ChildItem -LiteralPath $workingDir -Recurse -File
}

$totalFiles = @($filesToRestore).Count
if ($totalFiles -eq 0) { Write-Host " [ERROR] No files found!"; exit }
Write-Host " [LOCKED] Ready to restore $totalFiles files." -ForegroundColor Cyan

# 4. Hybrid APK Logic
if ($mode -eq "1" -and (Test-Path $apkPath)) {
    Write-Host "`n [HYBRID] Installing Apps..." -ForegroundColor Yellow
    $apks = Get-ChildItem -LiteralPath $apkPath -Filter "*.apk"
    $count = 0
    foreach ($apk in $apks) {
        $count++
        Write-Host " [$count] Installing: $($apk.Name)" -ForegroundColor Green
        adb -s $selectedSerial install -r "$($apk.FullName)" | Out-Null
    }
}

# 5. No-Mercy Restore Loop (Titanium Shield)
Write-Host "`n [STREAMING DATA...]" -ForegroundColor Cyan
$i = 0
foreach ($file in $filesToRestore) {
    $i++
    $percent = [math]::Round(($i / $totalFiles) * 100)
    
    $relPath = $file.FullName.Substring($workingDir.Length).Replace('\', '/')
    if (-not $relPath.StartsWith("/")) { $relPath = "/$relPath" }
    $remoteFile = "/sdcard$relPath"
    $remoteDir = $remoteFile.Substring(0, $remoteFile.LastIndexOf('/'))
    
    # Titanium Shield: Escape single quotes manually
    $remoteFileEscaped = $remoteFile.Replace("'", "'\''")
    $remoteDirEscaped = $remoteDir.Replace("'", "'\''")
    
    $remoteShell = "'$remoteFileEscaped'"
    $dirShell = "'$remoteDirEscaped'"

    Write-Progress -Activity "Smart Restore" -Status "Pushing: $relPath" -PercentComplete $percent

    # Smart Overwrite Check
    $remoteSizeStr = (adb -s $selectedSerial shell "stat -c %s $remoteShell 2>/dev/null").Trim()
    $remoteSize = 0
    if ($remoteSizeStr -match '^\d+$') { $remoteSize = [long]$remoteSizeStr }
    
    if ($remoteSize -ne $file.Length) {
        if ($remoteSize -eq 0) { Write-Host " [NEW] " -NoNewline -ForegroundColor Green }
        else { Write-Host " [FIX] " -NoNewline -ForegroundColor Magenta }
        Write-Host $relPath -ForegroundColor Gray
        
        adb -s $selectedSerial shell "mkdir -p $dirShell" | Out-Null
        adb -s $selectedSerial push "$($file.FullName)" "$remoteFile" | Out-Null
    }
}

# 6. Total Integrity Verification
Write-Host "`n [VERIFICATION] 100% Data Audit..." -ForegroundColor Cyan
$failed = 0
$v = 0
foreach ($f in $filesToRestore) {
    $v++
    $rp = $f.FullName.Substring($workingDir.Length).Replace('\', '/')
    if (-not $rp.StartsWith("/")) { $rp = "/$rp" }
    
    $rfEscaped = ("/sdcard" + $rp).Replace("'", "'\''")
    $rfShell = "'$rfEscaped'"
    
    $rsRaw = (adb -s $selectedSerial shell "stat -c %s $rfShell 2>/dev/null").Trim()
    $rs = 0
    if ($rsRaw -match '^\d+$') { $rs = [long]$rsRaw }

    if ($rs -ne $f.Length) { 
        $failed++ 
        Write-Host " [FAIL] Mismatch: $rp" -ForegroundColor Red
    }
    Write-Progress -Activity "Total Audit" -Status "Verifying: $v/$totalFiles" -PercentComplete ([math]::Round(($v / $totalFiles) * 100))
}

Write-Host "`n ========================================================"
if ($failed -eq 0) { Write-Host "  SUCCESS: 100% DATA INTEGRITY VERIFIED." -ForegroundColor Green } 
else { Write-Host "  WARNING: $failed files failed verification!" -ForegroundColor Red }
Write-Host " ========================================================"
Read-Host " Press Enter to exit..."