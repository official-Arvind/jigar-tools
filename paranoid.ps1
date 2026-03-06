# ========================================================
#  PARANOID HIDDEN FILE CHECKER (v2.0)
#  - Feature: FolderBrowserDialog for target selection
#  - Feature: GridView selection for specific subfolders
# ========================================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "Jigar Tools v2.0 - Paranoid Audit"

Write-Host " [PARANOID CHECK MODE]" -ForegroundColor Cyan

# 1. Choose Target Directory
Write-Host " [ACTION] Target folder select karo jisse audit karna hai..." -ForegroundColor Yellow
Add-Type -AssemblyName System.Windows.Forms
$fb = New-Object System.Windows.Forms.FolderBrowserDialog
$fb.Description = "Select the local folder to audit for hidden files"
if ($fb.ShowDialog() -ne "OK") { exit }
$localRoot = $fb.SelectedPath

# 2. Main Menu
Write-Host "`n [AUDIT MENU]" -ForegroundColor Cyan
Write-Host "  [1] SCAN ENTIRE FOLDER ($localRoot)"
Write-Host "  [2] SELECT SPECIFIC SUBFOLDERS"
$mode = Read-Host "`n Choice"

$foldersToScan = @()

if ($mode -eq "2") {
    Write-Host "`n [SCANNING] Indexing subdirectories..." -ForegroundColor Yellow
    $dirs = Get-ChildItem -LiteralPath $localRoot -Directory | Select-Object -ExpandProperty Name
    if (-not $dirs) { Write-Host " [ERROR] No subfolders found!"; exit }
    
    Write-Host " [ACTION] SPACEBAR dabao highlight (glow) karne ke liye!" -ForegroundColor Magenta
    $selection = $dirs | Out-GridView -Title "Pick Subfolders to Audit" -OutputMode Multiple
    if (-not $selection) { exit }
    
    foreach ($sel in $selection) {
        $foldersToScan += Join-Path -Path $localRoot -ChildPath $sel
    }
} else {
    $foldersToScan += $localRoot
}

# 3. The Deep Scan
$visibleCount = 0
$allCount = 0
$hiddenFilesList = @()

Write-Host "`n [AUDITING] Seeking the truth... Please wait." -ForegroundColor Yellow

foreach ($target in $foldersToScan) {
    # Count Visible
    $visibleFiles = Get-ChildItem -LiteralPath $target -Recurse -File
    $visibleCount += @($visibleFiles).Count

    # Count ALL (Force flag grabs Hidden/System)
    $allFiles = Get-ChildItem -LiteralPath $target -Recurse -File -Force
    $allCount += @($allFiles).Count

    $diff = Compare-Object -ReferenceObject $visibleFiles -DifferenceObject $allFiles -PassThru
    if ($diff) {
        $hiddenFilesList += $diff | Select-Object -ExpandProperty FullName
    }
}

# 4. The Math
$hiddenCount = $allCount - $visibleCount

Write-Host "`n ---------------------"
Write-Host " Visible Files: $visibleCount" -ForegroundColor Green
Write-Host " Total Files:   $allCount" -ForegroundColor Yellow
Write-Host " ---------------------"

if ($hiddenCount -eq 0) {
    Write-Host "`n RESULT: 100% CLEAN." -ForegroundColor Green
    Write-Host " No hidden files found. You are safe."
} else {
    Write-Host "`n RESULT: $hiddenCount HIDDEN FILES FOUND!" -ForegroundColor Red
    Write-Host " These were NOT backed up by standard processes."
    
    Write-Host "`n Hidden Files List:" -ForegroundColor Magenta
    foreach ($hf in $hiddenFilesList) {
        Write-Host " -> $hf" -ForegroundColor Gray
    }
}

Write-Host ""
Read-Host " Press Enter to exit..."