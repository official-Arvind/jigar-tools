<#
.SYNOPSIS
End-to-End Audit Test Script for Jigar Tools
#>

$ErrorActionPreference = 'Stop'
$scriptPath = $MyInvocation.MyCommand.Path
$rootDir = Split-Path $scriptPath

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    JIGAR TOOLS - E2E AUDIT TESTS       " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$global:failed = 0

function Assert-Pass ($Message) {
    Write-Host "[PASS] $Message" -ForegroundColor Green
}

function Assert-Fail ($Message) {
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    $global:failed++
}

function Assert-Warn ($Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

# ---------------------------------------------------------
# Phase 1: Syntax Analysis
# ---------------------------------------------------------
Write-Host "`n=== Phase 1: Syntax Analysis ==="

$ps1Files = @("JigarSmartSync.ps1", "JigarSmartRestore.ps1")
foreach ($psName in $ps1Files) {
    $path = Join-Path $rootDir $psName
    if (Test-Path $path) {
        $errors = $null
        $tokens = $null
        [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
        if ($errors.Count -gt 0) {
            Assert-Fail "Syntax errors in $psName"
            foreach ($err in $errors) { Write-Host "  -> $($err.Message)" -ForegroundColor Red }
        } else {
            Assert-Pass "No syntax errors in $psName"
        }
    } else {
        Assert-Fail "$psName is missing!"
    }
}

$batFiles = @("Jigar_Tools_Setup.bat", "Jigar_Tools_Uninstall.bat")
foreach ($batName in $batFiles) {
    $path = Join-Path $rootDir $batName
    if (Test-Path $path) {
        $content = Get-Content $path -ErrorAction SilentlyContinue
        if ($content.Count -gt 0) {
            Assert-Pass "$batName is readable and not empty"
        } else {
            Assert-Fail "$batName is empty!"
        }
    } else {
        Assert-Fail "$batName is missing!"
    }
}

# ---------------------------------------------------------
# Phase 2: Updater Sandboxing
# ---------------------------------------------------------
Write-Host "`n=== Phase 2: Updater Sandboxing ==="
$sandboxDir = Join-Path $env:TEMP "JigarSandbox_$(New-Guid)"
New-Item -ItemType Directory -Path $sandboxDir | Out-Null
Write-Host "  -> Created sandbox at $sandboxDir" -ForegroundColor DarkGray

try {
    # Copy target files
    Copy-Item (Join-Path $rootDir "Jigar_Tools_Setup.bat") $sandboxDir
    if (Test-Path (Join-Path $rootDir "JigarSmartSync.ps1")) { Copy-Item (Join-Path $rootDir "JigarSmartSync.ps1") $sandboxDir }
    if (Test-Path (Join-Path $rootDir "JigarSmartRestore.ps1")) { Copy-Item (Join-Path $rootDir "JigarSmartRestore.ps1") $sandboxDir }
    
    # Write stale version
    Set-Content -Path (Join-Path $sandboxDir ".version") -Value "v0.1"
    
    # Patch bat file to bypass UAC elevation and avoid popping new cmd windows in CI
    $batPath = Join-Path $sandboxDir "Jigar_Tools_Setup.bat"
    $batContent = Get-Content $batPath
    $batContent = $batContent -replace 'goto :Relaunch', 'rem goto :Relaunch'
    $batContent = $batContent -replace 'if exist "%SHORTCUT%" goto :Menu', 'goto :Menu'
    $batContent = $batContent -replace 'Start-Process cmd', 'Write-Host "Simulated Relaunch"'
    Set-Content -Path $batPath -Value $batContent
    
    Write-Host "  -> Invoking sandboxed updater..." -ForegroundColor DarkGray
    # The batch menu asks for weapon (1-5), 4 is updater. The updater asks for Y/N.
    # 5 is exit.
    $output = "4`nY`n5" | & cmd /c $batPath *>&1
    
    # Verify .version was updated
    $newVersion = Get-Content (Join-Path $sandboxDir ".version") -ErrorAction SilentlyContinue
    if ($newVersion -and $newVersion -ne "v0.1") {
        Assert-Pass "Auto-updater successfully fetched new payload ($newVersion)"
    } else {
        Assert-Fail "Auto-updater failed to update .version file!"
        Write-Host "Bat Output snippet:" -ForegroundColor DarkGray
        $output | Select-Object -Last 15 | Write-Host
    }
} catch {
    Assert-Fail "Sandbox execution threw an exception: $_"
} finally {
    Remove-Item $sandboxDir -Recurse -Force
    Write-Host "  -> Cleaned up sandbox" -ForegroundColor DarkGray
}

# ---------------------------------------------------------
# Phase 3: ADB Read-Only Check
# ---------------------------------------------------------
Write-Host "`n=== Phase 3: ADB Read-Only Check ==="

try {
    $adbOut = & adb devices 2>&1
    if ($LASTEXITCODE -ne 0) {
        Assert-Warn "adb command failed or not in PATH. Skipping ADB checks."
    } else {
        $devices = ($adbOut | Select-String -Pattern '\bdevice\b' | Where-Object { $_ -notmatch 'List of devices attached' })
        if ($devices.Count -gt 0) {
            Assert-Pass "Android device(s) found via adb."
            
            $prop = & adb shell getprop ro.build.version.release 2>&1
            if ($LASTEXITCODE -eq 0) {
                Assert-Pass "adb shell read check passed (Android Version: $prop)"
            } else {
                Assert-Fail "adb shell getprop failed."
            }
            
            $lsOut = & adb shell ls /sdcard/ 2>&1
            if ($LASTEXITCODE -eq 0) {
                Assert-Pass "adb shell ls /sdcard/ passed."
            } else {
                Assert-Fail "adb shell ls /sdcard/ failed."
            }
        } else {
            Assert-Warn "No adb devices attached. Skipping device interaction tests."
        }
    }
} catch {
    Assert-Warn "adb executable not found. Skipping ADB checks."
}

# ---------------------------------------------------------
# Teardown & Results
# ---------------------------------------------------------
Write-Host "`n========================================" -ForegroundColor Cyan
if ($global:failed -eq 0) {
    Write-Host "    ALL TESTS PASSED" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "    TESTS FAILED: $global:failed" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    exit 1
}
