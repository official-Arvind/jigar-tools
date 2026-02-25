@echo off
setlocal
:: ========================================================
::  JIGAR TOOLS - UNIFIED GOD MODE (v4.0)
::  - Fix: Hard-coded Desktop path replaced with True Path Auto-Discovery
::  - Fix: Simplified Admin relaunch to kill "Terminator" errors
::  - Consolidate: Nitro Backup is now Choice #1
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
echo        JIGAR TOOLS - INITIAL SYSTEM AUDIT
echo ========================================================

echo [AUDIT] Checking Directory Content...
if not exist "fullbackup.ps1" echo [FAIL] Run this from the tools folder! && pause && exit
echo   [OK] Scripts detected.

echo [AUDIT] Checking Assets...
if exist "%ICON_FILE%" (echo   [OK] logo.ico found.) else (echo   [!] Warning: logo.ico missing.)

echo [AUDIT] Checking PowerShell Environment...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if ($PSVersionTable.PSVersion.Major -ge 5) { Write-Host '  [OK] PS 5.1+ Active.' } else { Write-Host '  [FAIL] PS Outdated!'; pause; exit }"

echo.
echo [+] Registering Jigar_Tools to System PATH...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine'); if ($oldPath -notlike '*%TOOLS_DIR%*') { [Environment]::SetEnvironmentVariable('Path', $oldPath + ';%TOOLS_DIR%', 'Machine'); Write-Host '  [DONE] Path Registered.' } else { Write-Host '  [SKIP] Already in Path.' }"

echo [+] Planting the Flower (Desktop Shortcut)...
:: Force shortcut creation using the discovered Real Desktop path
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%');$s.TargetPath='%~f0';$s.WorkingDirectory='%TOOLS_DIR%';if(Test-Path '%ICON_FILE%'){$s.IconLocation='%ICON_FILE%'};$s.Save()"

echo --------------------------------------------------------
echo  [SUCCESS] Setup Complete! 
echo  [SUCCESS] Flower planted at: %REAL_DESKTOP%
echo  [ACTION] Entering the God Mode Menu...
echo --------------------------------------------------------
pause

:: 4. MAIN GOD MODE MENU (Cleaned for Jigar)
:Menu
cls
echo ========================================================
echo        JIGAR TOOLS - MASTER CONTROL CENTER
echo ========================================================
echo  [1] NITRO BACKUP (Full Hybrid or Selective)
echo  [2] NO-MERCY RESTORE (100%% Integrity + Auto APKs)
echo  [3] PARANOID CHECK (Hidden File Audit)
echo  [4] EXIT
echo ========================================================
set /p choice=" Choose your weapon: "

if "%choice%"=="1" goto :Backup
if "%choice%"=="2" goto :Restore
if "%choice%"=="3" goto :Paranoid
if "%choice%"=="4" exit
goto :Menu

:Backup
powershell -NoProfile -ExecutionPolicy Bypass -File "fullbackup.ps1"
pause
goto :Menu

:Restore
powershell -NoProfile -ExecutionPolicy Bypass -File "ADB_SmartRestore.ps1"
pause
goto :Menu

:Paranoid
powershell -NoProfile -ExecutionPolicy Bypass -File "paranoid.ps1"
pause
goto :Menu

:: 5. RELAUNCH HANDLER (Escaped Fix)
:Relaunch
echo [!] Requesting God Mode in persistent PowerShell window...
:: Simplified relaunch to avoid quote-parsing errors
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', \"cd -LiteralPath '%~dp0'; cmd /c '%~f0'\" -Verb RunAs"
exit /b