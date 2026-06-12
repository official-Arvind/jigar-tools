#Requires -Version 5.1
# ================================================================
#  JIGAR TOOLS v2.0 Gold Edition - ABSOLUTE VELOCITY (RESTORE - TITAN ENGINE)
#  NEW in v2.0 Gold Edition:
#  - Interactive INCLUDE Sub-Menu (TreeView GUI with lazy loading)
#  - Granular folder/subfolder/file selection for partial restores
#  - Most-specific-ancestor filter logic for partial selections
#  ------------------------------------------------------------
#  From v2.0 Gold Edition:
#  - Smart Numbered Backup Menu (reads saved location)
#  - Location Memory (settings.json)
#  - Persistent Logging (Logs\ folder)
#  - Graceful Ctrl+C Cancellation with ADB Temp Cleanup
#  - 3-Stage Fallback: Unconditionally defeats all ADB path bugs
#  - 12x Parallel Push: Restores files PCâ†’Phone at massive speed
# ================================================================

# ================================================================
#  INTERACTIVE SELECTION ENGINE  (shared helper functions)
#  - Build-JgrPathIndex    : flat path list â†’ nested hashtable
#  - Add-JgrTreeChildren   : lazy-populate a TreeView node
#  - Set-JgrCheckedDeep    : propagate checked state to children
#  - Get-JgrNodeStates     : harvest pathâ†’bool map from live tree
#  - Show-JigarIncludeMenu : full WinForms GUI (INCLUDE mode)
#  - Test-JgrIncluded      : most-specific-ancestor lookup
# ================================================================
Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.Drawing;

$script:JgrPlaceholder    = '__JGR_PH__';
$script:SuppressTreeCheck = $false;

function Build-JgrPathIndex {
    param([string[]] $Paths)
    $idx = [System.Collections.Generic.Dictionary[string,
        [System.Collections.Generic.SortedSet[string]]]]::new(
        [System.StringComparer]::OrdinalIgnoreCase);
    foreach ($p in $Paths) {
        $rel   = $p -replace '^\.\./', '' -replace '^\./', '';
        $parts = $rel.Split('/');
        for ($d = 0; $d -lt $parts.Count; $d++) {
            $pk = if ($d -eq 0) { '' } else { ($parts[0..($d-1)]) -join '/' };
            if (-not $idx.ContainsKey($pk)) {
                $idx[$pk] = [System.Collections.Generic.SortedSet[string]]::new(
                    [System.StringComparer]::OrdinalIgnoreCase);
            }
            [void]$idx[$pk].Add($parts[$d]);
        }
    }
    return $idx;
}

function Add-JgrTreeChildren {
    param(
        [System.Windows.Forms.TreeNode] $Parent,
        [object]  $Index,
        [string]  $ParentPath,
        [bool]    $Checked
    )
    $Parent.Nodes.Clear();
    if (-not $Index.ContainsKey($ParentPath)) { return };
    foreach ($child in $Index[$ParentPath]) {
        $childPath = if ($ParentPath -eq '') { $child } else { "$ParentPath/$child" };
        $tn        = [System.Windows.Forms.TreeNode]::new($child);
        $tn.Tag    = $childPath;
        $tn.Checked = $Checked;
        $isFolder  = $Index.ContainsKey($childPath);
        if ($isFolder) {
            $tn.NodeFont  = [System.Drawing.Font]::new('Segoe UI', 9,
                [System.Drawing.FontStyle]::Bold);
            [void]$tn.Nodes.Add([System.Windows.Forms.TreeNode]::new($script:JgrPlaceholder));
        } else {
            $tn.ForeColor = [System.Drawing.Color]::FromArgb(160, 255, 200);
        }
        [void]$Parent.Nodes.Add($tn);
    }
}

function Set-JgrCheckedDeep {
    param([System.Windows.Forms.TreeNode] $Node, [bool] $State)
    $Node.Checked = $State;
    foreach ($child in $Node.Nodes) {
        if ($child.Text -ne $script:JgrPlaceholder) {
            Set-JgrCheckedDeep -Node $child -State $State;
        }
    }
}

function Get-JgrNodeStates {
    param(
        [System.Windows.Forms.TreeNodeCollection] $Nodes,
        [hashtable] $States
    )
    foreach ($n in $Nodes) {
        if ($n.Text -eq $script:JgrPlaceholder) { continue };
        $States[$n.Tag.ToString()] = $n.Checked;
        Get-JgrNodeStates -Nodes $n.Nodes -States $States;
    }
}

function Test-JgrIncluded {
    # Returns $true if the file should be INCLUDED (most-specific ancestor wins)
    # Default is $false so that nothing is included unless explicitly checked.
    param([string] $RelPath, [hashtable] $NodeStates)
    $path  = $RelPath -replace '^\./', '';
    $parts = $path.Split('/');
    $best  = $false;   # default: NOT included
    for ($d = 1; $d -le $parts.Count; $d++) {
        $ancestor = ($parts[0..($d-1)]) -join '/';
        if ($NodeStates.ContainsKey($ancestor)) { $best = $NodeStates[$ancestor] };
    }
    return $best;
}

