#Requires -Version 5.1
# ================================================================
#  JIGAR TOOLS v39.1 - ABSOLUTE VELOCITY (THE TITAN ENGINE)
#  NEW in v39.1:
#  - Interactive EXCLUDE Sub-Menu (TreeView GUI with lazy loading)
#  - Granular folder/subfolder/file exclusion at runtime
#  - Most-specific-ancestor filter logic for partial selections
#  ------------------------------------------------------------
#  From v39.0:
#  - Dynamic Folder Naming (DeviceName_Date_Time)
#  - Location Memory (settings.json)
#  - Persistent Logging (Logs\ folder)
#  - Graceful Ctrl+C Cancellation with ADB Temp Cleanup
#  - 3-Stage Fallback: Unconditionally defeats all ADB path bugs
#  - Smart Routing: Bypasses Virtual Drive for Root files
#  - APatch Global Mount: Resolves /sdcard in root namespace
# ================================================================

# ================================================================
#  INTERACTIVE SELECTION ENGINE  (shared helper functions)
#  - Build-JgrPathIndex  : flat path list  â†’ nested hashtable
#  - Add-JgrTreeChildren : lazy-populate a TreeView node
#  - Set-JgrCheckedDeep  : propagate checked state to children
#  - Get-JgrNodeStates   : harvest pathâ†’bool map from live tree
#  - Show-JigarExcludeMenu : full WinForms GUI (EXCLUDE mode)
#  - Test-JgrExcluded    : most-specific-ancestor lookup
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
            $tn.ForeColor = [System.Drawing.Color]::FromArgb(160, 200, 255);
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

function Test-JgrExcluded {
    # Returns $true if the file should be EXCLUDED (most-specific ancestor wins)
    param([string] $RelPath, [hashtable] $NodeStates)
    $path  = $RelPath -replace '^\./', '';
    $parts = $path.Split('/');
    $best  = $false;   # default: NOT excluded
    for ($d = 1; $d -le $parts.Count; $d++) {
        $ancestor = ($parts[0..($d-1)]) -join '/';
        if ($NodeStates.ContainsKey($ancestor)) { $best = $NodeStates[$ancestor] };
    }
    return $best;
}

