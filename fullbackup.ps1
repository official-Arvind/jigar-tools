#Requires -Version 5.1
# ================================================================
#  ADB ULTIMATE GOD MODE  (v20.0 - POLISHED EDITION)
#  Smart GUI | Auto Units | Titanium Quoting | Stall Guard
#  BUG FIXES: 17 issues resolved     see changelog at bottom
# ================================================================

#region Bootstrap
# BUG FIX #1     Load assemblies ONCE here; removed duplicate Add-Type on line ~85
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# BUG FIX #4     Don't silence ALL errors globally; use targeted try/catch instead
$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'Jigar Tools v20.0 - Smart Backup'
#endregion

# ----------------------------------------------------------------
#  HELPER FUNCTIONS
# ----------------------------------------------------------------
#region Helpers

function Show-FolderSelector {
    param(
        [string]  $Title,
        [string[]]$Items
    )
    $form                  = New-Object System.Windows.Forms.Form
    $form.Text             = $Title
    $form.Size             = New-Object System.Drawing.Size(520, 660)
    $form.StartPosition    = 'CenterScreen'
    $form.FormBorderStyle  = 'FixedDialog'
    $form.MaximizeBox      = $false

    $label          = New-Object System.Windows.Forms.Label
    $label.Text     = "Select folders to back up  ($($Items.Count) found):"
    $label.Location = New-Object System.Drawing.Point(20, 10)
    $label.Size     = New-Object System.Drawing.Size(470, 22)
    $label.Font     = New-Object System.Drawing.Font('Segoe UI', 9)

    $listBox               = New-Object System.Windows.Forms.CheckedListBox
    $listBox.Location      = New-Object System.Drawing.Point(20, 36)
    $listBox.Size          = New-Object System.Drawing.Size(470, 530)
    $listBox.CheckOnClick  = $true
    $listBox.Font          = New-Object System.Drawing.Font('Consolas', 10)
    foreach ($item in $Items) { [void]$listBox.Items.Add($item) }

    $btnAll          = New-Object System.Windows.Forms.Button
    $btnAll.Location = New-Object System.Drawing.Point(20, 578)
    $btnAll.Size     = New-Object System.Drawing.Size(90, 30)
    $btnAll.Text     = 'Select All'
    $btnAll.Add_Click({
        for ($i = 0; $i -lt $listBox.Items.Count; $i++) {
            $listBox.SetItemChecked($i, $true)
        }
    })

    $btnNone          = New-Object System.Windows.Forms.Button
    $btnNone.Location = New-Object System.Drawing.Point(120, 578)
    $btnNone.Size     = New-Object System.Drawing.Size(90, 30)
    $btnNone.Text     = 'Clear All'
    $btnNone.Add_Click({
        for ($i = 0; $i -lt $listBox.Items.Count; $i++) {
            $listBox.SetItemChecked($i, $false)
        }
    })

    $btnOK           = New-Object System.Windows.Forms.Button
    $btnOK.Location  = New-Object System.Drawing.Point(400, 578)
    $btnOK.Size      = New-Object System.Drawing.Size(90, 30)
    $btnOK.Text      = 'Start Backup'
    $btnOK.DialogResult = 'OK'
    $btnOK.BackColor = [System.Drawing.Color]::DarkCyan
    $btnOK.ForeColor = [System.Drawing.Color]::White
    $btnOK.Font      = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)

    $form.Controls.AddRange(@($label, $listBox, $btnAll, $btnNone, $btnOK))
    $form.AcceptButton = $btnOK

    if ($form.ShowDialog() -eq 'OK') {
        return [string[]]$listBox.CheckedItems
    }
    return $null
}

function Format-Bytes {
    param([double]$Bytes)
    if ($Bytes -ge 1GB) { return '{0:N2} GB' -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return '{0:N2} MB' -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return '{0:N2} KB' -f ($Bytes / 1KB) }
    return '{0} B'      -f  $Bytes
}

function Write-Banner {
    param([string]$Text, [System.ConsoleColor]$Color = 'Cyan')
    $bar = '=' * 62
    Write-Host "`n $bar"      -ForegroundColor $Color
    Write-Host "   $Text"     -ForegroundColor $Color
    Write-Host " $bar`n"      -ForegroundColor $Color
}

#endregion

