# ========================================================
#  ADB SMART RESTORE & VERIFY (v3.0 - NO MERCY)
#  - Feature: Interactive GridView for Selective Restore
#  - UI: FolderBrowserDialog to locate extracted backup
#  - Fix: Iron-Shield quoting for spaces in Android shell
# ========================================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "Jigar Tools v3.0 - No Mercy Restore"

# 1. Device Selection
$adbDevices = adb devices | Select-String -Pattern "\tdevice$"
if ($adbDevices.Count -eq 0) { Write-Host "`n [ERROR] Device connect karo, Arvind Ji!" -ForegroundColor Red; exit }
$selectedSerial = $adbDevices[0].ToString().Split("`t")[0].Trim()

# 2. Locate Backup Source
Write-Host "`n [SOURCE] Extracted backup folder select karo..." -ForegroundColor Cyan
Add-Type -AssemblyName System.Windows.Forms
$fb = New-Object System.Windows.Forms.FolderBrowserDialog
$fb.Description = "Select your EXTRACTED backup folder (where 'sdcard' is located)"
if ($fb.ShowDialog() -ne "OK") { Write-Host " [CANCELLED]"; exit }
$sourcePath = $fb.SelectedPath

$sdcardPath = Join-Path -Path $sourcePath -ChildPath "sdcard"
$apkPath = Join-Path -Path $sourcePath -ChildPath "data\local\tmp\APKS"
if (-not (Test-Path $apkPath)) { $apkPath = Join-Path -Path $sourcePath -ChildPath "data\local\tmp\BACKUP_TEMP_APKS" }

$workingDir = if (Test-Path $sdcardPath) { $sdcardPath } else { $sourcePath }

# 3. Main Menu
Write-Host "`n [RESTORE MENU]" -ForegroundColor Cyan
Write-Host "  [1] FULL RESTORE (Everything + APKs)"
Write-Host "  [2] SELECTIVE RESTORE (Pick your folders)"
$mode = Read-Host "`n Choice"

$filesToRestore = @()

if ($mode -eq "2") {
    Write-Host "`n [SCANNING] Finding folders in $workingDir..." -ForegroundColor Yellow
    $folders = Get-ChildItem -LiteralPath $workingDir -Directory | Select-Object -ExpandProperty Name
    if (-not $folders) { Write-Host " [ERROR] Folders nahi mile!"; exit }
    
    Write-Host " [ACTION] SPACEBAR dabao highlight (glow) karne ke liye!" -ForegroundColor Magenta
    $selection = $folders | Out-GridView -Title "Folders Chuno: Space to Select, ENTER to Confirm" -OutputMode Multiple
    if (-not $selection) { Write-Host " [CANCELLED]"; exit }
    
    Write-Host " [AUDIT] Gathering files..." -ForegroundColor Yellow
    foreach ($sel in $selection) {
        $filesToRestore += Get-ChildItem -LiteralPath "$workingDir\$sel" -Recurse -File
    }
} else {
    Write-Host "`n [AUDIT] Gathering all files..." -ForegroundColor Yellow
    $filesToRestore = Get-ChildItem -LiteralPath $workingDir -Recurse -File
}

$totalFiles = @($filesToRestore).Count
if ($totalFiles -eq 0) { Write-Host " [ERROR] Restore karne ke liye koi files nahi hain!"; exit }
Write-Host " [REPORT] Found $totalFiles files for absolute restoration." -ForegroundColor Magenta

# 4. Hybrid APK Logic
if ($mode -eq "1" -and (Test-Path $apkPath)) {
    Write-Host "`n [HYBRID] Pushing User APKs..." -ForegroundColor Yellow
    $apks = Get-ChildItem -LiteralPath $apkPath -Filter "*.apk"
    $apkCount = $apks.Count
    $a = 0
    foreach ($apk in $apks) {
        $a++
        Write-Host " [$a/$apkCount] Installing: $($apk.Name)" -ForegroundColor Green
        adb -s $selectedSerial install -r "$($apk.FullName)" | Out-Null
    }
}

# 5. No-Mercy Push Loop (Space-Proof)
Write-Host "`n [RESTORING DATA...]" -ForegroundColor Cyan
$i = 0
foreach ($file in $filesToRestore) {
    $i++
    $percent = [math]::Round(($i / $totalFiles) * 100)
    
    $relPath = $file.FullName.Substring($workingDir.Length).Replace('\', '/')
    if (-not $relPath.StartsWith("/")) { $relPath = "/$relPath" }
    $remoteFile = "/sdcard$relPath"
    
    # Safe remote directory extraction
    $remoteDir = $remoteFile.Substring(0, $remoteFile.LastIndexOf('/'))
    if ($remoteDir -eq "") { $remoteDir = "/sdcard" }

    # Iron-Shield Quoting
    $remoteFileShell = "`"$remoteFile`""
    $remoteDirShell = "`"$remoteDir`""

    Write-Progress -Activity "True God Mode Restore" -Status "Pushing: $($file.Name)" -PercentComplete $percent

    $remoteSizeStr = (adb -s $selectedSerial shell "stat -c %s $remoteFileShell 2>/dev/null").Trim()
    $remoteSize = 0
    if ($remoteSizeStr -match '^\d+$') { $remoteSize = [long]$remoteSizeStr }
    
    if ($remoteSize -eq 0 -or $file.Length -ne $remoteSize) {
        if ($remoteSize -eq 0) { Write-Host " [NEW] " -NoNewline -ForegroundColor Green }
        else { Write-Host " [FIX] " -NoNewline -ForegroundColor Magenta }
        Write-Host $relPath -ForegroundColor Gray
        
        adb -s $selectedSerial shell "mkdir -p $remoteDirShell" | Out-Null
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
    $rfShell = "`"/sdcard$rp`""
    
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
Read-Host " Press Enter to finish..."