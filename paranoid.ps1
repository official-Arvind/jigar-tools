# ========================================================
#  JIGAR TOOLS: PARANOID VERIFIER (v3.2 - TITANIUM AUDIT)
#  - Fix: Hardened Shell Escaping (Single Quotes) for (1).. files
#  - Feature: Forensic Integrity Check (PC vs Phone)
#  - GUI: GridView for Targeted Audits
# ========================================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "Jigar Tools v3.2 - Paranoid Verify"

# 1. Device Connection
Write-Host "`n [SYSTEM] Connecting to Device..." -ForegroundColor Cyan
$adbDevices = adb devices | Select-String -Pattern "\tdevice$"
if ($adbDevices.Count -eq 0) { Write-Host " [ERROR] Device connect karo, Arvind Ji!" -ForegroundColor Red; exit }
$selectedSerial = $adbDevices[0].ToString().Split("`t")[0].Trim()

# 2. Select PC Source
Write-Host "`n [SOURCE] PC par woh folder chuno jo verify karna hai..." -ForegroundColor Yellow
Add-Type -AssemblyName System.Windows.Forms
$fb = New-Object System.Windows.Forms.FolderBrowserDialog
$fb.Description = "SELECT PC FOLDER TO VERIFY"
if ($fb.ShowDialog() -ne "OK") { exit }
$localTarget = $fb.SelectedPath

# 3. Path Intelligence (Auto-Map)
$remoteBase = "/sdcard"
if ($localTarget -match "sdcard") {
    $rel = $localTarget.Substring($localTarget.IndexOf("sdcard") + 6).Replace('\', '/')
    $remoteBase = "/sdcard$rel"
}
Write-Host " [MAPPING] PC: $localTarget  ->  Phone: $remoteBase" -ForegroundColor Gray

# 4. Selective Mode
Write-Host "`n [AUDIT MENU]" -ForegroundColor Cyan
Write-Host "  [1] VERIFY EVERYTHING (Deep Scan)"
Write-Host "  [2] SELECTIVE VERIFY (Pick Subfolders)"
$mode = Read-Host "`n Choice"

$itemsToScan = @()

if ($mode -eq "2") {
    Write-Host "`n [SCANNING] Indexing folders..." -ForegroundColor Yellow
    $dirs = Get-ChildItem -LiteralPath $localTarget -Directory | Select-Object -ExpandProperty Name
    
    Write-Host " [ACTION] GridView: SPACEBAR se select karo!" -ForegroundColor Magenta
    $selection = $dirs | Out-GridView -Title "AUDIT SELECTION: Select Folders (Spacebar to Glow) -> Enter" -OutputMode Multiple
    if (-not $selection) { Write-Host " [CANCELLED]"; exit }
    
    foreach ($sel in $selection) {
        $itemsToScan += Get-ChildItem -LiteralPath "$localTarget\$sel" -Recurse -File
    }
} else {
    $itemsToScan = Get-ChildItem -LiteralPath $localTarget -Recurse -File
}

$totalFiles = @($itemsToScan).Count
Write-Host "`n [LOCKED] Forensic Verification of $totalFiles files." -ForegroundColor Cyan

# 5. The Forensic Loop (Titanium Shield)
$missing = 0
$corrupt = 0
$valid = 0
$i = 0

foreach ($file in $itemsToScan) {
    $i++
    $percent = [math]::Round(($i / $totalFiles) * 100)
    
    # Calculate Relative Path
    $relPath = $file.FullName.Substring($localTarget.Length).Replace('\', '/')
    if (-not $relPath.StartsWith("/")) { $relPath = "/$relPath" }
    
    # Titanium Shield: Escape single quotes manually, then wrap in single quotes
    $remoteFile = "$remoteBase$relPath".Replace('//','/')
    $remoteFileEscaped = $remoteFile.Replace("'", "'\''")
    $remoteShell = "'$remoteFileEscaped'" 

    Write-Progress -Activity "Forensic Verification" -Status "Auditing: $relPath" -PercentComplete $percent

    # Fetch Phone Size (Robust)
    $remoteSizeStr = (adb -s $selectedSerial shell "stat -c %s $remoteShell 2>/dev/null").Trim()
    
    if ($remoteSizeStr -notmatch '^\d+$') {
        # Double check if file exists but stat failed due to permissions
        Write-Host " [MISSING] $relPath" -ForegroundColor Red
        $missing++
    } elseif ([long]$remoteSizeStr -ne $file.Length) {
        Write-Host " [CORRUPT] $relPath (PC: $($file.Length) | Phone: $remoteSizeStr)" -ForegroundColor Magenta
        $corrupt++
    } else {
        $valid++
    }
}

# 6. The Verdict
Write-Host "`n ========================================================"
Write-Host "  AUDIT REPORT" -ForegroundColor Yellow
Write-Host "  --------------------------------------------------------"
Write-Host "  [+] Verified Clean: $valid" -ForegroundColor Green
if ($missing -gt 0) { Write-Host "  [-] Missing on Phone: $missing" -ForegroundColor Red }
if ($corrupt -gt 0) { Write-Host "  [!] Size Mismatch : $corrupt" -ForegroundColor Magenta }
Write-Host " ========================================================"

Read-Host " Press Enter to close case..."