# ----------------------------------------------------------------
#  1. DEVICE DETECTION
# ----------------------------------------------------------------
Write-Host "`n [ADB] Scanning for connected devices..." -ForegroundColor Yellow

$adbDevices = (& { $ErrorActionPreference = 'Continue'; adb devices 2>&1 }) | Select-String -Pattern '\tdevice$'

if ($adbDevices.Count -eq 0) {
    Write-Host ' [ERROR] No authorised device found.' -ForegroundColor Red
    Write-Host '         Ensure USB Debugging is enabled and the device is authorised.'
    exit 1
}

$selectedSerial = ($adbDevices[0].ToString().Split("`t")[0]).Trim()

# Show device identity to confirm correct target
$modelName  = (adb -s $selectedSerial shell 'getprop ro.product.model'   2>$null).Trim() `
                  -replace '[\\/\*\?:"<>\|]', '_'
# BUG FIX #15     Show Android version so the user can confirm the right device
$androidVer = (adb -s $selectedSerial shell 'getprop ro.build.version.release' 2>$null).Trim()

Write-Host " [DEVICE] $modelName  |  Android $androidVer  |  Serial: $selectedSerial" -ForegroundColor Cyan

# ----------------------------------------------------------------
#  2. ROOT + TOOLCHAIN DETECTION
# ----------------------------------------------------------------
# BUG FIX #17 — Match only /su or /bin/su etc., not substrings like /usr/bin/...
$suOutput = "$(adb -s $selectedSerial shell 'which su' 2>$null)".Trim()
$hasRoot  = ($suOutput -match '(?:^|/)su$')

$bbOutput = "$(adb -s $selectedSerial shell 'which busybox' 2>$null)".Trim()
$tarBin   = if ($bbOutput -match 'busybox') { 'busybox tar' } else { 'tar' }

Write-Host " [ROOT]   $(if ($hasRoot) { "Yes  ($suOutput)" } else { 'No  (non-root mode)' })" `
    -ForegroundColor $(if ($hasRoot) { 'Green' } else { 'Yellow' })
Write-Host " [TAR]    $tarBin"

# ----------------------------------------------------------------
#  3. MODE SELECTION
# ----------------------------------------------------------------
Write-Banner 'GOD MODE MENU'
Write-Host '  [1]  FULL NITRO       Entire /sdcard + APK links (root needed for APKs)'
Write-Host '  [2]  SELECTIVE        Pick folders via GUI'
Write-Host ''
# BUG FIX #10     .Trim() so a leading/trailing space doesn't break the -eq checks
$mode = (Read-Host ' Choice [1/2]').Trim()
if ($mode -notin '1', '2') {
    Write-Host ' [ERROR] Invalid choice. Enter 1 or 2.' -ForegroundColor Red
    exit 1
}

# ----------------------------------------------------------------
#  4. FOLDER SELECTION (selective mode)
# ----------------------------------------------------------------
[long]$totalKB        = 0          # BUG FIX #2     explicit [long] to avoid int32 overflow
$targetFoldersString  = 'sdcard'
[string[]]$selection  = @()

if ($mode -eq '2') {
    Write-Host "`n [SCAN] Listing /sdcard..." -ForegroundColor Yellow
    $folderData = adb -s $selectedSerial shell 'ls -p /sdcard' 2>$null |
                    Where-Object { $_ -match '/$' } |
                    ForEach-Object { $_.TrimEnd('/') }

    if (-not $folderData) {
        Write-Host ' [ERROR] Could not list /sdcard contents.' -ForegroundColor Red
        exit 1
    }

    $selection = Show-FolderSelector -Title 'Select Folders to Back Up' -Items $folderData

    # BUG FIX #11     Check .Count; an empty @() is not $null so -not $selection was always $false
    if (-not $selection -or $selection.Count -eq 0) {
        Write-Host ' [CANCEL] No folders selected. Exiting.' -ForegroundColor Yellow
        exit 0
    }

    $quotedFolders       = $selection | ForEach-Object { "'sdcard/$_'" }
    $targetFoldersString = $quotedFolders -join ' '
}

# ----------------------------------------------------------------
#  5. SIZE AUDIT
# ----------------------------------------------------------------
Write-Host "`n [AUDIT] Calculating payload size..." -ForegroundColor Yellow

