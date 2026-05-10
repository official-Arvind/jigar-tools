@echo off
setlocal enabledelayedexpansion
:: ========================================================
::  JIGAR TOOLS - UNIFIED GOD MODE (v4.1)
::  - Enhanced: Device connection verification
::  - Enhanced: Smart ADB path detection
::  - Enhanced: Better error messaging
:: ========================================================

:: 1. THE STABLE ADMIN RELAUNCH
net session >nul 2>&1
if %errorLevel% neq 0 goto :Relaunch

:: 2. DIRECTORY & ASSET LOCK
cd /d "%~dp0"
set "TOOLS_DIR=%CD%"
set "ICON_FILE=%TOOLS_DIR%\logo.ico"

:: Detect the REAL Desktop path (handles OneDrive and custom paths)
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"`) do set "REAL_DESKTOP=%%I"
set "SHORTCUT=%REAL_DESKTOP%\Jigar Tools.lnk"

:: 3. AUTO-SETUP CHECK
if exist "%SHORTCUT%" goto :Menu

cls
echo ========================================================
echo        JIGAR TOOLS - INITIAL SYSTEM AUDIT (v4.1)
echo ========================================================
echo.

echo [AUDIT] Checking Directory Content...
if not exist "JigarSmartSync.ps1" echo [FAIL] Run this from the tools folder! && pause && exit /b 1
echo   [OK] JigarSmartSync.ps1 found.
if not exist "JigarSmartRestore.ps1" echo [FAIL] JigarSmartRestore.ps1 missing! && pause && exit /b 1
echo   [OK] JigarSmartRestore.ps1 found.
if not exist "paranoid.ps1" echo [FAIL] paranoid.ps1 missing! && pause && exit /b 1
echo   [OK] paranoid.ps1 found.

echo.
echo [AUDIT] Checking Assets...
if exist "%ICON_FILE%" (echo   [OK] logo.ico found.) else (echo   [!] Warning: logo.ico missing.)

echo.
echo [AUDIT] Checking PowerShell Environment...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if ($PSVersionTable.PSVersion.Major -ge 5) { Write-Host '  [OK] PS 5.1+ Active.' } else { Write-Host '  [FAIL] PS Outdated! Minimum: PS 5.1'; pause; exit 1 }"
if %errorLevel% neq 0 goto :PSError

echo.
echo [AUDIT] Checking ADB Availability...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command adb -ErrorAction SilentlyContinue) { Write-Host '  [OK] ADB found in PATH.' } else { Write-Host '  [!] ADB not in system PATH.' }"

echo.
echo [+] Registering Jigar_Tools to System PATH...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine'); if ($oldPath -notlike '*%TOOLS_DIR%*') { [Environment]::SetEnvironmentVariable('Path', $oldPath + ';%TOOLS_DIR%', 'Machine'); Write-Host '  [DONE] Path Registered.' } else { Write-Host '  [SKIP] Already in Path.' }"

echo.
echo [+] Planting the Flower (Desktop Shortcut)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%');$s.TargetPath='%~f0';$s.WorkingDirectory='%TOOLS_DIR%';if(Test-Path '%ICON_FILE%'){$s.IconLocation='%ICON_FILE%'};$s.Save()"

echo.
echo ========================================================
echo  [SUCCESS] Setup Complete!
echo  [SUCCESS] Flower planted at: %REAL_DESKTOP%
echo  [ACTION] Entering the God Mode Menu...
echo ========================================================
echo.
pause

:: 4. MAIN GOD MODE MENU
:Menu
cls
echo ========================================================
echo        JIGAR TOOLS - MASTER CONTROL CENTER (v38.2)
echo ========================================================
echo.
echo  ARSENAL:
echo  [1] JIGARSYNC BACKUP (12x Threads + 3-Stage Fallback)
echo  [2] JIGAR SMART RESTORE (Full Folder Restore)
echo  [3] PARANOID CHECK (Deep Integrity Verify)
echo  [4] DEVICE STATUS (Check Connection)
echo  [5] EXIT
echo.
echo ========================================================
set /p choice=" Choose your weapon (1-5): "

if "%choice%"=="1" goto :Backup
if "%choice%"=="2" goto :Restore
if "%choice%"=="3" goto :Paranoid
if "%choice%"=="4" goto :DeviceStatus
if "%choice%"=="5" exit /b 0
echo.
echo [ERROR] Invalid choice. Try again.
echo.
timeout /t 2 >nul
goto :Menu

:DeviceStatus
cls
echo ========================================================
echo        DEVICE CONNECTION STATUS
echo ========================================================
echo.
echo [CHECK] Scanning for connected devices...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "
$bin = Join-Path '$TOOLS_DIR' 'bin'
if (Test-Path (Join-Path $bin 'adb.exe')) {
    `$adb = Join-Path $bin 'adb.exe'
} else {
    `$adb = 'adb'
}

`$devices = & `$adb devices 2^>^`$null | Select-String '\tdevice^$'
if (`$devices.Count -eq 0) {
    Write-Host '[ERROR] No Android device detected!' -ForegroundColor Red
    Write-Host '' 
    Write-Host 'TROUBLESHOOTING:' -ForegroundColor Yellow
    Write-Host '  1. Connect phone via USB cable' -ForegroundColor Gray
    Write-Host '  2. On phone: Enable USB Debugging' -ForegroundColor Gray
    Write-Host '  3. Tap ALLOW when permission appears' -ForegroundColor Gray
    Write-Host '  4. Select File Transfer mode (not Charging Only)' -ForegroundColor Gray
    Write-Host '  5. Keep screen UNLOCKED during operations' -ForegroundColor Gray
} else {
    Write-Host '[SUCCESS] Device(s) detected!' -ForegroundColor Green
    Write-Host ''
    foreach (`$line in `$devices) {
        `$serial = `$line.ToString().Split([char]9)[0].Trim()
        Write-Host \"  ✓ Serial: `$serial\" -ForegroundColor Cyan
        `$info = & `$adb -s `$serial shell 'getprop ro.build.fingerprint' 2^>^`$null
        if (`$info) { Write-Host \"    Info: `$info\" -ForegroundColor Gray }
    }
}
"

echo.
pause
goto :Menu

:Backup
cls
echo.
echo [ACTION] Launching JIGARSYNC BACKUP...
echo [INFO] Ensure your phone is connected and screen is UNLOCKED
echo.
timeout /t 2 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "JigarSmartSync.ps1"
pause
goto :Menu

:Restore
cls
echo.
echo [ACTION] Launching JIGAR SMART RESTORE...
echo [INFO] Ensure your phone is connected and screen is UNLOCKED
echo [INFO] You will be prompted to select your backup folder
echo.
timeout /t 2 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "JigarSmartRestore.ps1"
pause
goto :Menu

:Paranoid
cls
echo.
echo [ACTION] Launching PARANOID CHECK...
echo [INFO] Ensure your phone is connected and screen is UNLOCKED
echo [INFO] You will be prompted to select a folder to verify
echo.
timeout /t 2 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "paranoid.ps1"
pause
goto :Menu

:PSError
echo.
echo [FATAL] PowerShell 5.1+ is required!
echo.
echo Please upgrade PowerShell:
echo https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows
echo.
pause
exit /b 1

:: 5. RELAUNCH HANDLER
:Relaunch
echo [!] This tool requires Administrator privileges...
echo [!] Requesting God Mode elevation...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', \"cd -LiteralPath '%~dp0'; cmd /c '%~f0'\" -Verb RunAs"
exit /b 0