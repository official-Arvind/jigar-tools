@echo off
setlocal enabledelayedexpansion
:: ========================================================
::  JIGAR TOOLS - UNIFIED GOD MODE (v2.0 Gold Edition)
::  NEW in v2.0 Gold Edition:
::  - 20x Parallel Titan Engine (Sync/Restore)
::  - Real-time Speed & Size Progress Bar
::  - Robust Phone Scanning Pipeline (xargs)
::  - Auto-Updater & Clean Exit (No ADB memory leaks)
:: ========================================================

:: ---- 1. ADMIN ELEVATION --------------------------------
net session >nul 2>&1
if %errorLevel% neq 0 goto :Relaunch

:: ---- 2. DIRECTORY & ASSET LOCK ------------------------
cd /d "%~dp0"
set "TOOLS_DIR=%CD%"
set "ICON_FILE=%TOOLS_DIR%\logo.ico"
set "VERSION_FILE=%TOOLS_DIR%\.version"

:: Detect the REAL Desktop path (handles OneDrive and custom paths)
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"`) do set "REAL_DESKTOP=%%I"
set "SHORTCUT=%REAL_DESKTOP%\Jigar Tools.lnk"

:: Read local version (set by updater or manually)
set "LOCAL_VERSION=v40.0"
if exist "%VERSION_FILE%" (
    set /p LOCAL_VERSION=<"%VERSION_FILE%"
)

:: ---- 3. AUTO-SETUP CHECK -------------------------------
if exist "%SHORTCUT%" goto :Menu

cls
echo ========================================================
echo        JIGAR TOOLS - INITIAL SYSTEM AUDIT (v2.0 Gold Edition)
echo ========================================================
echo.

echo [AUDIT] Checking Directory Content...
if not exist "JigarSmartSync.ps1"    echo [FAIL] JigarSmartSync.ps1 missing.    && pause && exit /b 1
echo   [OK] JigarSmartSync.ps1 found.
if not exist "JigarSmartRestore.ps1" echo [FAIL] JigarSmartRestore.ps1 missing. && pause && exit /b 1
echo   [OK] JigarSmartRestore.ps1 found.

echo.
echo [AUDIT] Checking Assets...
if exist "%ICON_FILE%" (echo   [OK] logo.ico found.) else (echo   [WARN] Warning: logo.ico missing.)

echo.
echo [AUDIT] Checking PowerShell Environment...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if ($PSVersionTable.PSVersion.Major -ge 5) { Write-Host '  [OK] PS 5.1+ Active.' } else { Write-Host '  [FAIL] PS Outdated. Minimum: PS 5.1'; exit 1 }"
if %errorLevel% neq 0 goto :PSError

echo.
echo [AUDIT] Checking ADB Availability...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command adb -ErrorAction SilentlyContinue) { Write-Host '  [OK] ADB found in PATH.' } else { Write-Host '  [WARN] ADB not in system PATH.' }"

echo.
echo [+] Registering Jigar Tools to System PATH...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine'); if ($oldPath -notlike ('*' + $env:TOOLS_DIR + '*')) { [Environment]::SetEnvironmentVariable('Path', $oldPath + ';' + $env:TOOLS_DIR, 'Machine'); Write-Host '  [DONE] Path Registered.' } else { Write-Host '  [SKIP] Already in Path.' }"

echo.
echo [+] Writing version file (%LOCAL_VERSION%)...
echo %LOCAL_VERSION%> "%VERSION_FILE%"

echo.
echo [+] Planting the Flower (Desktop Shortcut)...
set "SELF_PATH=%~f0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut($env:SHORTCUT);$s.TargetPath=$env:SELF_PATH;$s.WorkingDirectory=$env:TOOLS_DIR;if(Test-Path $env:ICON_FILE){$s.IconLocation=$env:ICON_FILE};$s.Save()"