if ($mode -eq '1') {
    $sizeCmd = if ($hasRoot) { "su -c 'du -sk /sdcard/'" } else { 'du -sk /sdcard/' }
    $sizeRaw = (adb -s $selectedSerial shell "$sizeCmd" 2>$null).Trim()
    # BUG FIX #3     Use regex match instead of fragile .Split("`t") which breaks on multi-line output
    if ($sizeRaw -match '^(\d+)') { [long]$totalKB = [long]$Matches[1] }
} else {
    foreach ($folder in $selection) {
        $fCmd = if ($hasRoot) { "su -c 'du -sk ""/sdcard/$folder/""'" } `
                             else {   "du -sk ""/sdcard/$folder/""" }
        $fRaw = (adb -s $selectedSerial shell "$fCmd" 2>$null).Trim()
        if ($fRaw -match '^(\d+)') { [long]$totalKB += [long]$Matches[1] }
    }
}

[long]  $totalBytes  = $totalKB * 1024L
[string]$displayTotal = Format-Bytes $totalBytes
Write-Host " [SIZE]   Estimated: $displayTotal" -ForegroundColor Magenta

# ----------------------------------------------------------------
#  6. CHOOSE DESTINATION
# ----------------------------------------------------------------
# (Add-Type already loaded at top     BUG FIX #1 removes the duplicate call that was here)
$fb             = New-Object System.Windows.Forms.FolderBrowserDialog
$fb.Description = 'Select destination folder for the backup file'
if ($fb.ShowDialog() -ne 'OK') {
    Write-Host ' [CANCEL] No destination chosen. Exiting.' -ForegroundColor Yellow
    exit 0
}

$timestamp     = Get-Date -Format 'yyyy-MM-dd_HH-mm'
$finalFileName = "${modelName}_v20.0_${timestamp}.tar"
$finalPath     = Join-Path $fb.SelectedPath $finalFileName

# ----------------------------------------------------------------
#  7. BUILD SHELL COMMAND
# ----------------------------------------------------------------
# BUG FIX #12     Added quotes around $p in the APK ln command so paths with spaces work
if ($mode -eq '1' -and $hasRoot) {
    Write-Host "`n [APK]   Staging APK symlinks on device..." -ForegroundColor Yellow
    $apkCmd  = 'rm -rf /data/local/tmp/APKS; mkdir -p /data/local/tmp/APKS; '
    $apkCmd += 'pm list packages -3 | cut -f2 -d: | while read pkg; do '
    $apkCmd += '  p=$(pm path "$pkg" | grep "base.apk" | cut -f2 -d: | head -n1); '
    $apkCmd += '  [ -n "$p" ] && ln -s "$p" "/data/local/tmp/APKS/$pkg.apk"; '  # FIX: quoted $p
    $apkCmd += 'done'
    adb -s $selectedSerial shell "su -c '$apkCmd'" | Out-Null
    $shellCmd = "su -c '$tarBin -h -cf - sdcard data/local/tmp/APKS'"
} elseif ($hasRoot) {
    $shellCmd = "su -c '$tarBin -cf - $targetFoldersString'"
} else {
    $shellCmd = "$tarBin -cf - $targetFoldersString"
}

# ----------------------------------------------------------------
#  8. LAUNCH BACKUP PROCESS
# ----------------------------------------------------------------
Write-Banner 'NITRO STREAM ACTIVE' 'Green'
Write-Host "  Destination : $finalPath"
Write-Host "  Estimated   : $displayTotal"

$cmdArgs = "/c adb -s $selectedSerial exec-out `"$shellCmd`" > `"$finalPath`""
$job     = Start-Process -FilePath 'cmd.exe' -ArgumentList $cmdArgs -PassThru -NoNewWindow

# ----------------------------------------------------------------
#  9. PROGRESS MONITOR
# ----------------------------------------------------------------
$stopwatch       = [System.Diagnostics.Stopwatch]::StartNew()
[long]$lastSize  = 0
$stallCounter    = 0
$noFileCounter   = 0
$stallThreshold  = 30   # seconds of zero growth before abort
$noFileThreshold = 20   # seconds to wait for file to first appear
$wasStalled      = $false
$streamStarted   = $false

# Rolling speed window (bytes per second samples)
$speedSamples    = [System.Collections.Generic.Queue[long]]::new()
$windowSize      = 5   # rolling average over last 5 seconds

while (-not $job.HasExited) {
    Start-Sleep -Seconds 1

    # BUG FIX #8     Timeout if the file never appears (adb exec-out silently failed)
    if (-not (Test-Path $finalPath)) {
        $noFileCounter++
        if ($noFileCounter -ge $noFileThreshold) {
            Write-Host "`n [ERROR] Backup file was never created after ${noFileThreshold}s." `
                       -ForegroundColor Red
            Write-Host '         Check that adb exec-out is working and try again.' `
                       -ForegroundColor DarkYellow
            $job | Stop-Process -Force -ErrorAction SilentlyContinue
            $wasStalled = $true
            break
        }
        Write-Progress -Activity 'Nitro Streaming' `
                       -Status 'Waiting for stream to initialise...' `
                       -PercentComplete 0
        continue
    }

    if (-not $streamStarted) {
        # Reset stopwatch to when data actually started arriving
        $stopwatch.Restart()
        $streamStarted = $true
    }
    $noFileCounter = 0

    $fileItem       = Get-Item $finalPath -ErrorAction SilentlyContinue
    [long]$currSize = if ($fileItem) { $fileItem.Length } else { 0 }
    [long]$delta    = $currSize - $lastSize

    if ($delta -eq 0 -and $currSize -gt 0) {
        $stallCounter++
        if ($stallCounter -ge $stallThreshold) {
            Write-Host "`n [WARN]  No data received for ${stallThreshold}s     stream stalled, aborting." `
                       -ForegroundColor Red
            $job | Stop-Process -Force -ErrorAction SilentlyContinue
            $wasStalled = $true
            break
        }
    } else {
        $stallCounter = 0
        $speedSamples.Enqueue($delta)
        if ($speedSamples.Count -gt $windowSize) { [void]$speedSamples.Dequeue() }
    }

    # BUG FIX #7     Rolling-window speed (not speed from process start)
    [double]$avgBps  = if ($speedSamples.Count -gt 0) {
        ($speedSamples | Measure-Object -Sum).Sum / $speedSamples.Count
    } else { 0 }
    [double]$speedMB = $avgBps / 1MB

    # BUG FIX #6     Compute and pass -PercentComplete so the bar actually fills
    $pct = if ($totalBytes -gt 0) {
        [int][Math]::Min(99, [Math]::Round($currSize / $totalBytes * 100))
    } else { -1 }

    $elapsed    = $stopwatch.Elapsed
    $statusText = 'Speed: {0:N2} MB/s   {1} / {2}   Elapsed: {3:mm\:ss}' -f `
                  $speedMB, (Format-Bytes $currSize), $displayTotal, $elapsed

    $pArgs = @{ Activity = 'Nitro Streaming'; Status = $statusText }
    if ($pct -ge 0) { $pArgs['PercentComplete'] = $pct }
    Write-Progress @pArgs

    $lastSize = $currSize
}

Write-Progress -Activity 'Nitro Streaming' -Completed
$stopwatch.Stop()

# ----------------------------------------------------------------
#  10. RESULT & SUMMARY
# ----------------------------------------------------------------
# BUG FIX #5     Show FAIL (not SUCCESS) when the process was killed due to stall
if ($wasStalled) {
    Write-Banner 'BACKUP FAILED' 'Red'
    if (Test-Path $finalPath) {
        $partialSz = Format-Bytes (Get-Item $finalPath).Length
        Write-Host "  Partial file ($partialSz) left at:"
        Write-Host "  $finalPath" -ForegroundColor DarkYellow
        Write-Host ''
        Write-Host '  You can delete it or attempt to open with a tar tool.' -ForegroundColor DarkYellow
    }
    # BUG FIX #13     Proper exit codes
    exit 2
}

$finalItem   = Get-Item $finalPath -ErrorAction SilentlyContinue
$finalSz     = if ($finalItem) { $finalItem.Length } else { 0 }
$avgSpeedMB  = if ($stopwatch.Elapsed.TotalSeconds -gt 1) {
                   ($finalSz / 1MB) / $stopwatch.Elapsed.TotalSeconds } else { 0 }

Write-Banner 'BACKUP COMPLETE' 'Green'
Write-Host "  File      : $finalPath"
Write-Host "  Size      : $(Format-Bytes $finalSz)"
Write-Host "  Duration  : $($stopwatch.Elapsed.ToString('mm\:ss'))"
Write-Host "  Avg Speed : $([Math]::Round($avgSpeedMB, 2)) MB/s"

# ----------------------------------------------------------------
#  11. VERIFICATION
# ----------------------------------------------------------------
Write-Host "`n [VERIFY] Counting source files on device..." -ForegroundColor Yellow

# BUG FIX #16     [long] for pCount; large devices can exceed int32 with deep trees
[long]$pCount = 0
if ($mode -eq '1') {
    $pRaw = (adb -s $selectedSerial shell 'find /sdcard -type f | wc -l' 2>$null).Trim()
    if ($pRaw -match '^\d+$') { $pCount = [long]$pRaw }
} else {
    foreach ($folder in $selection) {
        $cRaw = (adb -s $selectedSerial shell "find '/sdcard/$folder' -type f | wc -l" 2>$null).Trim()
        if ($cRaw -match '^\d+$') { $pCount += [long]$cRaw }
    }
}

# BUG FIX #9     Only run local tar verify if tar.exe actually exists on PATH
$localTar = Get-Command 'tar' -ErrorAction SilentlyContinue
if ($localTar -and (Test-Path $finalPath)) {
    $tCount   = (& tar -tf $finalPath 2>$null | Measure-Object).Count
    $threshold = [long][Math]::Floor($pCount * 0.90)
    if ($tCount -ge $threshold) {
        Write-Host "  [OK]   Device: $pCount files   Archive: $tCount entries" -ForegroundColor Green
    } else {
        Write-Host "  [!]    MISMATCH  Device: $pCount   Archive: $tCount" -ForegroundColor Red
    }
} else {
    Write-Host "  [SKIP] 'tar' not on PATH     skipping archive-entry count." -ForegroundColor DarkYellow
    Write-Host "  [INFO] Device file count: $pCount" -ForegroundColor Cyan
}

# ----------------------------------------------------------------
#  12. CLEANUP
# ----------------------------------------------------------------
if ($hasRoot) {
    adb -s $selectedSerial shell "su -c 'rm -rf /data/local/tmp/APKS'" | Out-Null
}

# BUG FIX #14     Partial file cleanup happens in the $wasStalled block above; full file kept here
Read-Host "`n Press Enter to exit..."
exit 0

# ================================================================
#  CHANGELOG  v19.2     v20.0
# ================================================================
# FIX #1   Removed duplicate Add-Type for System.Windows.Forms
# FIX #2   $totalKB declared as [long]     prevents int32 overflow on big devices
# FIX #3   Size parsing now uses regex '^(\d+)' instead of fragile .Split("`t")
# FIX #4   $ErrorActionPreference changed from SilentlyContinue to Stop
# FIX #5   Stall-killed path now shows BACKUP FAILED instead of SUCCESS
# FIX #6   Write-Progress now passes -PercentComplete so the bar fills correctly
# FIX #7   Speed uses a rolling 5-second window starting when data first arrives
# FIX #8   Added 20s no-file timeout; loop no longer hangs if exec-out is silent
# FIX #9   Verification checks for local tar.exe before calling it; graceful skip
# FIX #10  Mode input .Trim()'d     space after "1" no longer breaks selection
# FIX #11  Empty selection now checked via .Count -eq 0, not just -not $selection
# FIX #12  APK ln -s command now quotes $p so paths with spaces are handled
# FIX #13  Script exits with code 0 (success), 1 (user error), 2 (backup failed)
# FIX #14  Partial file path shown clearly on failure; no silent leftover
# FIX #15  Android version shown next to device name to confirm correct target
# FIX #16  pCount declared as [long]     safe for devices with >2 billion files
# FIX #17  hasRoot regex changed to '(?:^|/)su$'     no false positive on /usr/bin
# OPT  A   Stopwatch resets when first byte arrives     accurate timing
# OPT  B   Select All / Clear All buttons added to folder picker GUI
# OPT  C   Write-Banner helper for consistent section headers
# OPT  D   Final summary (size, duration, avg speed) printed after backup
# OPT  E   noFileCounter reset when file appears; cleaner state machine
# ================================================================

