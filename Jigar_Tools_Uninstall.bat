@echo off
setlocal enabledelayedexpansion
:: ========================================================
::  JIGAR TOOLS - UNINSTALLER (v1.0)
::  Does the exact opposite of Jigar_Tools_Setup.bat:
::  1. Verifies / requests Administrator privileges
::  2. Removes tool dir from System PATH
::  3. Deletes the Desktop shortcut
::  4. Optionally wipes backup data + logs
:: ========================================================

:: ---- 1. ADMIN ELEVATION CHECK -------------------------
net session >nul 2>&1
if %errorLevel% neq 0 goto :Relaunch

:: ---- 2. LOCK PATHS ------------------------------------
cd /d "%~dp0"
set "TOOLS_DIR=%CD%"

:: Detect real Desktop (handles OneDrive redirection)
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"`) do set "REAL_DESKTOP=%%I"
set "SHORTCUT=%REAL_DESKTOP%\Jigar Tools.lnk"

cls
echo.
echo  ============================================================
echo      JIGAR TOOLS  ^|  UNINSTALLER v1.0
echo  ============================================================
echo.
echo   This will PERMANENTLY remove Jigar Tools from your system.
echo   Your Android backup data will be handled separately.
echo.
echo  ============================================================
echo.
set /p CONFIRM=" Are you sure you want to continue? [Y/N]: "
if /i not "%CONFIRM%"=="Y" (
    echo.
    echo  [CANCELLED] No changes were made.
    echo.
    pause
    exit /b 0
)

echo.
echo  ============================================================
echo   STEP 1 ^|  Removing from System PATH
echo  ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$dir = '%TOOLS_DIR%';" ^
    "$scope = 'Machine';" ^
    "$cur = [Environment]::GetEnvironmentVariable('Path', $scope);" ^
    "$parts = $cur -split ';' | Where-Object { $_.Trim() -ne '' -and $_.TrimEnd('\') -ne $dir.TrimEnd('\') };" ^
    "$new = $parts -join ';';" ^
    "if ($cur -ne $new) {" ^
    "  [Environment]::SetEnvironmentVariable('Path', $new, $scope);" ^
    "  Write-Host '  [DONE] Jigar Tools removed from System PATH.' -ForegroundColor Green" ^
    "} else {" ^
    "  Write-Host '  [SKIP] Jigar Tools was not in System PATH.' -ForegroundColor DarkGray" ^
    "}"

echo.
echo  ============================================================
echo   STEP 2 ^|  Deleting Desktop Shortcut
echo  ============================================================
echo.

if exist "%SHORTCUT%" (
    del /f /q "%SHORTCUT%"
    echo   [DONE] Shortcut deleted: %SHORTCUT%
) else (
    echo   [SKIP] Shortcut not found at: %SHORTCUT%
)

echo.
echo  ============================================================
echo   STEP 3 ^|  ADB Server Cleanup
echo  ============================================================
echo.

set "ADB_EXE=%TOOLS_DIR%\bin\adb.exe"
if exist "%ADB_EXE%" (
    "%ADB_EXE%" kill-server >nul 2>&1
    echo   [DONE] ADB server stopped.
) else (
    where adb >nul 2>&1
    if !errorLevel! equ 0 (
        adb kill-server >nul 2>&1
        echo   [DONE] ADB server stopped (system ADB).
    ) else (
        echo   [SKIP] ADB not found, nothing to stop.
    )
)

echo.
echo  ============================================================
echo   STEP 4 ^|  Backup Data and Logs
echo  ============================================================
echo.
echo   The following data folders exist in this directory:
echo.

set "HAS_DATA=0"
if exist "%TOOLS_DIR%\Logs"  (echo     Logs\     - operation transcripts   & set "HAS_DATA=1")

:: Check for any dynamic backup folders (DeviceName_YYYY-MM-DD pattern)
set "BACKUP_COUNT=0"
for /d %%D in ("%TOOLS_DIR%\*_????-??-??_*") do (
    echo     %%~nxD\  - backup snapshot
    set /a BACKUP_COUNT+=1
    set "HAS_DATA=1"
)
:: Also check for legacy Smart_Backup folder
if exist "%TOOLS_DIR%\Smart_Backup" (
    echo     Smart_Backup\  - legacy backup data
    set "HAS_DATA=1"
)
:: Check saved config
if exist "%TOOLS_DIR%\settings.json" (
    echo     settings.json  - saved preferences
    set "HAS_DATA=1"
)

if "%HAS_DATA%"=="0" (
    echo   [INFO] No backup data or logs found. Nothing to delete.
    goto :Final
)

echo.
set /p DEL_DATA=" Delete ALL of the above (Logs, backups, settings)? [Y/N]: "
if /i "%DEL_DATA%"=="Y" (
    echo.
    echo   Deleting data...

    if exist "%TOOLS_DIR%\Logs" (
        rd /s /q "%TOOLS_DIR%\Logs"
        echo   [DONE] Logs\ deleted.
    )

    for /d %%D in ("%TOOLS_DIR%\*_????-??-??_*") do (
        rd /s /q "%%D"
        echo   [DONE] %%~nxD\ deleted.
    )

    if exist "%TOOLS_DIR%\Smart_Backup" (
        rd /s /q "%TOOLS_DIR%\Smart_Backup"
        echo   [DONE] Smart_Backup\ deleted.
    )

    if exist "%TOOLS_DIR%\settings.json" (
        del /f /q "%TOOLS_DIR%\settings.json"
        echo   [DONE] settings.json deleted.
    )
) else (
    echo.
    echo   [SKIP] Backup data and logs preserved.
)

:Final
echo.
echo  ============================================================
echo.
echo   [SUCCESS]  Jigar Tools has been cleanly uninstalled.
echo.
echo   The script files in this folder are still present.
echo   You may delete this folder manually if you wish.
echo.
echo  ============================================================
echo.
pause
exit /b 0

:: ---- ADMIN RELAUNCH -----------------------------------
:Relaunch
echo.
echo  [WARN] Administrator privileges required for PATH modification.
echo  [WARN] Requesting elevation...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
exit /b 0