echo.
echo ========================================================
echo  [SUCCESS] Setup Complete.
echo  [SUCCESS] Flower planted at: %REAL_DESKTOP%
echo  [ACTION]  Entering the God Mode Menu...
echo ========================================================
echo.
pause

:: ---- 4. MAIN GOD MODE MENU ----------------------------
:Menu
cls
echo ========================================================
echo        JIGAR TOOLS v2.0 Gold Edition  -  MASTER CONTROL CENTER
echo        Local Version: %LOCAL_VERSION% (Internal)
echo ========================================================
echo.
echo  ARSENAL:
echo  [1] JIGARSYNC BACKUP     (20x Threads + 3-Stage Fallback)
echo  [2] JIGAR SMART RESTORE  (Full / Selective Folder Restore)
echo  [3] DEVICE STATUS        (Check Connection)
echo  [4] CHECK FOR UPDATES    (GitHub Auto-Updater)
echo  [5] EXIT                 (Kills ADB server + closes)
echo.
echo ========================================================
set /p choice=" Choose your weapon (1-5): "

if "%choice%"=="1" goto :Backup
if "%choice%"=="2" goto :Restore
if "%choice%"=="3" goto :DeviceStatus
if "%choice%"=="4" goto :CheckUpdate
if "%choice%"=="5" goto :Exit
echo.
echo [ERROR] Invalid choice. Try again.
echo.
timeout /t 2 >nul
goto :Menu

:: ---- DEVICE STATUS ------------------------------------
:DeviceStatus
cls
echo ========================================================
echo        DEVICE CONNECTION STATUS
echo ========================================================
echo.
echo [CHECK] Scanning for connected devices...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$bin = Join-Path $env:TOOLS_DIR 'bin';" ^
    "$adb  = if (Test-Path (Join-Path $bin 'adb.exe')) { Join-Path $bin 'adb.exe' } else { 'adb' };" ^
    "$devices = & $adb devices 2>$null | Select-String '\tdevice$';" ^
    "if ($devices.Count -eq 0) {" ^
    "  Write-Host '[ERROR] No Android device detected.' -ForegroundColor Red;" ^
    "  Write-Host '';" ^
    "  Write-Host 'TROUBLESHOOTING:' -ForegroundColor Yellow;" ^
    "  Write-Host '  1. Connect phone via USB' -ForegroundColor Gray;" ^
    "  Write-Host '  2. Enable USB Debugging on phone' -ForegroundColor Gray;" ^
    "  Write-Host '  3. Tap ALLOW when prompted' -ForegroundColor Gray;" ^
    "  Write-Host '  4. Select File Transfer mode' -ForegroundColor Gray;" ^
    "  Write-Host '  5. Keep screen UNLOCKED' -ForegroundColor Gray" ^
    "} else {" ^
    "  Write-Host '[SUCCESS] Device(s) detected.' -ForegroundColor Green;" ^
    "  Write-Host '';" ^
    "  foreach ($line in $devices) {" ^
    "    $serial = $line.ToString().Split([char]9)[0].Trim();" ^
    "    Write-Host \"  + Serial: $serial\" -ForegroundColor Cyan;" ^
    "    $model = & $adb -s $serial shell 'getprop ro.product.model' 2>$null;" ^
    "    if ($model) { Write-Host \"    Model : $($model.Trim())\" -ForegroundColor Gray }" ^
    "  }" ^
    "}"

echo.
pause
goto :Menu

:: ---- BACKUP -------------------------------------------
:Backup
cls
echo.
echo [ACTION] Launching JIGARSYNC BACKUP...
echo [INFO]   Ensure your phone is connected and screen is UNLOCKED
echo.
timeout /t 2 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "JigarSmartSync.ps1"
pause
goto :Menu

:: ---- RESTORE ------------------------------------------
:Restore
cls
echo.
echo [ACTION] Launching JIGAR SMART RESTORE...
echo [INFO]   Ensure your phone is connected and screen is UNLOCKED
echo [INFO]   You will be prompted to select your backup folder
echo.
timeout /t 2 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "JigarSmartRestore.ps1"
pause
goto :Menu