function Show-JigarExcludeMenu {
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
    $form.BackColor     = [System.Drawing.Color]::FromArgb(18, 18, 28);
    $form.ForeColor     = [System.Drawing.Color]::FromArgb(220, 220, 240);

    # -- Top instruction banner -------------------------------------
    $pnlTop = [System.Windows.Forms.Panel]::new();
    $pnlTop.Dock      = 'Top';
    $pnlTop.Height    = 62;
    $pnlTop.BackColor = [System.Drawing.Color]::FromArgb(28, 14, 14);
    $pnlTop.Padding   = [System.Windows.Forms.Padding]::new(12, 8, 12, 4);

    $lblTitle = [System.Windows.Forms.Label]::new();
    $lblTitle.Text      = '[EXCLUDE] SELECT FOLDERS / FILES TO EXCLUDE FROM BACKUP';
    $lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(255, 90, 90);
    $lblTitle.Font      = [System.Drawing.Font]::new('Segoe UI', 10,
        [System.Drawing.FontStyle]::Bold);
    $lblTitle.Dock      = 'Top';
    $lblTitle.Height    = 26;

    $lblSub = [System.Windows.Forms.Label]::new();
    $lblSub.Text = '  Checked items will be SKIPPED. Press ENTER to Confirm.';
    $lblSub.ForeColor = [System.Drawing.Color]::FromArgb(180, 120, 120);
    $lblSub.Font      = [System.Drawing.Font]::new('Segoe UI', 8);
    $lblSub.Dock      = 'Top';
    $lblSub.Height    = 20;

    $pnlTop.Controls.Add($lblSub);
    $pnlTop.Controls.Add($lblTitle);

    # -- Status strip ---------------------------------------------
    $status = [System.Windows.Forms.ToolStripStatusLabel]::new();
    $status.Text      = '0 item(s) marked for exclusion';
    $status.ForeColor = [System.Drawing.Color]::FromArgb(200, 160, 100);
    $statusBar = [System.Windows.Forms.StatusStrip]::new();
    $statusBar.BackColor = [System.Drawing.Color]::FromArgb(12, 12, 20);
    [void]$statusBar.Items.Add($status);

    # -- TreeView -------------------------------------------------
    $tv = [System.Windows.Forms.TreeView]::new();
    $tv.CheckBoxes  = $true;
    $tv.Dock        = 'Fill';
    $tv.Font        = [System.Drawing.Font]::new('Segoe UI', 9);
    $tv.BackColor   = [System.Drawing.Color]::FromArgb(22, 22, 34);
    $tv.ForeColor   = [System.Drawing.Color]::FromArgb(210, 210, 235);
    $tv.BorderStyle = 'None';
    $tv.Scrollable  = $true;

    # -- Bottom panel ---------------------------------------------
    $pnlBot = [System.Windows.Forms.Panel]::new();
    $pnlBot.Dock      = 'Bottom';
    $pnlBot.Height    = 54;
    $pnlBot.BackColor = [System.Drawing.Color]::FromArgb(14, 14, 22);
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
    $btnNone     = & $mkBtn 'Clear All'   115 '#5c1a1a';
    $btnExpand   = & $mkBtn 'Expand All'  220 '#1a2d5c';
    $btnCollapse = & $mkBtn 'Collapse'    325 '#2e2e40';

    $btnProceed = [System.Windows.Forms.Button]::new();
    $btnProceed.Text = 'Confirm [ENTER]';
    $btnProceed.Size      = [System.Drawing.Size]::new(130, 34);
    $btnProceed.FlatStyle = 'Flat';
    $btnProceed.BackColor = [System.Drawing.Color]::FromArgb(0, 100, 200);
    $btnProceed.ForeColor = [System.Drawing.Color]::White;
    $btnProceed.Font      = [System.Drawing.Font]::new('Segoe UI', 9,
        [System.Drawing.FontStyle]::Bold);
    $btnProceed.FlatAppearance.BorderSize = 0;
    $btnProceed.Anchor      = 'Bottom, Right';
    $btnProceed.DialogResult = 'OK';

    $btnSkip = [System.Windows.Forms.Button]::new();
    $btnSkip.Text      = 'Skip (Backup All)';
    $btnSkip.Size      = [System.Drawing.Size]::new(130, 34);
    $btnSkip.FlatStyle = 'Flat';
    $btnSkip.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 65);
    $btnSkip.ForeColor = [System.Drawing.Color]::White;
    $btnSkip.Font      = [System.Drawing.Font]::new('Segoe UI', 9);
    $btnSkip.FlatAppearance.BorderSize = 0;
    $btnSkip.Anchor       = 'Bottom, Right';
    $btnSkip.DialogResult = 'Cancel';

    # Anchor right-side buttons manually
    $form.add_Resize({
        $btnProceed.Location = [System.Drawing.Point]::new($pnlBot.Width - 145, 10);
        $btnSkip.Location    = [System.Drawing.Point]::new($pnlBot.Width - 280, 10);
    })
    $btnProceed.Location = [System.Drawing.Point]::new(640, 10);
    $btnSkip.Location    = [System.Drawing.Point]::new(505, 10);

    $pnlBot.Controls.AddRange(@($btnAll, $btnNone, $btnExpand, $btnCollapse,
                                 $btnProceed, $btnSkip));
    $form.AcceptButton = $btnProceed;
    $form.CancelButton = $btnSkip;

    # -- Populate root nodes ---------------------------------------
    $tv.BeginUpdate();
    if ($pathIndex.ContainsKey('')) {
        foreach ($child in $pathIndex['']) {
            $tn      = [System.Windows.Forms.TreeNode]::new($child);
            $tn.Tag  = $child;
            $tn.Checked = $false;
            $isFolder   = $pathIndex.ContainsKey($child);
            if ($isFolder) {
                $tn.NodeFont = [System.Drawing.Font]::new('Segoe UI', 9,
                    [System.Drawing.FontStyle]::Bold);
                [void]$tn.Nodes.Add(
                    [System.Windows.Forms.TreeNode]::new($script:JgrPlaceholder));
            } else {
                $tn.ForeColor = [System.Drawing.Color]::FromArgb(160, 200, 255);
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
        $status.Text = "$c item(s) marked for exclusion";
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

    $dlgResult = $form.ShowDialog();
    $nodeStates = @{};
    if ($dlgResult -eq 'OK') {
        Get-JgrNodeStates -Nodes $tv.Nodes -States $nodeStates;
    }
    $form.Dispose();
    if ($dlgResult -ne 'OK') { return $null };  # null = skip filter
    return $nodeStates;
}

& chcp 65001 | Out-Null;
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8;
$ProgressPreference = 'Continue';
$Host.UI.RawUI.WindowTitle = 'Jigar Tools v39.0 - Titan Engine';
$ErrorActionPreference = 'SilentlyContinue';
[System.Environment]::SetEnvironmentVariable("LC_ALL", "C.UTF-8");

# ----------------------------------------------------------------
#  LOGGING INIT  (must be near top so all output is captured)
# ----------------------------------------------------------------
$LogsDir = Join-Path $PSScriptRoot "Logs";
if (-not (Test-Path $LogsDir)) { New-Item -ItemType Directory -Force -Path $LogsDir | Out-Null };
$LogTimestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss";
$LogFile = Join-Path $LogsDir "SyncLog_$LogTimestamp.txt";
Start-Transcript -Path $LogFile -Append | Out-Null;

Write-Host "`n ==============================================================" -ForegroundColor Cyan;
Write-Host "   JIGAR SMART SYNC v39.0  (12x THREADS + 3-STAGE TITAN FALLBACK)" -ForegroundColor Cyan;
Write-Host " ==============================================================" -ForegroundColor Cyan;
Write-Host "   Log: $LogFile" -ForegroundColor DarkGray;

# ----------------------------------------------------------------
#  0. AUTO-CLEANUP ORPHANED VIRTUAL DRIVES
# ----------------------------------------------------------------
$substOut = & subst;
if ($substOut) {
    foreach ($line in $substOut) {
        if ($line -match "^([A-Z]:\\): => (.*(Smart_Backup|_\d{4}-\d\d-\d\d_).*)$") {
            $drv = $Matches[1].TrimEnd('\');
            & subst $drv /D | Out-Null;
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
#  FEATURE 1+2: DEVICE NAME + DYNAMIC FOLDER + LOCATION MEMORY
# ----------------------------------------------------------------
$SettingsFile = Join-Path $PSScriptRoot "settings.json";
$Settings = @{ LastBackupLocation = "" };
if (Test-Path $SettingsFile) {
    try { $parsed = Get-Content $SettingsFile -Raw | ConvertFrom-Json; if ($parsed.LastBackupLocation) { $Settings.LastBackupLocation = $parsed.LastBackupLocation } } catch {};
}

# --- Fetch Device Name via ADB ---
$rawModel = (& $adbExe -s $serial shell getprop ro.product.model 2>$null);
$rawModel = $rawModel.Trim();
# Sanitize: remove chars invalid in Windows folder names
$DeviceName = $rawModel -replace '[<>:"/\\|?*\x00-\x1F]', '_';
$DeviceName = $DeviceName -replace '\s+', '_';
$DeviceName = $DeviceName.Trim('_');
if ($DeviceName -eq "") { $DeviceName = "Android_Device" };

Write-Host "[SYSTEM] Device Model : $rawModel" -ForegroundColor DarkCyan;
Write-Host "[SYSTEM] Folder Name  : $DeviceName" -ForegroundColor DarkCyan;

# --- Location Memory (Feature 2) ---
Add-Type -AssemblyName System.Windows.Forms;
$baseBackupPath = $null;
$savedPath = $Settings.LastBackupLocation;

if ($savedPath -and (Test-Path $savedPath)) {
    Write-Host "`n[CONFIG] Previous backup location found:" -ForegroundColor Yellow;
    Write-Host "         $savedPath" -ForegroundColor White;
    $useOld = Read-Host "         Use this location? [Y/N]";
    if ($useOld.Trim().ToUpper() -eq "Y") {
        $baseBackupPath = $savedPath;
    }
}

if (-not $baseBackupPath) {
    Write-Host "`n[CONFIG] Select base backup location..." -ForegroundColor Yellow;
    $fb = New-Object System.Windows.Forms.FolderBrowserDialog;
    $fb.Description = "Select Base Backup Folder (e.g. D:\Backups)";
    $fb.ShowNewFolderButton = $true;
    if ($savedPath -and (Test-Path $savedPath)) { $fb.SelectedPath = $savedPath };
    if ($fb.ShowDialog() -ne "OK") {
        Write-Host "[ABORT] No folder selected. Exiting." -ForegroundColor Red;
        Stop-Transcript | Out-Null;
        exit;
    }
    $baseBackupPath = $fb.SelectedPath;
    # Save to settings.json
    $Settings.LastBackupLocation = $baseBackupPath;
    $Settings | ConvertTo-Json | Set-Content -Path $SettingsFile -Encoding UTF8;
    Write-Host "[CONFIG] Saved new location to settings.json" -ForegroundColor DarkGray;
}

# --- Build Dynamic Destination Folder ---
$DateStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss";
$destFolderName = "${DeviceName}_${DateStamp}";
$destPath = Join-Path $baseBackupPath $destFolderName;
if (-not (Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath -Force | Out-Null };

Write-Host "[SYSTEM] Backup Destination:" -ForegroundColor Green;
Write-Host "         $destPath`n" -ForegroundColor White;

# ----------------------------------------------------------------
#  VIRTUAL DRIVE SETUP (DEFEATS MAX_PATH)
# ----------------------------------------------------------------
$virtDrive = $null;
foreach ($letter in "ZYXWVUTSRQPONMLKJIHGFE".ToCharArray()) {
    if (-not (Test-Path "$($letter):")) {
        $virtDrive = "$($letter):";
        break;
    }
}

if ($virtDrive) {
    & subst $virtDrive "`"$destPath`"" | Out-Null;
    $syncTarget = "$virtDrive\";
} else {
    $syncTarget = "$destPath\";
}
Write-Host "[SYSTEM] Sync Target  : $destPath`n" -ForegroundColor DarkGray;

# ----------------------------------------------------------------
#  FEATURE 5: GRACEFUL CTRL+C CANCELLATION HANDLER
# ----------------------------------------------------------------
$global:JigarAbort = $false;

$cancelHandler = [System.ConsoleCancelEventHandler]{
    param($sender, $e)
    $e.Cancel = $true;   # Prevent immediate kill - we handle it ourselves
    $global:JigarAbort = $true;
    Write-Host "`n`n[ABORT] Ctrl+C detected. Finishing current batch safely..." -ForegroundColor Red;
};
[System.Console]::add_CancelKeyPress($cancelHandler);

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
Write-Host "[SCAN] Mapping Android Storage... (Please Wait)" -ForegroundColor Yellow;
$AndroidFiles = @{};

$cmd      = "cd /sdcard && find . -type f -exec stat -c '%s|%n' {} + 2>/dev/null";
$procInfo = New-Object System.Diagnostics.ProcessStartInfo;
$procInfo.FileName  = $adbExe;
$procInfo.Arguments = "-s $serial shell `"$cmd`"";
$procInfo.RedirectStandardOutput = $true;
$procInfo.UseShellExecute = $false;
$procInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8;
$procInfo.CreateNoWindow = $true;

$proc   = [System.Diagnostics.Process]::Start($procInfo);
$output = $proc.StandardOutput.ReadToEnd() -split "`n";
$proc.WaitForExit();

foreach ($line in $output) {
    $line = $line.Trim();
    $idx  = $line.IndexOf('|');
    if ($idx -gt 0) {
        $sz   = [long]$line.Substring(0, $idx);
        $file = $line.Substring($idx + 1);
        if ($file.StartsWith("./")) { $AndroidFiles[$file] = $sz };
    }
}
Write-Host "[SCAN] Found $($AndroidFiles.Count) total files on Android." -ForegroundColor Green;

Write-Host "[SCAN] Mapping Local PC Backup..." -ForegroundColor Yellow;
$LocalFiles = @{};
Get-ChildItem -Path $destPath -File -Recurse -Force | ForEach-Object {
    $relPath = $_.FullName.Substring($destPath.Length + 1) -replace '\\', '/';
    $relPath  = "./" + $relPath;
    $LocalFiles[$relPath] = $_.Length;
}
Write-Host "[SCAN] Found $($LocalFiles.Count) files currently on PC.`n" -ForegroundColor Green;

# ----------------------------------------------------------------
#  4.5  INTERACTIVE EXCLUDE SUB-MENU
# ----------------------------------------------------------------
Write-Host "[FILTER] Customize which folders/files to EXCLUDE from this backup?" -ForegroundColor Yellow;
Write-Host "         (Opens a folder/file picker - press N to back up everything)" -ForegroundColor DarkGray;
$filterChoice = Read-Host "         Launch exclude menu? [Y/N]";
$ExcludeNodeStates = $null;
if ($filterChoice.Trim().ToUpper() -eq 'Y') {
    Write-Host "[FILTER] Building Android file tree for selection..." -ForegroundColor DarkCyan;
    $ExcludeNodeStates = Show-JigarExcludeMenu `
        -FormTitle 'JigarSmartSync  -  Select Items to EXCLUDE from Backup' `
        -FilePaths ($AndroidFiles.Keys | Sort-Object);
    if ($null -eq $ExcludeNodeStates) {
        Write-Host "[FILTER] Skipped - backing up everything." -ForegroundColor DarkGray;
    } else {
        $excCount = ($ExcludeNodeStates.Values | Where-Object { $_ -eq $true }).Count;
        Write-Host "[FILTER] $excCount item(s) marked for exclusion." -ForegroundColor Yellow;
    }
}

# ----------------------------------------------------------------
#  5. CALCULATE DELTA (RESPECTING IGNORE LIST + INTERACTIVE FILTER)
# ----------------------------------------------------------------
$ToPull = [System.Collections.Generic.List[string]]::new();
foreach ($key in $AndroidFiles.Keys) {
    $androidSize = $AndroidFiles[$key];

    # Static ignore patterns (.ini rules)
    $skip = $false;
    foreach ($pattern in $IgnorePatterns) {
        if ($key -match $pattern) { $skip = $true; break };
    }
    if ($skip) { continue };

    # Interactive exclusion filter (most-specific-ancestor rule)
    if ($ExcludeNodeStates -and $ExcludeNodeStates.Count -gt 0) {
        if (Test-JgrExcluded -RelPath $key -NodeStates $ExcludeNodeStates) { continue };
    }

    $pcKey = $key -replace '[<>:"|?*]', '_';
    if (-not $LocalFiles.ContainsKey($pcKey) -or $LocalFiles[$pcKey] -ne $androidSize) {
        $ToPull.Add($key);
    }
}

$totalFiles = $ToPull.Count;
if ($totalFiles -eq 0) {
    Write-Host "==============================================================" -ForegroundColor Green;
    Write-Host " YOUR PC IS 100% IN SYNC. NO NEW FILES TO DOWNLOAD."           -ForegroundColor Green;
    Write-Host "==============================================================`n" -ForegroundColor Green;
    if ($virtDrive) { & subst $virtDrive /D | Out-Null };
    Stop-Transcript | Out-Null;
    Read-Host "Press Enter to exit...";
    exit;
}
Write-Host "[SYNC] Queued $totalFiles missing or modified files for download." -ForegroundColor Magenta;

# ----------------------------------------------------------------
#  6. THE 12x TITAN PULL ENGINE (SMART PATHING + 3-STAGE FALLBACK)
# ----------------------------------------------------------------
Write-Host "[SYNC] Pre-allocating directory trees natively..." -ForegroundColor DarkGray;
$uniqueDirs = @{}
foreach ($file in $ToPull) {
    $cleanPath  = $file.Substring(2);
    $safeWinPath = $cleanPath -replace '[<>:"|?*]', '_' -replace '/', '\';

    if ($virtDrive -and $safeWinPath -match '\\') {
        $dest = Join-Path $syncTarget $safeWinPath;
    } else {
        $dest = Join-Path $destPath $safeWinPath;
    }

    $destFolder = [System.IO.Path]::GetDirectoryName($dest);
    $uniqueDirs[$destFolder] = $true;
}
foreach ($folder in $uniqueDirs.Keys) {
    if (-not [System.IO.Directory]::Exists($folder)) {
        [System.IO.Directory]::CreateDirectory($folder) | Out-Null;
    }
}

Write-Host "[SYNC] Engaging 12x Parallel Titan Streams...`n" -ForegroundColor Yellow;

$MaxThreads   = 12;
$RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads);
$RunspacePool.Open();

$ScriptBlock = {
    param($adbExe, $serial, $src, $dest)

    function Invoke-ProcessSafe {
        param($pInfo)
        $pInfo.RedirectStandardOutput = $true;
        $pInfo.RedirectStandardError = $true;
        $p = [System.Diagnostics.Process]::Start($pInfo);
        $outTask = $p.StandardOutput.ReadToEndAsync();
        $errTask = $p.StandardError.ReadToEndAsync();
        [System.Threading.Tasks.Task]::WaitAll($outTask, $errTask);
        $p.WaitForExit();
        $exitCode = $p.ExitCode;
        $p.Dispose();
        return $exitCode;
    }

    # ---------------------------------------------------
    # ATTEMPT 1: Standard Pull
    # ---------------------------------------------------
    $pInfo = New-Object System.Diagnostics.ProcessStartInfo;
    $pInfo.FileName  = $adbExe;
    $pInfo.Arguments = "-s `"$serial`" pull `"$src`" `"$dest`"";
    $pInfo.UseShellExecute = $false;
    $pInfo.CreateNoWindow  = $true;
    $exitCode1 = Invoke-ProcessSafe $pInfo;

    if ($exitCode1 -eq 0) { return 0; }

    # ---------------------------------------------------
    # ATTEMPT 2: PC-Side Temp Pull (Bypasses ADB Drive Bugs)
    # ---------------------------------------------------
    $pcTemp  = Join-Path ([System.IO.Path]::GetTempPath()) "jgr_$([guid]::NewGuid().ToString()).tmp";
    $pInfo2  = New-Object System.Diagnostics.ProcessStartInfo;
    $pInfo2.FileName  = $adbExe;
    $pInfo2.Arguments = "-s `"$serial`" pull `"$src`" `"$pcTemp`"";
    $pInfo2.UseShellExecute = $false;
    $pInfo2.CreateNoWindow  = $true;
    $exitCode2 = Invoke-ProcessSafe $pInfo2;

    if ($exitCode2 -eq 0) {
        try {
            [System.IO.File]::Copy($pcTemp, $dest, $true); [System.IO.File]::Delete($pcTemp);
            return 0;
        } catch {}
    }
    if ([System.IO.File]::Exists($pcTemp)) { [System.IO.File]::Delete($pcTemp) };

    # ---------------------------------------------------
    # ATTEMPT 3: Root Global Mount Fallback (APatch/Magisk)
    # ---------------------------------------------------
    $uuid       = [guid]::NewGuid().ToString().Substring(0, 8);
    $androidTmp = "/data/local/tmp/jgr_$uuid";
    $rootSrc    = $src -replace "^/sdcard", "/data/media/0";

    try {
        $suArgs = "-s `"$serial`" shell `"su -c 'cp \`"$rootSrc\`" \`"$androidTmp\`" && chmod 777 \`"$androidTmp\`"'`"";
        $pSuInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $pSuInfo.FileName  = $adbExe;
        $pSuInfo.Arguments = $suArgs;
        $pSuInfo.UseShellExecute = $false;
        $pSuInfo.CreateNoWindow  = $true;
        $exitCodeSu = Invoke-ProcessSafe $pSuInfo;

        if ($exitCodeSu -eq 0) {
            $pPullInfo = New-Object System.Diagnostics.ProcessStartInfo;
            $pPullInfo.FileName  = $adbExe;
            $pPullInfo.Arguments = "-s `"$serial`" pull `"$androidTmp`" `"$dest`"";
            $pPullInfo.UseShellExecute = $false;
            $pPullInfo.CreateNoWindow  = $true;
            $exitCodePull = Invoke-ProcessSafe $pPullInfo;

            return $exitCodePull;
        }

        return 1; # Absolute Failure
    } finally {
        $pRmInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $pRmInfo.FileName  = $adbExe;
        $pRmInfo.Arguments = "-s `"$serial`" shell `"rm \`"$androidTmp\`" 2>/dev/null`"";
        $pRmInfo.UseShellExecute = $false;
        $pRmInfo.CreateNoWindow  = $true;
        Invoke-ProcessSafe $pRmInfo | Out-Null;
    }
}

$ActiveJobs    = [System.Collections.Generic.List[psobject]]::new();
$failedFiles   = [System.Collections.Generic.List[string]]::new();
$completedCount = 0;

foreach ($file in $ToPull) {
    # --- Check Abort Flag (Feature 5) ---
    if ($global:JigarAbort) { break };

    $cleanPath   = $file.Substring(2);
    $src         = "/sdcard/$cleanPath";
    $safeWinPath = $cleanPath -replace '[<>:"|?*]', '_' -replace '/', '\';

    if ($virtDrive -and $safeWinPath -match '\\') {
        $dest = Join-Path $syncTarget $safeWinPath;
    } else {
        $dest = Join-Path $destPath $safeWinPath;
    }

    $PSInstance = [powershell]::Create().AddScript($ScriptBlock).AddArgument($adbExe).AddArgument($serial).AddArgument($src).AddArgument($dest);
    $PSInstance.RunspacePool = $RunspacePool;

    $ActiveJobs.Add([PSCustomObject]@{
        PS    = $PSInstance
        Async = $PSInstance.BeginInvoke()
        File  = $cleanPath
    });

    while ($ActiveJobs.Count -ge ($MaxThreads * 2)) {
        $done = $ActiveJobs | Where-Object { $_.Async.IsCompleted };
        foreach ($d in $done) {
            $exitCode = $d.PS.EndInvoke($d.Async);
            if ($exitCode -ne 0) { $failedFiles.Add($d.File) };
            $d.PS.Dispose();
            $completedCount++;
        }
        $ActiveJobs = [System.Collections.Generic.List[psobject]]::new([psobject[]]@($ActiveJobs | Where-Object { -not $_.Async.IsCompleted }));

        if ($done.Count -eq 0) { Start-Sleep -Milliseconds 50 };
        if ($completedCount % 5 -eq 0) {
            Write-Progress -Activity "12x Multi-Threaded Titan Pull" -Status "[$completedCount / $totalFiles] Downloaded" -PercentComplete (($completedCount / $totalFiles) * 100);
        }

        if ($global:JigarAbort) { break };
    }
}

# Drain remaining jobs
while ($ActiveJobs.Count -gt 0) {
    $done = $ActiveJobs | Where-Object { $_.Async.IsCompleted };
    foreach ($d in $done) {
        $exitCode = $d.PS.EndInvoke($d.Async);
        if ($exitCode -ne 0) { $failedFiles.Add($d.File) };
        $d.PS.Dispose();
        $completedCount++;
    }
    $ActiveJobs = [System.Collections.Generic.List[psobject]]::new([psobject[]]@($ActiveJobs | Where-Object { -not $_.Async.IsCompleted }));
    if ($done.Count -eq 0) { Start-Sleep -Milliseconds 100 };
    Write-Progress -Activity "12x Multi-Threaded Titan Pull" -Status "[$completedCount / $totalFiles] Downloaded" -PercentComplete (($completedCount / $totalFiles) * 100);
    if ($global:JigarAbort -and $ActiveJobs.Count -eq 0) { break };
}
Write-Progress -Activity "12x Multi-Threaded Titan Pull" -Completed;

# ----------------------------------------------------------------
#  GRACEFUL ABORT CLEANUP (Feature 5)
# ----------------------------------------------------------------
if ($global:JigarAbort) {
    Write-Host "`n[ABORT] Closing runspace pool..." -ForegroundColor Red;
    $RunspacePool.Close();
    $RunspacePool.Dispose();
    if ($virtDrive) { & subst $virtDrive /D | Out-Null };

    Write-Host "[ABORT] Cleaning up abandoned ADB temp files (jgr_*)..." -ForegroundColor Yellow;
    & $adbExe -s $serial shell "rm /data/local/tmp/jgr_* 2>/dev/null" | Out-Null;

    Write-Host "`n[DONE] Process aborted safely. Temp files cleaned up." -ForegroundColor Green;
    Stop-Transcript | Out-Null;
    Read-Host "`nPress Enter to exit...";
    exit;
}

$RunspacePool.Close();
$RunspacePool.Dispose();
if ($virtDrive) { & subst $virtDrive /D | Out-Null };

# ----------------------------------------------------------------
#  7. SUMMARY
# ----------------------------------------------------------------
Write-Host "`n ==============================================================" -ForegroundColor Green;
Write-Host "   SYNC COMPLETED" -ForegroundColor Green;
Write-Host " ==============================================================" -ForegroundColor Green;
Write-Host "   Saved to: $destPath" -ForegroundColor DarkGray;

if ($failedFiles.Count -gt 0) {
    Write-Host "`n[REPORT] Skipped $($failedFiles.Count) heavily locked system files:" -ForegroundColor Yellow;
    for ($i = 0; $i -lt [Math]::Min($failedFiles.Count, 15); $i++) {
        Write-Host "   > $($failedFiles[$i])" -ForegroundColor DarkRed;
    }
    if ($failedFiles.Count -gt 15) { Write-Host "   > ... and $(($failedFiles.Count) - 15) more." -ForegroundColor DarkRed };
} else {
    Write-Host "`n[SUCCESS] 100% of files downloaded flawlessly!" -ForegroundColor Green;
}

Write-Host "`n[LOG] Transcript saved to: $LogFile" -ForegroundColor DarkGray;
Stop-Transcript | Out-Null;
Read-Host "`nPress Enter to exit...";