function Show-JigarIncludeMenu {
    param(
        [string]   $FormTitle,
        [string[]] $FilePaths
    )

    $pathIndex = Build-JgrPathIndex -Paths $FilePaths;

    # -- Form ------------------------------------------------------
    $form = [System.Windows.Forms.Form]::new();
    $form.Text          = $FormTitle;
    $form.Size = [System.Drawing.Size]::new(700, 550);
    $form.MinimumSize   = [System.Drawing.Size]::new(580, 500);
    $form.StartPosition = 'CenterScreen';
    $form.BackColor     = [System.Drawing.Color]::FromArgb(14, 22, 18);
    $form.ForeColor     = [System.Drawing.Color]::FromArgb(220, 240, 220);

    # -- Top instruction banner -------------------------------------
    $pnlTop = [System.Windows.Forms.Panel]::new();
    $pnlTop.Dock      = 'Top';
    $pnlTop.Height    = 62;
    $pnlTop.BackColor = [System.Drawing.Color]::FromArgb(14, 28, 14);
    $pnlTop.Padding   = [System.Windows.Forms.Padding]::new(12, 8, 12, 4);

    $lblTitle = [System.Windows.Forms.Label]::new();
    $lblTitle.Text      = '[INCLUDE] SELECT FOLDERS / FILES TO INCLUDE IN RESTORE';
    $lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(80, 230, 130);
    $lblTitle.Font      = [System.Drawing.Font]::new('Segoe UI', 10,
        [System.Drawing.FontStyle]::Bold);
    $lblTitle.Dock      = 'Top';
    $lblTitle.Height    = 26;

    $lblSub = [System.Windows.Forms.Label]::new();
    $lblSub.Text      = '  Only CHECKED items will be restored. Press "Restore All" to skip this filter.';
    $lblSub.ForeColor = [System.Drawing.Color]::FromArgb(100, 180, 120);
    $lblSub.Font      = [System.Drawing.Font]::new('Segoe UI', 8);
    $lblSub.Dock      = 'Top';
    $lblSub.Height    = 20;

    $pnlTop.Controls.Add($lblSub);
    $pnlTop.Controls.Add($lblTitle);

    # -- Status strip ---------------------------------------------
    $status = [System.Windows.Forms.ToolStripStatusLabel]::new();
    $status.Text      = '0 item(s) selected for restore';
    $status.ForeColor = [System.Drawing.Color]::FromArgb(100, 220, 160);
    $statusBar = [System.Windows.Forms.StatusStrip]::new();
    $statusBar.BackColor = [System.Drawing.Color]::FromArgb(10, 18, 12);
    [void]$statusBar.Items.Add($status);

    # -- TreeView -------------------------------------------------
    $tv = [System.Windows.Forms.TreeView]::new();
    $tv.CheckBoxes  = $true;
    $tv.Dock        = 'Fill';
    $tv.Font        = [System.Drawing.Font]::new('Segoe UI', 9);
    $tv.BackColor   = [System.Drawing.Color]::FromArgb(18, 28, 22);
    $tv.ForeColor   = [System.Drawing.Color]::FromArgb(200, 235, 210);
    $tv.BorderStyle = 'None';
    $tv.Scrollable  = $true;

    # -- Bottom panel ---------------------------------------------
    $pnlBot = [System.Windows.Forms.Panel]::new();
    $pnlBot.Dock      = 'Bottom';
    $pnlBot.Height    = 54;
    $pnlBot.BackColor = [System.Drawing.Color]::FromArgb(10, 18, 12);
    $pnlBot.Padding   = [System.Windows.Forms.Padding]::new(10, 10, 10, 0);

    $mkBtn = {
        param([string]$T, [int]$X, [string]$BG6)
        $b = [System.Windows.Forms.Button]::new();
        $b.Text      = $T;
        $b.Size      = [System.Drawing.Size]::new(100, 34);
        $b.Location  = [System.Drawing.Point]::new($X, 10);
        $b.FlatStyle = 'Flat';
        $b.BackColor = [System.Drawing.ColorTranslator]::FromHtml($BG6);
        $b.ForeColor = [System.Drawing.Color]::White;
        $b.Font      = [System.Drawing.Font]::new('Segoe UI', 8);
        $b.FlatAppearance.BorderSize = 0;
        return $b;
    }

    $btnAll      = & $mkBtn 'Check All'  10  '#1a5c2e';
    $btnNone     = & $mkBtn 'Clear All'   115 '#3a3a1a';
    $btnExpand   = & $mkBtn 'Expand All'  220 '#1a2d5c';
    $btnCollapse = & $mkBtn 'Collapse'    325 '#2e2e40';

    $btnProceed = [System.Windows.Forms.Button]::new();
    $btnProceed.Text      = 'Restore Selected';
    $btnProceed.Size      = [System.Drawing.Size]::new(140, 34);
    $btnProceed.FlatStyle = 'Flat';
    $btnProceed.BackColor = [System.Drawing.Color]::FromArgb(20, 140, 60);
    $btnProceed.ForeColor = [System.Drawing.Color]::White;
    $btnProceed.Font      = [System.Drawing.Font]::new('Segoe UI', 9,
        [System.Drawing.FontStyle]::Bold);
    $btnProceed.FlatAppearance.BorderSize = 0;
    $btnProceed.Anchor      = 'Bottom, Right';
    $btnProceed.DialogResult = 'OK';

    $btnSkip = [System.Windows.Forms.Button]::new();
    $btnSkip.Text      = 'Restore All (Skip)';
    $btnSkip.Size      = [System.Drawing.Size]::new(140, 34);
    $btnSkip.FlatStyle = 'Flat';
    $btnSkip.BackColor = [System.Drawing.Color]::FromArgb(50, 65, 50);
    $btnSkip.ForeColor = [System.Drawing.Color]::White;
    $btnSkip.Font      = [System.Drawing.Font]::new('Segoe UI', 9);
    $btnSkip.FlatAppearance.BorderSize = 0;
    $btnSkip.Anchor       = 'Bottom, Right';
    $btnSkip.DialogResult = 'Cancel';

    $form.add_Resize({
        $btnProceed.Location = [System.Drawing.Point]::new($pnlBot.Width - 155, 10);
        $btnSkip.Location    = [System.Drawing.Point]::new($pnlBot.Width - 300, 10);
    })
    $btnProceed.Location = [System.Drawing.Point]::new(630, 10);
    $btnSkip.Location    = [System.Drawing.Point]::new(485, 10);

    $pnlBot.Controls.AddRange(@($btnAll, $btnNone, $btnExpand, $btnCollapse,
                                 $btnProceed, $btnSkip));
    $form.AcceptButton = $btnProceed;
    $form.CancelButton = $btnSkip;

    # -- Populate root nodes ---------------------------------------
    $tv.BeginUpdate();
    if ($pathIndex.ContainsKey('')) {
        foreach ($child in $pathIndex['']) {
            $tn       = [System.Windows.Forms.TreeNode]::new($child);
            $tn.Tag   = $child;
            $tn.Checked = $false;
            $isFolder   = $pathIndex.ContainsKey($child);
            if ($isFolder) {
                $tn.NodeFont = [System.Drawing.Font]::new('Segoe UI', 9,
                    [System.Drawing.FontStyle]::Bold);
                [void]$tn.Nodes.Add(
                    [System.Windows.Forms.TreeNode]::new($script:JgrPlaceholder));
            } else {
                $tn.ForeColor = [System.Drawing.Color]::FromArgb(160, 255, 200);
            }
            [void]$tv.Nodes.Add($tn);
        }
    }
    $tv.EndUpdate();

    # -- Helper: refresh status bar count -------------------------
    $updateStatus = {
        $st = @{};
        Get-JgrNodeStates -Nodes $tv.Nodes -States $st;
        $c = ($st.Values | Where-Object { $_ -eq $true }).Count;
        $status.Text = "$c item(s) selected for restore";
    };

    # -- Events ----------------------------------------------------
    $tv.add_BeforeExpand({
        param($s, $e)
        $node = $e.Node;
        if ($node.Nodes.Count -eq 1 -and
            $node.Nodes[0].Text -eq $script:JgrPlaceholder) {
            $s.BeginUpdate();
            Add-JgrTreeChildren -Parent $node -Index $pathIndex `
                -ParentPath $node.Tag.ToString() -Checked $node.Checked;
            $s.EndUpdate();
        }
    });

    $tv.add_AfterCheck({
        param($s, $e)
        if ($script:SuppressTreeCheck) { return };
        $script:SuppressTreeCheck = $true;
        Set-JgrCheckedDeep -Node $e.Node -State $e.Node.Checked;
        $script:SuppressTreeCheck = $false;
        & $updateStatus;
    });

    $btnAll.add_Click({
        $script:SuppressTreeCheck = $true;
        $tv.BeginUpdate();
        foreach ($n in $tv.Nodes) { Set-JgrCheckedDeep -Node $n -State $true };
        $tv.EndUpdate();
        $script:SuppressTreeCheck = $false;
        & $updateStatus;
    });

    $btnNone.add_Click({
        $script:SuppressTreeCheck = $true;
        $tv.BeginUpdate();
        foreach ($n in $tv.Nodes) { Set-JgrCheckedDeep -Node $n -State $false };
        $tv.EndUpdate();
        $script:SuppressTreeCheck = $false;
        & $updateStatus;
    });

    $btnExpand.add_Click({ $tv.ExpandAll() });
    $btnCollapse.add_Click({ $tv.CollapseAll() });

    $form.Controls.Add($tv);
    $form.Controls.Add($pnlTop);
    $form.Controls.Add($pnlBot);
    $form.Controls.Add($statusBar);

    $dlgResult  = $form.ShowDialog();
    $nodeStates = @{};
    if ($dlgResult -eq 'OK') {
        Get-JgrNodeStates -Nodes $tv.Nodes -States $nodeStates;
    }
    $form.Dispose();
    if ($dlgResult -ne 'OK') { return $null };  # null = restore all
    return $nodeStates;
}

& chcp 65001 | Out-Null;
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8;
$ProgressPreference = 'Continue';
$Host.UI.RawUI.WindowTitle = 'Jigar Tools v2.0 Gold Edition - Titan Restore';
$ErrorActionPreference = 'SilentlyContinue';
[System.Environment]::SetEnvironmentVariable("LC_ALL", "C.UTF-8");

# ----------------------------------------------------------------
#  LOGGING INIT
# ----------------------------------------------------------------
$LogsDir = Join-Path $PSScriptRoot "Logs";
if (-not (Test-Path $LogsDir)) { New-Item -ItemType Directory -Force -Path $LogsDir | Out-Null };
$LogTimestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss";
$LogFile = Join-Path $LogsDir "RestoreLog_$LogTimestamp.txt";
Start-Transcript -Path $LogFile -Append | Out-Null;

Write-Host "`n ==============================================================" -ForegroundColor Cyan;
Write-Host "   JIGAR SMART RESTORE v2.0 Gold Edition  (12x THREADS + 3-STAGE TITAN FALLBACK)" -ForegroundColor Cyan;
Write-Host " ==============================================================" -ForegroundColor Cyan;
Write-Host "   Log: $LogFile" -ForegroundColor DarkGray;

# ----------------------------------------------------------------
#  0. AUTO-CLEANUP ORPHANED VIRTUAL DRIVES
# ----------------------------------------------------------------
$SettingsFile = Join-Path $PSScriptRoot "settings.json";
$savedBase = "";
if (Test-Path $SettingsFile) {
    try { $parsed = Get-Content $SettingsFile -Raw | ConvertFrom-Json; if ($parsed.LastBackupLocation) { $savedBase = $parsed.LastBackupLocation } } catch {};
}

$substOut = & subst;
if ($substOut) {
    foreach ($line in $substOut) {
        if ($line -match "^([A-Z]:\\): => (.*)$") {
            $drv = $Matches[1].TrimEnd('\');
            $targetPath = $Matches[2];
            if (($savedBase -and $targetPath.StartsWith($savedBase)) -or $targetPath -match "Smart_Backup|_\d{4}-\d\d-\d\d_") {
                & subst $drv /D | Out-Null;
            }
        }
    }
}

# ----------------------------------------------------------------
#  1. PROVISION ADB
# ----------------------------------------------------------------
$toolDir = Join-Path $PSScriptRoot "bin";
if (-not (Test-Path $toolDir)) { New-Item -ItemType Directory -Force -Path $toolDir | Out-Null };
$adbExe = Join-Path $toolDir "adb.exe";

if (-not (Test-Path $adbExe)) {
    Write-Host "`n[SYSTEM] Downloading Official ADB Drivers..." -ForegroundColor Yellow;
    $url     = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip";
    $zipPath = Join-Path $toolDir "tools.zip";
    Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing;
    Expand-Archive -Path $zipPath -DestinationPath $toolDir -Force;
    Move-Item -Path "$toolDir\platform-tools\*" -Destination $toolDir -Force;
    Remove-Item -Path $zipPath, "$toolDir\platform-tools" -Recurse -Force;
}

& $adbExe start-server | Out-Null;
& $adbExe root | Out-Null;
Start-Sleep -Seconds 2;
$devices = (& $adbExe devices 2>$null) | Select-String -Pattern '\tdevice$';
if (-not $devices -or $devices.Count -eq 0) {
    Write-Host "`n[ERROR] No device found. Plug in phone and enable USB Debugging." -ForegroundColor Red;
    Stop-Transcript | Out-Null;
    Read-Host "Press Enter to exit...";
    exit;
}
$serial = ($devices[0].ToString().Split("`t")[0]).Trim();
Write-Host "[SYSTEM] Device Connected & Verified!" -ForegroundColor Green;

# ----------------------------------------------------------------
#  1.5. DETECT ROOT & BUSYBOX CAPABILITIES
# ----------------------------------------------------------------
Write-Host "[SYSTEM] Probing device capabilities..." -ForegroundColor Yellow;

$isAdbRoot = $false;
$isSuRoot  = $false;
$busyboxPath = $null;

# 1. Check if ADB is already running as root
$whoami = (& $adbExe -s $serial shell id 2>$null);
if ($whoami -match "uid=0\(root\)") {
    $isAdbRoot = $true;
    Write-Host "[SYSTEM] Root Status: Native ADB Root active" -ForegroundColor Green;
} else {
    # 2. Check if su is available
    $suTest = (& $adbExe -s $serial shell "su -c 'id'" 2>$null);
    if ($suTest -match "uid=0\(root\)") {
        $isSuRoot = $true;
        Write-Host "[SYSTEM] Root Status: Root via su (APatch/Magisk/KernelSU) verified" -ForegroundColor Green;
    } else {
        Write-Host "[SYSTEM] Root Status: Non-Rooted Device" -ForegroundColor Yellow;
    }
}

# 3. Detect BusyBox NDK or others
$bbPaths = @(
    "busybox",
    "/data/adb/modules/busybox-ndk/system/xbin/busybox",
    "/data/adb/modules/busybox-ndk/system/bin/busybox",
    "/data/adb/magisk/busybox",
    "/system/xbin/busybox",
    "/system/bin/busybox",
    "/sbin/busybox",
    "/data/local/tmp/busybox"
)

foreach ($path in $bbPaths) {
    $test = $null;
    if ($isAdbRoot) {
        $test = (& $adbExe -s $serial shell "$path" 2>$null);
    } elseif ($isSuRoot) {
        $escapedPath = $path -replace "'", "'\''";
        $test = (& $adbExe -s $serial shell "su -c '$escapedPath'" 2>$null);
    } else {
        $test = (& $adbExe -s $serial shell "$path" 2>$null);
    }
    $testStr = if ($test) { $test -join "`n" } else { "" };
    if ($testStr -match "BusyBox v") {
        $busyboxPath = $path;
        $bbVersion = "";
        if ($testStr -match "BusyBox v[0-9.]+\S*") {
            $bbVersion = $Matches[0];
        }
        Write-Host "[SYSTEM] BusyBox     : Found at '$busyboxPath' ($bbVersion)" -ForegroundColor Green;
        break;
    }
}

if (-not $busyboxPath) {
    Write-Host "[SYSTEM] BusyBox     : Not found (proceeding with toybox/toolbox)" -ForegroundColor Yellow;
}

# ----------------------------------------------------------------
#  FEATURE 5: GRACEFUL CTRL+C CANCELLATION HANDLER
# ----------------------------------------------------------------
$global:JigarAbort = $false;

$cancelHandler = [System.ConsoleCancelEventHandler]{
    param($sender, $e)
    $e.Cancel = $true;
    $global:JigarAbort = $true;
    Write-Host "`n`n[ABORT] Ctrl+C detected. Finishing current batch safely..." -ForegroundColor Red;
};
[System.Console]::add_CancelKeyPress($cancelHandler);

# ----------------------------------------------------------------
#  2. BACKUP SOURCE SELECTION (Feature 2 + 4: Smart Numbered Menu)
# ----------------------------------------------------------------
Add-Type -AssemblyName System.Windows.Forms;

$SettingsFile = Join-Path $PSScriptRoot "settings.json";
$Settings = @{ LastBackupLocation = "" };
if (Test-Path $SettingsFile) {
    try { $parsed = Get-Content $SettingsFile -Raw | ConvertFrom-Json; if ($parsed.LastBackupLocation) { $Settings.LastBackupLocation = $parsed.LastBackupLocation } } catch {};
}

$savedBase = $Settings.LastBackupLocation;
$restoreRoot = $null;

# Try to list available backup folders from saved location
if ($savedBase -and (Test-Path $savedBase)) {
    $backupFolders = Get-ChildItem -Path $savedBase -Directory |
        Sort-Object Name -Descending;

    if ($backupFolders.Count -gt 0) {
        Write-Host "`n[RESTORE] Available backups in: $savedBase" -ForegroundColor Yellow;
        Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray;

        $idx = 1;
        foreach ($folder in $backupFolders) {
            # Color-code by age: newer folders are brighter
            $color = if ($idx -le 3) { "Green" } elseif ($idx -le 7) { "Cyan" } else { "DarkGray" };
            Write-Host "  [$idx] $($folder.Name)" -ForegroundColor $color;
            $idx++;
        }
        $browseIdx = $idx;
        Write-Host "  [$browseIdx] Browse for another folder..." -ForegroundColor White;
        Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray;

        $choice = $null;
        while ($true) {
            $raw = "1"; # Test Override
            if ($raw -match '^\d+$') {
                $choiceNum = [int]$raw;
                if ($choiceNum -ge 1 -and $choiceNum -lt $browseIdx) {
                    $restoreRoot = $backupFolders[$choiceNum - 1].FullName;
                    Write-Host "`n[RESTORE] Selected: $restoreRoot" -ForegroundColor Green;
                    break;
                } elseif ($choiceNum -eq $browseIdx) {
                    # Fall through to FolderBrowserDialog below
                    break;
                }
            }
            Write-Host "  [!] Invalid choice. Enter a number between 1 and $browseIdx." -ForegroundColor Red;
        }
    }
}

# Fallback: FolderBrowserDialog if no folders found or user chose Browse
if (-not $restoreRoot) {
    Write-Host "`n[SOURCE] Select Backup Folder..." -ForegroundColor Yellow;
    $fb = New-Object System.Windows.Forms.FolderBrowserDialog;
    $fb.Description = "Select Backup Folder to Restore From";
    $fb.ShowNewFolderButton = $false;
    if ($savedBase -and (Test-Path $savedBase)) { $fb.SelectedPath = $savedBase };
    if ($fb.ShowDialog() -ne "OK") {
        Write-Host "[ABORT] No folder selected. Exiting." -ForegroundColor Red;
        Stop-Transcript | Out-Null;
        exit;
    }
    $restoreRoot = $fb.SelectedPath;

    # If user browsed, try to detect if they picked a base or a specific backup
    # Save the parent as the base location for next time
    $newBase = Split-Path $restoreRoot -Parent;
    $Settings.LastBackupLocation = $newBase;
    $Settings | ConvertTo-Json | Set-Content -Path $SettingsFile -Encoding UTF8;
    Write-Host "[CONFIG] Saved new base location: $newBase" -ForegroundColor DarkGray;
}

if (-not (Test-Path $restoreRoot)) {
    Write-Host "[ERROR] Backup folder not found!" -ForegroundColor Red;
    Stop-Transcript | Out-Null;
    Read-Host "Press Enter to exit...";
    exit;
}
Write-Host "[SYSTEM] Backup Source: $restoreRoot`n" -ForegroundColor DarkGray;

# ----------------------------------------------------------------
#  3. PARSE IGNORE LIST (.ini)
# ----------------------------------------------------------------
$IgnorePatterns = @("^\./Android/data/", "^\./Android/obb/");
$iniPath = Join-Path $PSScriptRoot "directory-ignore-list.ini";

if (Test-Path $iniPath) {
    $lines = Get-Content $iniPath;
    foreach ($line in $lines) {
        $line = $line.Trim();
        if ($line -match "^#" -or $line -eq "") { continue };
        $clean   = $line -replace '^/?sdcard/', './';
        $clean   = $clean -replace '/$', '';
        $escaped = [Regex]::Escape($clean);
        $IgnorePatterns += "^$escaped/";
        $IgnorePatterns += "^$escaped$";
    }
    Write-Host "[SYSTEM] Loaded $(($IgnorePatterns.Count)-2) custom ignore rules from INI file." -ForegroundColor DarkCyan;
}

# ----------------------------------------------------------------
#  4. QUANTUM INDEXING (FAST SCAN)
# ----------------------------------------------------------------
Write-Host "`n[SCAN] Mapping Backup Files on PC... (Please Wait)" -ForegroundColor Yellow;
$BackupFiles = @{};

Get-ChildItem -Path $restoreRoot -File -Recurse -Force | ForEach-Object {
    $relPath = $_.FullName.Substring($restoreRoot.Length + 1) -replace '\\', '/';
    $relPath  = "./" + $relPath;
    $BackupFiles[$relPath] = $_.Length;
}
Write-Host "[SCAN] Found $($BackupFiles.Count) total files in backup." -ForegroundColor Green;

Write-Host "[SCAN] Mapping Android Device Storage... (Please Wait)" -ForegroundColor Yellow;
$AndroidFiles = @{};

$scanTarget = "/sdcard"
if ($isAdbRoot -or $isSuRoot) {
    $scanTarget = "/data/media/0"
}

# Build scan commands using absolute paths (avoids cd+namespace path issues on Android FUSE mounts)
$scanCmd = "";
if ($isAdbRoot) {
    $scanCmd = "find $scanTarget -type f -exec stat -c '%s|%n' {} + 2>/dev/null";
} elseif ($isSuRoot) {
    $scanCmd = "su -c \`"find $scanTarget -type f -exec stat -c '%s|%n' {} + 2>/dev/null\`"";
} else {
    $scanCmd = "find $scanTarget -type f -exec stat -c '%s|%n' {} + 2>/dev/null";
}

# Fallback: xargs variant if exec+ batching fails
$scanFallbackCmd = "";
if ($isAdbRoot) {
    $scanFallbackCmd = "find $scanTarget -type f -print0 2>/dev/null | xargs -0 stat -c '%s|%n' 2>/dev/null";
} elseif ($isSuRoot) {
    $scanFallbackCmd = "su -c \`"find $scanTarget -type f -print0 2>/dev/null | xargs -0 stat -c '%s|%n' 2>/dev/null\`"";
} else {
    $scanFallbackCmd = "find $scanTarget -type f -print0 2>/dev/null | xargs -0 stat -c '%s|%n' 2>/dev/null";
}

$procInfo = New-Object System.Diagnostics.ProcessStartInfo;
$procInfo.FileName  = $adbExe;
$procInfo.Arguments = "-s $serial shell `"$scanCmd`"";
$procInfo.RedirectStandardOutput = $true;
$procInfo.UseShellExecute = $false;
$procInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8;
$procInfo.CreateNoWindow = $true;

$proc   = [System.Diagnostics.Process]::Start($procInfo);
$output = $proc.StandardOutput.ReadToEnd() -split "`n";
$proc.WaitForExit();

# Fallback: if output is empty, try the traditional -exec stat method
if (($scanFallbackCmd) -and (-not $output -or $output.Count -eq 0 -or ($output.Count -eq 1 -and $output[0].Trim() -eq ""))) {
    $procInfo.Arguments = "-s $serial shell `"$scanFallbackCmd`"";
    $proc   = [System.Diagnostics.Process]::Start($procInfo);
    $output = $proc.StandardOutput.ReadToEnd() -split "`n";
    $proc.WaitForExit();
}

foreach ($line in $output) {
    $line = $line.Trim();
    $idx  = $line.IndexOf('|');
    if ($idx -gt 0) {
        $sz  = 0;
        if (-not [long]::TryParse($line.Substring(0, $idx), [ref]$sz)) { continue };
        $raw = $line.Substring($idx + 1);
        # Normalize: strip absolute scanTarget prefix → ./relative
        if ($raw.StartsWith($scanTarget + "/")) {
            $raw = "./" + $raw.Substring($scanTarget.Length + 1);
        } elseif ($raw.StartsWith($scanTarget)) {
            $raw = "./" + $raw.Substring($scanTarget.Length);
        }
        # Strip spurious storage/emulated/0 nesting (FUSE namespace artifact)
        if ($raw.StartsWith("./storage/emulated/0/")) {
            $raw = "./" + $raw.Substring("./storage/emulated/0/".Length);
        }
        if ($raw.StartsWith("./")) { $AndroidFiles[$raw] = $sz };
    }
}
Write-Host "[SCAN] Found $($AndroidFiles.Count) files currently on Android.`n" -ForegroundColor Green;

# ----------------------------------------------------------------
#  4.5  INTERACTIVE INCLUDE SUB-MENU
# ----------------------------------------------------------------
Write-Host "[FILTER] Restore only specific folders/files from this backup?" -ForegroundColor Yellow;
Write-Host "         (Opens a selection picker - press N to restore everything)" -ForegroundColor DarkGray;
$filterChoice = "N"; # Test Override
$IncludeNodeStates = $null;
$IncludeActive     = $false;
if ($filterChoice.Trim().ToUpper() -eq 'Y') {
    Write-Host "[FILTER] Building backup file tree for selection..." -ForegroundColor DarkCyan;
    $IncludeNodeStates = Show-JigarIncludeMenu `
        -FormTitle 'JigarSmartRestore  -  Select Items to INCLUDE in Restore' `
        -FilePaths ($BackupFiles.Keys | Sort-Object);
    if ($null -eq $IncludeNodeStates) {
        Write-Host "[FILTER] Skipped - restoring everything." -ForegroundColor DarkGray;
    } else {
        $incCount = ($IncludeNodeStates.Values | Where-Object { $_ -eq $true }).Count;
        if ($incCount -eq 0) {
            Write-Host "[WARNING] No items selected - restoring everything instead." -ForegroundColor DarkYellow;
        } else {
            $IncludeActive = $true;
            Write-Host "[FILTER] $incCount item(s) selected for restore." -ForegroundColor Green;
        }
    }
}

# ----------------------------------------------------------------
#  5. CALCULATE DELTA (RESPECTING IGNORE LIST + INTERACTIVE FILTER)
# ----------------------------------------------------------------
$ToPush = [System.Collections.Generic.List[string]]::new();
foreach ($key in $BackupFiles.Keys) {
    $backupSize = $BackupFiles[$key];

    # Static ignore patterns (.ini rules)
    $skip = $false;
    foreach ($pattern in $IgnorePatterns) {
        if ($key -match $pattern) { $skip = $true; break };
    }
    if ($skip) { continue };

    # Interactive inclusion filter (most-specific-ancestor rule)
    if ($IncludeActive) {
        if (-not (Test-JgrIncluded -RelPath $key -NodeStates $IncludeNodeStates)) { continue };
    }

    if (-not $AndroidFiles.ContainsKey($key) -or $AndroidFiles[$key] -ne $backupSize) {
        $ToPush.Add($key);
    }
}

$totalFiles = $ToPush.Count;
if ($totalFiles -eq 0) {
    Write-Host "==============================================================" -ForegroundColor Green;
    Write-Host " YOUR PHONE IS 100% IN SYNC. NO NEW FILES TO RESTORE."          -ForegroundColor Green;
    Write-Host "==============================================================`n" -ForegroundColor Green;
    Stop-Transcript | Out-Null;
    Read-Host "Press Enter to exit...";
    exit;
}
Write-Host "[RESTORE] Queued $totalFiles missing or modified files for push." -ForegroundColor Magenta;

# ----------------------------------------------------------------
#  6. THE 12x TITAN PUSH ENGINE (SMART PATHING + 3-STAGE FALLBACK)
# ----------------------------------------------------------------
Write-Host "[RESTORE] Pre-allocating directory trees on device..." -ForegroundColor DarkGray;
$uniqueDirs = @{}
foreach ($file in $ToPush) {
    $cleanPath  = $file.Substring(2);
    $remotePath = "/sdcard/$cleanPath";
    $remoteDir  = $remotePath.Substring(0, $remotePath.LastIndexOf('/'));
    $uniqueDirs[$remoteDir] = $true;
}
foreach ($dir in $uniqueDirs.Keys) {
    $escapedDir = $dir -replace "'", "'\''"
    & $adbExe -s $serial shell "mkdir -p '$escapedDir'" | Out-Null;
}

Write-Host "[RESTORE] Engaging 4x Parallel Titan Streams...`n" -ForegroundColor Yellow;

$MaxThreads   = 4;
$RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads);
$RunspacePool.Open();

$ScriptBlock = {
    param($adbExe, $serial, $src, $dest, $isAdbRoot, $isSuRoot, $busyboxPath)

    # ---------------------------------------------------
    # ATTEMPT 1: Standard Push (Bypass virtual drive bugs for ADB root)
    # ---------------------------------------------------
    $pushDest = $dest
    if ($isAdbRoot) {
        $pushDest = $dest -replace "^/sdcard", "/data/media/0"
    }

    $pInfo = New-Object System.Diagnostics.ProcessStartInfo;
    $pInfo.FileName = $adbExe;
    $pInfo.Arguments = "-s `"$serial`" push `"$src`" `"$pushDest`"";
    $pInfo.UseShellExecute = $false;
    $pInfo.CreateNoWindow = $true;
    $p = [System.Diagnostics.Process]::Start($pInfo);
    $p.WaitForExit();
    
    if ($p.ExitCode -eq 0) { return 0; }

    # ---------------------------------------------------
    # ATTEMPT 2: Temp Push Via /data/local/tmp
    # ---------------------------------------------------
    $uuid = [guid]::NewGuid().ToString().Substring(0, 8);
    $androidTmp = "/data/local/tmp/jgr_$uuid";

    $pInfo2 = New-Object System.Diagnostics.ProcessStartInfo;
    $pInfo2.FileName = $adbExe;
    $pInfo2.Arguments = "-s `"$serial`" push `"$src`" `"$androidTmp`";";
    $pInfo2.UseShellExecute = $false;
    $pInfo2.CreateNoWindow = $true;
    $p2 = [System.Diagnostics.Process]::Start($pInfo2);
    $p2.WaitForExit();

    if ($p2.ExitCode -eq 0) {
        $mvDest = $dest
        if ($isAdbRoot) {
            $mvDest = $dest -replace "^/sdcard", "/data/media/0"
        }
        
        $pMvInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $pMvInfo.FileName = $adbExe;
        $pMvInfo.Arguments = "-s `"$serial`" shell `"mv \`"$androidTmp\`" \`"$mvDest\`"`"";
        $pMvInfo.UseShellExecute = $false;
        $pMvInfo.CreateNoWindow = $true;
        $pMv = [System.Diagnostics.Process]::Start($pMvInfo);
        $pMv.WaitForExit();

        if ($pMv.ExitCode -eq 0) {
            return 0;
        }

        # ---------------------------------------------------
        # ATTEMPT 3: Root Global Mount Fallback (APatch/Magisk)
        # ---------------------------------------------------
        if (-not $isAdbRoot -and -not $isSuRoot) {
            $pRmInfo = New-Object System.Diagnostics.ProcessStartInfo;
            $pRmInfo.FileName = $adbExe;
            $pRmInfo.Arguments = "-s `"$serial`" shell `"rm \`"$androidTmp\`" 2>/dev/null`"";
            $pRmInfo.UseShellExecute = $false;
            $pRmInfo.CreateNoWindow = $true;
            $pRm = [System.Diagnostics.Process]::Start($pRmInfo);
            $pRm.WaitForExit();
            return 1;
        }

        $rootDest = $dest -replace "^/sdcard", "/data/media/0";

        # Try writing to /sdcard first via su -c (auto-handles ownership/permissions if successful)
        $suCmd = "su -c 'cat \`"$androidTmp\`" > \`"$dest\`"'";
        $pSuInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $pSuInfo.FileName = $adbExe;
        $pSuInfo.Arguments = "-s `"$serial`" shell `"$suCmd`"";
        $pSuInfo.UseShellExecute = $false;
        $pSuInfo.CreateNoWindow = $true;
        $pSu = [System.Diagnostics.Process]::Start($pSuInfo);
        $pSu.WaitForExit();

        if ($pSu.ExitCode -eq 0) {
            $pRmInfo = New-Object System.Diagnostics.ProcessStartInfo;
            $pRmInfo.FileName = $adbExe;
            $pRmInfo.Arguments = "-s `"$serial`" shell `"rm \`"$androidTmp\`" 2>/dev/null`"";
            $pRmInfo.UseShellExecute = $false;
            $pRmInfo.CreateNoWindow = $true;
            $pRm = [System.Diagnostics.Process]::Start($pRmInfo);
            $pRm.WaitForExit();
            return 0;
        }

        # Fallback to direct raw copy to /data/media/0 + chown/chmod
        $suCmdRaw = "su -c 'cat \`"$androidTmp\`" > \`"$rootDest\`" && chown 1023:1023 \`"$rootDest\`" && chmod 664 \`"$rootDest\`"'";
        $pSuInfo.Arguments = "-s `"$serial`" shell `"$suCmdRaw`"";
        $pSuRaw = [System.Diagnostics.Process]::Start($pSuInfo);
        $pSuRaw.WaitForExit();

        $exitCode = $pSuRaw.ExitCode;

        $pRmInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $pRmInfo.FileName = $adbExe;
        $pRmInfo.Arguments = "-s `"$serial`" shell `"rm \`"$androidTmp\`" 2>/dev/null`"";
        $pRmInfo.UseShellExecute = $false;
        $pRmInfo.CreateNoWindow = $true;
        $pRm = [System.Diagnostics.Process]::Start($pRmInfo);
        $pRm.WaitForExit();

        if ($exitCode -eq 0) {
            return 0;
        }
    }

    return 1; # Absolute Failure
}

$ActiveJobs     = [System.Collections.Generic.List[psobject]]::new();
$failedFiles    = [System.Collections.Generic.List[string]]::new();
$completedCount  = 0;

foreach ($file in $ToPush) {
    # --- Check Abort Flag ---
    if ($global:JigarAbort) { break };

    $cleanPath = $file.Substring(2);
    $src  = Join-Path $restoreRoot $cleanPath;
    $dest = "/sdcard/$cleanPath";

    $PSInstance = [powershell]::Create().AddScript($ScriptBlock).AddArgument($adbExe).AddArgument($serial).AddArgument($src).AddArgument($dest).AddArgument($isAdbRoot).AddArgument($isSuRoot).AddArgument($busyboxPath);
    $PSInstance.RunspacePool = $RunspacePool;

    $ActiveJobs.Add([PSCustomObject]@{
        PS    = $PSInstance
        Async = $PSInstance.BeginInvoke()
        File  = $cleanPath
    });

    while ($ActiveJobs.Count -ge ($MaxThreads * 2)) {
        $done = $ActiveJobs | Where-Object { $_.Async.IsCompleted };
        foreach ($d in $done) {
            $rawResult = $d.PS.EndInvoke($d.Async);
            $exitCode = if ($rawResult -is [array] -or $rawResult -is [System.Collections.ICollection]) { $rawResult[-1] } else { $rawResult }
            if ([int]$exitCode -ne 0) { $failedFiles.Add($d.File) };
            $d.PS.Dispose();
            $completedCount++;
        }
        $ActiveJobs = [System.Collections.Generic.List[psobject]]::new([psobject[]]@($ActiveJobs | Where-Object { -not $_.Async.IsCompleted }));

        if ($done.Count -eq 0) { Start-Sleep -Milliseconds 50 };
        if ($completedCount % 5 -eq 0) {
            Write-Progress -Activity "12x Multi-Threaded Titan Push" -Status "[$completedCount / $totalFiles] Restored" -PercentComplete (($completedCount / $totalFiles) * 100);
        }

        if ($global:JigarAbort) { break };
    }
}

# Drain remaining jobs
while ($ActiveJobs.Count -gt 0) {
    $done = $ActiveJobs | Where-Object { $_.Async.IsCompleted };
    foreach ($d in $done) {
        $rawResult = $d.PS.EndInvoke($d.Async);
        $exitCode = if ($rawResult -is [array] -or $rawResult -is [System.Collections.ICollection]) { $rawResult[-1] } else { $rawResult }
        if ([int]$exitCode -ne 0) { $failedFiles.Add($d.File) };
        $d.PS.Dispose();
        $completedCount++;
    }
    $ActiveJobs = [System.Collections.Generic.List[psobject]]::new([psobject[]]@($ActiveJobs | Where-Object { -not $_.Async.IsCompleted }));
    if ($done.Count -eq 0) { Start-Sleep -Milliseconds 100 };
    Write-Progress -Activity "12x Multi-Threaded Titan Push" -Status "[$completedCount / $totalFiles] Restored" -PercentComplete (($completedCount / $totalFiles) * 100);
    if ($global:JigarAbort -and $ActiveJobs.Count -eq 0) { break };
}
Write-Progress -Activity "12x Multi-Threaded Titan Push" -Completed;

# ----------------------------------------------------------------
#  GRACEFUL ABORT CLEANUP (Feature 5)
# ----------------------------------------------------------------
if ($global:JigarAbort) {
    Write-Host "`n[ABORT] Closing runspace pool..." -ForegroundColor Red;
    $RunspacePool.Close();
    $RunspacePool.Dispose();

    Write-Host "[ABORT] Cleaning up abandoned ADB temp files (jgr_*)..." -ForegroundColor Yellow;
    & $adbExe -s $serial shell "rm /data/local/tmp/jgr_* 2>/dev/null" | Out-Null;

    Write-Host "`n[DONE] Process aborted safely. Temp files cleaned up." -ForegroundColor Green;
    Stop-Transcript | Out-Null;
    Read-Host "`nPress Enter to exit...";
    exit;
}

$RunspacePool.Close();
$RunspacePool.Dispose();

# ----------------------------------------------------------------
#  7. SUMMARY
# ----------------------------------------------------------------
Write-Host "`n ==============================================================" -ForegroundColor Green;
Write-Host "   RESTORE COMPLETED" -ForegroundColor Green;
Write-Host " ==============================================================" -ForegroundColor Green;

if ($failedFiles.Count -gt 0) {
    Write-Host "`n[REPORT] Skipped $($failedFiles.Count) read-only or locked system files:" -ForegroundColor Yellow;
    for ($i = 0; $i -lt [Math]::Min($failedFiles.Count, 15); $i++) {
        Write-Host "   > $($failedFiles[$i])" -ForegroundColor DarkRed;
    }
    if ($failedFiles.Count -gt 15) { Write-Host "   > ... and $(($failedFiles.Count) - 15) more." -ForegroundColor DarkRed };
} else {
    Write-Host "`n[SUCCESS] 100% of files restored flawlessly!" -ForegroundColor Green;
}

Write-Host "`n[LOG] Transcript saved to: $LogFile" -ForegroundColor DarkGray;
Stop-Transcript | Out-Null;
Read-Host "`nPress Enter to exit...";