:: ---- AUTO-UPDATER --------------------------
:CheckUpdate
cls
echo ========================================================
echo        JIGAR TOOLS  |  AUTO-UPDATER
echo        Checking: github.com/official-Arvind/jigar-tools
echo ========================================================
echo.
echo [UPDATE] Querying GitHub API for latest release...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$localVer = 'v40.0'; $vc = Get-Content $env:VERSION_FILE -ErrorAction SilentlyContinue; if ($vc) { $localVer = $vc.Trim() };" ^
    "$api = 'https://api.github.com/repos/official-Arvind/jigar-tools/releases/latest';" ^
    "try {" ^
    "  $rel = Invoke-RestMethod -Uri $api -UseBasicParsing -ErrorAction Stop;" ^
    "  $remoteVer = $rel.tag_name.Trim();" ^
    "  $zipUrl    = ($rel.assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1).browser_download_url;" ^
    "  if (-not $zipUrl) { $zipUrl = $rel.zipball_url };" ^
    "  Write-Host \"  Local  : $localVer\" -ForegroundColor Cyan;" ^
    "  Write-Host \"  Remote : $remoteVer\" -ForegroundColor Cyan;" ^
    "  Write-Host '';" ^
    "  $cmpLocal = $localVer.Trim();" ^
    "  $cmpRemote = $remoteVer.Trim();" ^
    "  if ($cmpLocal -match 'Beta' -or $cmpLocal -eq $cmpRemote) {" ^
    "    Write-Host '  [UP-TO-DATE] You are running a Beta or the latest version.' -ForegroundColor Green;" ^
    "    exit 0" ^
    "  };" ^
    "  Write-Host \"  [UPDATE AVAILABLE]  $localVer  ->  $remoteVer\" -ForegroundColor Yellow;" ^
    "  Write-Host '';" ^
    "  $answer = Read-Host '  Download and install update now? [Y/N]';" ^
    "  if ($answer.Trim().ToUpper() -ne 'Y') { Write-Host '  [SKIPPED] Update deferred.' -ForegroundColor DarkGray; exit 0 };" ^
    "  Write-Host '';" ^
    "  Write-Host '  [1/4] Downloading release ZIP...' -ForegroundColor Yellow;" ^
    "  $tmpZip = Join-Path $env:TEMP 'jigar_update.zip';" ^
    "  $tmpDir = Join-Path $env:TEMP 'jigar_update_extract';" ^
    "  if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force };" ^
    "  Invoke-WebRequest -Uri $zipUrl -OutFile $tmpZip -UseBasicParsing;" ^
    "  Write-Host '  [2/4] Extracting...' -ForegroundColor Yellow;" ^
    "  Expand-Archive -Path $tmpZip -DestinationPath $tmpDir -Force;" ^
    "  $root = Get-ChildItem $tmpDir -Directory | Select-Object -First 1;" ^
    "  if (-not $root) { $root = [System.IO.DirectoryInfo]$tmpDir };" ^
    "  Write-Host '  [3/4] Installing (preserving backups + config)...' -ForegroundColor Yellow;" ^
    "  $toolsDir   = $env:TOOLS_DIR;" ^
    "  $preservePat = @('settings.json','.version','Logs','*.log','directory-ignore-list.ini');" ^
    "  Get-ChildItem $root.FullName | ForEach-Object {" ^
    "    $name   = $_.Name;" ^
    "    $keep   = $false;" ^
    "    foreach ($pat in $preservePat) { if ($name -like $pat) { $keep = $true; break } };" ^
    "    if ($keep) { Write-Host \"    [PRESERVED] $name\" -ForegroundColor DarkGray; return };" ^
    "    $dst = Join-Path $toolsDir $name;" ^
    "    if ($name -eq 'Jigar_Tools_Setup.bat') { $dst = Join-Path $toolsDir 'Jigar_Tools_Setup_New.bat' };" ^
    "    if ($_.PSIsContainer) { " ^
    "      if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Force -Path $dst | Out-Null };" ^
    "      Copy-Item \"$($_.FullName)\*\" $dst -Recurse -Force" ^
    "    } else { Copy-Item $_.FullName $dst -Force };" ^
    "    Write-Host \"    [UPDATED] $name\" -ForegroundColor Gray" ^
    "  };" ^
    "  $remoteVer | Set-Content (Join-Path $toolsDir '.version') -Encoding UTF8;" ^
    "  Remove-Item $tmpZip, $tmpDir -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "  Write-Host '';" ^
    "  Write-Host \"  [4/4] Update to $remoteVer complete.\" -ForegroundColor Green;" ^
    "  Write-Host '        Relaunching Jigar Tools...' -ForegroundColor Cyan;" ^
    "  Start-Sleep -Seconds 2;" ^
    "  $qc = [char]34;" ^
    "  Start-Process cmd -ArgumentList ('/c', 'timeout /t 2 >nul & move /y ' + $qc + $toolsDir + '\Jigar_Tools_Setup_New.bat' + $qc + ' ' + $qc + $toolsDir + '\Jigar_Tools_Setup.bat' + $qc + ' & ' + $qc + $toolsDir + '\Jigar_Tools_Setup.bat' + $qc);" ^
    "  exit 99" ^
    "} catch {" ^
    "  Write-Host \"  [ERROR] Could not reach GitHub: $($_.Exception.Message)\" -ForegroundColor Red;" ^
    "  Write-Host '  Check your internet connection and try again.' -ForegroundColor DarkGray" ^
    "}"

