# ========================================================
#  PARANOID HIDDEN FILE CHECKER (Global Tool)
#  Scans the folder you are currently standing in.
# ========================================================

$ErrorActionPreference = "SilentlyContinue"
$localRoot = (Get-Location).Path

Write-Host " [PARANOID CHECK MODE]" -ForegroundColor Cyan
Write-Host " Scanning: $localRoot" -ForegroundColor Gray
Write-Host ""

# 1. Count Visible Files (Standard Scan)
$visibleFiles = Get-ChildItem -LiteralPath $localRoot -Recurse -File
$visibleCount = $visibleFiles.Count

# 2. Count ALL Files (Force Mode - Includes Hidden/System)
$allFiles = Get-ChildItem -LiteralPath $localRoot -Recurse -File -Force
$allCount = $allFiles.Count

# 3. The Math
$hiddenCount = $allCount - $visibleCount

Write-Host " Visible Files: $visibleCount" -ForegroundColor Green
Write-Host " Total Files:   $allCount" -ForegroundColor Yellow
Write-Host " ---------------------"

if ($hiddenCount -eq 0) {
    Write-Host " RESULT: 100% CLEAN." -ForegroundColor Green
    Write-Host " No hidden files found. You are safe."
} else {
    Write-Host " RESULT: $hiddenCount HIDDEN FILES FOUND!" -ForegroundColor Red
    Write-Host " These were NOT backed up by the default script."
    Write-Host " To back them up, edit restore.ps1 and add '-Force' to the Get-ChildItem line."
    
    # Optional: List the hidden files so you know what they are
    Write-Host ""
    Write-Host " Hidden Files List:" -ForegroundColor Magenta
    Compare-Object -ReferenceObject $visibleFiles -DifferenceObject $allFiles -PassThru | Select-Object FullName
}

Write-Host ""
Read-Host " Press Enter to exit..."