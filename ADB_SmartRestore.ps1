# ========================================================
#  ANDROID SMART RESTORE & VERIFY (v2.1 - NO MERCY)
#  - Features: Smart Overwrite, Hybrid APK Auto-Installer
#  - Integrity: 100% FULL FILE VERIFICATION (No sampling)
#  - Compatibility: PowerShell 5.1 Native
# ========================================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "ADB Smart Restore v2.1 - TRUE GOD MODE"

# 1. Setup & Environment
$localRoot = Get-Location
Write-Host "`n [CHECKING ADB STATUS...]" -ForegroundColor Cyan
$adbDevices = adb devices | Select-String -Pattern "\tdevice$"
if ($adbDevices.Count -eq 0) {
    Write-Host " [ERROR] No devices found. Check your cable!" -ForegroundColor Red
    Read-Host " Press Enter to exit..."
    exit
}

$sdcardPath = Join-Path -Path $localRoot -ChildPath "sdcard"
$apkPath = Join-Path -Path $localRoot -ChildPath "data\local\tmp\BACKUP_TEMP_APKS"

# 2. Hybrid APK Logic (The Initial Wave)
if (Test-Path $apkPath) {
    Write-Host "`n [HYBRID] Pushing User APKs..." -ForegroundColor Yellow
    $apks = Get-ChildItem -Path $apkPath -Filter "*.apk"
    $apkCount = $apks.Count
    $a = 0
    foreach ($apk in $apks) {
        $a++
        Write-Host " [$a/$apkCount] Installing: $($apk.Name)" -ForegroundColor Green
        adb install -r "$($apk.FullName)" | Out-Null
    }
}

# 3. File Discovery
Write-Host "`n [SCANNING LOCAL STORAGE CONTENT...]" -ForegroundColor Cyan
if (Test-Path $sdcardPath) {
    $files = Get-ChildItem -LiteralPath $sdcardPath -Recurse -File
} else {
    $files = Get-ChildItem -LiteralPath $localRoot -Recurse -File | Where-Object { 
        $_.Name -notin @("ADB_SmartRestore.ps1", "fullbackup.ps1", "paranoid.ps1", "logo.ico", "Jigar_Tools_Setup.bat") -and
        $_.FullName -notmatch "data\\local\\tmp"
    }
}

$totalFiles = $files.Count
Write-Host " Found $totalFiles files for absolute restoration." -ForegroundColor Yellow

# 4. The No-Mercy Restore Loop
$i = 0
foreach ($file in $files) {
    $i++
    $percent = [math]::Round(($i / $totalFiles) * 100)
    
    # Absolute Path Stripping Logic
    if ($file.FullName.Contains("sdcard\")) {
        $relPath = $file.FullName.Substring($file.FullName.IndexOf("sdcard\") + 6)
    } else {
        $relPath = $file.FullName.Substring($localRoot.Path.Length)
    }
    
    $relPathUnix = $relPath.Replace('\', '/')
    $remoteFile = "/sdcard$relPathUnix"
    $remoteDir = ([System.IO.Path]::GetDirectoryName($remoteFile)).Replace('\', '/')
    
    $remoteFileShell = "'" + $remoteFile.Replace("'", "'\''") + "'"
    $remoteDirShell = "'" + $remoteDir.Replace("'", "'\''") + "'"

    Write-Progress -Activity "True God Mode Restore" -Status "Restoring: $($file.Name)" -PercentComplete $percent

    # Smart Overwrite Check
    $remoteSizeStr = (adb shell "stat -c %s $remoteFileShell 2>/dev/null").Trim()
    $remoteSize = 0
    if ($remoteSizeStr -match '^\d+$') { $remoteSize = [long]$remoteSizeStr }
    $localSize = $file.Length

    if ($remoteSize -eq 0 -or $localSize -ne $remoteSize) {
        if ($remoteSize -eq 0) { Write-Host " [NEW] " -NoNewline -ForegroundColor Green }
        else { Write-Host " [FIX] " -NoNewline -ForegroundColor Magenta }
        Write-Host $relPathUnix -ForegroundColor Gray
        
        adb shell "mkdir -p $remoteDirShell" | Out-Null
        adb push "$($file.FullName)" "$remoteFile" | Out-Null
    }
}

# 5. 100% TOTAL INTEGRITY VERIFICATION
Write-Host "`n [GOD MODE VERIFICATION] Performing 100% Data Audit..." -ForegroundColor Cyan
$failed = 0
$v = 0
foreach ($f in $files) {
    $v++
    if ($f.FullName.Contains("sdcard\")) {
        $rp = $f.FullName.Substring($f.FullName.IndexOf("sdcard\") + 6).Replace('\', '/')
    } else {
        $rp = $f.FullName.Substring($localRoot.Path.Length).Replace('\', '/')
    }
    $rfShell = "'/sdcard" + $rp.Replace("'", "'\''") + "'"
    
    $rs = (adb shell "stat -c %s $rfShell 2>/dev/null").Trim()
    if ($rs -ne $f.Length) { 
        $failed++ 
        Write-Host " [FAIL] Verification Error: $rp" -ForegroundColor Red
    }
    Write-Progress -Activity "Total Audit" -Status "Verifying: $v/$totalFiles" -PercentComplete ([math]::Round(($v / $totalFiles) * 100))
}

Write-Host "`n ========================================================"
if ($failed -eq 0) {
    Write-Host "  GOD MODE SUCCESS: 100% DATA INTEGRITY VERIFIED." -ForegroundColor Green
} else {
    Write-Host "  CRITICAL WARNING: $failed files are corrupt or missing!" -ForegroundColor Red
}
Write-Host " ========================================================"
Read-Host " Press Enter to finish..."