:: If updater returned 99 it relaunched itself — close this instance
if %errorLevel% equ 99 exit /b 0

echo.
pause
goto :Menu

:: ---- EXIT WITH ADB CLEANUP -----------------
:Exit
cls
echo.
echo ========================================================
echo        JIGAR TOOLS  |  SHUTDOWN SEQUENCE
echo ========================================================
echo.
echo  [SHUTDOWN] Killing ADB server daemon...

:: Try bundle ADB first, fall back to system ADB
set "ADB_EXE=%TOOLS_DIR%\bin\adb.exe"
if exist "%ADB_EXE%" (
    "%ADB_EXE%" kill-server >nul 2>&1
) else (
    where adb >nul 2>&1
    if !errorLevel! equ 0 ( adb kill-server >nul 2>&1 )
)

:: Verify the ADB process is gone
timeout /t 1 >nul
tasklist /fi "imagename eq adb.exe" 2>nul | find /i "adb.exe" >nul
if %errorLevel% equ 0 (
    echo  [WARNING] ADB process still detected. Force-killing...
    taskkill /im adb.exe /f >nul 2>&1
    timeout /t 1 >nul
    tasklist /fi "imagename eq adb.exe" 2>nul | find /i "adb.exe" >nul
    if !errorLevel! equ 0 (
        echo  [WARN] Could not fully terminate ADB. It may restart on next use.
    ) else (
        echo  [OK] ADB server shutdown confirmed.
    )
) else (
    echo  [OK] ADB server shutdown confirmed.
)

echo.
echo  [DONE] Thank you for using Jigar Tools. Goodbye..
echo.
echo ========================================================
echo.
timeout /t 2 >nul
exit /b 0

:: ---- ERROR HANDLERS ------------------------------------
:PSError
echo.
echo [FATAL] PowerShell 5.1+ is required.
echo.
echo Please upgrade PowerShell:
echo https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows
echo.
pause
exit /b 1

:: ---- ADMIN RELAUNCH -----------------------------------
:Relaunch
echo [WARN] This tool requires Administrator privileges...
echo [WARN] Requesting God Mode elevation...
echo.
set "SELF_PATH=%~f0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList ('/c', $env:SELF_PATH) -Verb RunAs"
exit /b 0