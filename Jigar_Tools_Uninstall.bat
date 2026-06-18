@echo off
setlocal enabledelayedexpansion
:: ========================================================
::  JIGAR TOOLS - UNINSTALLER (v2.0)
::  Does the exact opposite of Jigar_Tools_Setup.bat:
::  1. Verifies / requests Administrator privileges
::  2. Removes tool dir from System PATH
::  3. Deletes the Desktop shortcut
::  4. Stops ADB server
::  5. Optionally wipes Logs + settings
::  6. Optionally wipes the BACKUPS folder (wherever it is)
::  7. Self-deletes the entire Jigar Tools install folder
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

:: Read backup location from settings.json if it exists
set "BACKUPS_DIR="
if exist "%TOOLS_DIR%\settings.json" (
    for /f "usebackq delims=" %%B in (`powershell -NoProfile -Command "try { $s=(Get-Content (Join-Path $env:TOOLS_DIR 'settings.json') | ConvertFrom-Json); if($s.LastBackupLocation){$s.LastBackupLocation} } catch {}"`) do set "BACKUPS_DIR=%%B"
)
:: Fallback: check common backup location on Desktop
if not defined BACKUPS_DIR (
    if exist "%REAL_DESKTOP%\BACKUPS" set "BACKUPS_DIR=%REAL_DESKTOP%\BACKUPS"
)

cls
echo.
echo  ============================================================
echo      JIGAR TOOLS  ^|  UNINSTALLER v2.0
echo  ============================================================
echo.
echo   This will PERMANENTLY remove Jigar Tools from your system.
echo   Your backup data choices will be asked separately.
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
    "$dir = $env:TOOLS_DIR;" ^
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
        echo   [DONE] ADB server stopped (system ADB^).
    ) else (
        echo   [SKIP] ADB not found, nothing to stop.
    )
)

echo.
echo  ============================================================
echo   STEP 4 ^|  Logs and Settings
echo  ============================================================
echo.

set "HAS_LOCAL=0"
if exist "%TOOLS_DIR%\Logs"         (echo     Logs\          - operation transcripts  & set "HAS_LOCAL=1")
if exist "%TOOLS_DIR%\settings.json" (echo     settings.json  - saved preferences      & set "HAS_LOCAL=1")
if exist "%TOOLS_DIR%\.version"      (echo     .version       - version tracking file   & set "HAS_LOCAL=1")

if "%HAS_LOCAL%"=="0" (
    echo   [INFO] No logs or settings found.
) else (
    echo.
    set /p DEL_LOCAL=" Delete logs and settings? [Y/N]: "
    if /i "!DEL_LOCAL!"=="Y" (
        echo.
        if exist "%TOOLS_DIR%\Logs"          ( rd /s /q "%TOOLS_DIR%\Logs"          & echo   [DONE] Logs\ deleted. )
        if exist "%TOOLS_DIR%\settings.json" ( del /f /q "%TOOLS_DIR%\settings.json" & echo   [DONE] settings.json deleted. )
        if exist "%TOOLS_DIR%\.version"      ( del /f /q "%TOOLS_DIR%\.version"      & echo   [DONE] .version deleted. )
    ) else (
        echo.
        echo   [SKIP] Logs and settings preserved.
    )
)

echo.
echo  ============================================================
echo   STEP 5 ^|  Android Backup Data
echo  ============================================================
echo.

:: Show any inline backup folders (DeviceName_YYYY-MM-DD pattern)
set "HAS_INLINE=0"
for /d %%D in ("%TOOLS_DIR%\*_????-??-??_*") do (
    echo     %%~nxD\  - backup snapshot (inside install folder^)
    set "HAS_INLINE=1"
)
if exist "%TOOLS_DIR%\Smart_Backup" (
    echo     Smart_Backup\  - legacy backup data (inside install folder^)
    set "HAS_INLINE=1"
)

:: Show external backups folder
if defined BACKUPS_DIR (
    if exist "%BACKUPS_DIR%" (
        echo     %BACKUPS_DIR%
        echo     ^--- Your Android backup snapshots (EXTERNAL BACKUPS FOLDER^)
        set "HAS_INLINE=1"
    )
)

if "!HAS_INLINE!"=="0" (
    echo   [INFO] No backup data found anywhere. Nothing to delete.
    goto :SelfDelete
)

echo.
echo  ============================================================
echo   WARNING: Deleting backups is PERMANENT and UNRECOVERABLE!
echo  ============================================================
echo.

:: Ask about inline backups
set "HAS_ASKABLE=0"
for /d %%D in ("%TOOLS_DIR%\*_????-??-??_*") do set "HAS_ASKABLE=1"
if exist "%TOOLS_DIR%\Smart_Backup" set "HAS_ASKABLE=1"

if "%HAS_ASKABLE%"=="1" (
    set /p DEL_INLINE=" Delete backup snapshots inside the install folder? [Y/N]: "
    if /i "!DEL_INLINE!"=="Y" (
        echo.
        for /d %%D in ("%TOOLS_DIR%\*_????-??-??_*") do (
            rd /s /q "%%D"
            echo   [DONE] %%~nxD\ deleted.
        )
        if exist "%TOOLS_DIR%\Smart_Backup" (
            rd /s /q "%TOOLS_DIR%\Smart_Backup"
            echo   [DONE] Smart_Backup\ deleted.
        )
    ) else (
        echo   [SKIP] Inline backup snapshots preserved.
    )
)

:: Ask about external BACKUPS folder
if defined BACKUPS_DIR (
    if exist "%BACKUPS_DIR%" (
        echo.
        echo   External backups folder found at:
        echo   %BACKUPS_DIR%
        echo.
        set /p DEL_EXT=" Delete the entire BACKUPS folder (all your Android snapshots)? [Y/N]: "
        if /i "!DEL_EXT!"=="Y" (
            echo.
            echo   Deleting %BACKUPS_DIR% ...
            rd /s /q "%BACKUPS_DIR%"
            echo   [DONE] Backups folder deleted.
        ) else (
            echo   [SKIP] Backups folder preserved at: %BACKUPS_DIR%
        )
    )
)

:SelfDelete
echo.
echo  ============================================================
echo   STEP 6 ^|  Self-Delete Install Folder
echo  ============================================================
echo.
echo   Install folder: %TOOLS_DIR%
echo.
set /p DEL_SELF=" Delete the entire Jigar Tools install folder? [Y/N]: "
if /i "%DEL_SELF%"=="Y" (
    echo.
    echo   [INFO] Scheduling self-deletion and exiting...
    echo.
    echo  ============================================================
    echo.
    echo   [SUCCESS]  Jigar Tools has been completely removed.
    echo              The install folder will be deleted now.
    echo.
    echo  ============================================================
    echo.
    :: Use a temporary payload in %TEMP% so the script doesn't lock its own folder
    (
        echo @echo off
        echo ping 127.0.0.1 -n 3 ^>nul
        echo rd /s /q "%TOOLS_DIR%"
        echo del "%%~f0"
    ) > "%TEMP%\jigar_cleanup.bat"
    
    start "" /b "%TEMP%\jigar_cleanup.bat"
    exit /b 0
) else (
    echo.
    echo   [SKIP] Install folder preserved. You can delete it manually.
)

echo.
echo  ============================================================
echo.
echo   [SUCCESS]  Jigar Tools has been cleanly uninstalled.
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
set "SELF_PATH=%~f0"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Start-Process cmd -ArgumentList ('/c', $env:SELF_PATH) -Verb RunAs"
exit /b 0
