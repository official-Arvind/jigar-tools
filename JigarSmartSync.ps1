#Requires -Version 5.1
# ================================================================
#  JIGAR TOOLS v38.2 - ABSOLUTE VELOCITY (THE TITAN ENGINE)
#  - 3-Stage Fallback: Unconditionally defeats all ADB path bugs
#  - Smart Routing: Bypasses Virtual Drive for Root files
#  - APatch Global Mount: Resolves /sdcard in root namespace
#  - Formatting-Proof: Double-spaced and hardcoded semicolons
# ================================================================

& chcp 65001 | Out-Null;
[Console]::OutputEncoding =[System.Text.Encoding]::UTF8;
[Console]::InputEncoding = [System.Text.Encoding]::UTF8;
$ProgressPreference = 'Continue';
$Host.UI.RawUI.WindowTitle = 'Jigar Tools v38.2 - Titan Engine';
$ErrorActionPreference = 'SilentlyContinue';[System.Environment]::SetEnvironmentVariable("LC_ALL", "C.UTF-8");

Write-Host "`n ==============================================================" -ForegroundColor Cyan;
Write-Host "   JIGAR SMART SYNC (12x THREADS + 3-STAGE TITAN FALLBACK)" -ForegroundColor Cyan;
Write-Host " ==============================================================" -ForegroundColor Cyan;

# ----------------------------------------------------------------
#  0. AUTO-CLEANUP ORPHANED VIRTUAL DRIVES
# ----------------------------------------------------------------
$substOut = & subst;
if ($substOut) {
    foreach ($line in $substOut) {
        if ($line -match "^([A-Z]:)\\: => (.*Smart_Backup.*)$") {
            $drv = $Matches[1];
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
    $url = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip";
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
    Read-Host "Press Enter to exit...";
    exit;
}
$serial = ($devices[0].ToString().Split("`t")[0]).Trim();
Write-Host "[SYSTEM] Device Connected & Verified!" -ForegroundColor Green;

# ----------------------------------------------------------------
#  2. VIRTUAL DRIVE SETUP (DEFEATS MAX_PATH)
# ----------------------------------------------------------------
$destPath = Join-Path $PSScriptRoot "Smart_Backup";
if (-not (Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath -Force | Out-Null };

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
Write-Host "[SYSTEM] Sync Target: $destPath`n" -ForegroundColor DarkGray;

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
        $clean = $line -replace '^/?sdcard/', './';
        $clean = $clean -replace '/$', '';
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

$cmd = "cd /sdcard && find . -type f -exec stat -c '%s|%n' {} + 2>/dev/null";
$procInfo = New-Object System.Diagnostics.ProcessStartInfo;
$procInfo.FileName = $adbExe;
$procInfo.Arguments = "-s $serial shell `"$cmd`"";
$procInfo.RedirectStandardOutput = $true;
$procInfo.UseShellExecute = $false;
$procInfo.StandardOutputEncoding =[System.Text.Encoding]::UTF8;
$procInfo.CreateNoWindow = $true;

$proc =[System.Diagnostics.Process]::Start($procInfo);
$output = $proc.StandardOutput.ReadToEnd() -split "`n";
$proc.WaitForExit();

foreach ($line in $output) {
    $line = $line.Trim();
    $idx = $line.IndexOf('|');
    if ($idx -gt 0) {
        $sz = [long]$line.Substring(0, $idx);
        $file = $line.Substring($idx + 1);
        if ($file.StartsWith("./")) { $AndroidFiles[$file] = $sz };
    }
}
Write-Host "[SCAN] Found $($AndroidFiles.Count) total files on Android." -ForegroundColor Green;

Write-Host "[SCAN] Mapping Local PC Backup..." -ForegroundColor Yellow;
$LocalFiles = @{};
Get-ChildItem -Path $destPath -File -Recurse | ForEach-Object {
    $relPath = $_.FullName.Substring($destPath.Length + 1) -replace '\\', '/';
    $relPath = "./" + $relPath;
    $LocalFiles[$relPath] = $_.Length;
}
Write-Host "[SCAN] Found $($LocalFiles.Count) files currently on PC.`n" -ForegroundColor Green;

# ----------------------------------------------------------------
#  5. CALCULATE DELTA (RESPECTING IGNORE LIST)
# ----------------------------------------------------------------
$ToPull = @();
foreach ($key in $AndroidFiles.Keys) {
    $androidSize = $AndroidFiles[$key];
    
    $skip = $false;
    foreach ($pattern in $IgnorePatterns) {
        if ($key -match $pattern) { $skip = $true; break };
    }
    if ($skip) { continue };

    $pcKey = $key -replace '[<>:"|?*]', '_';
    if (-not $LocalFiles.ContainsKey($pcKey) -or $LocalFiles[$pcKey] -ne $androidSize) {
        $ToPull += $key;
    }
}

$totalFiles = $ToPull.Count;
if ($totalFiles -eq 0) {
    Write-Host "==============================================================" -ForegroundColor Green;
    Write-Host " YOUR PC IS 100% IN SYNC. NO NEW FILES TO DOWNLOAD." -ForegroundColor Green;
    Write-Host "==============================================================`n" -ForegroundColor Green;
    if ($virtDrive) { & subst $virtDrive /D | Out-Null };
    Read-Host "Press Enter to exit...";
    exit;
}
Write-Host "[SYNC] Queued $totalFiles missing or modified files for download." -ForegroundColor Magenta;

# ----------------------------------------------------------------
#  6. THE 12x TITAN PULL ENGINE (SMART PATHING + 3-STAGE FALLBACK)
# ----------------------------------------------------------------
Write-Host "[SYNC] Pre-allocating directory trees natively..." -ForegroundColor DarkGray;
foreach ($file in $ToPull) {
    $cleanPath = $file.Substring(2);
    $safeWinPath = $cleanPath -replace '[<>:"|?*]', '_' -replace '/', '\';
    
    # Smart Routing: Bypass Virtual Drive for Root files to avoid ADB Z:\ bug
    if ($virtDrive -and $safeWinPath -match '\\') {
        $dest = Join-Path $syncTarget $safeWinPath;
    } else {
        $dest = Join-Path $destPath $safeWinPath;
    }

    $destFolder = [System.IO.Path]::GetDirectoryName($dest);
    if (-not [System.IO.Directory]::Exists($destFolder)) {
        [System.IO.Directory]::CreateDirectory($destFolder) | Out-Null;
    }
}

Write-Host "[SYNC] Engaging 12x Parallel Titan Streams...`n" -ForegroundColor Yellow;

$MaxThreads = 12;
$RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads);
$RunspacePool.Open();

$ScriptBlock = {
    param($adbExe, $serial, $src, $dest)
    
    # ---------------------------------------------------
    # ATTEMPT 1: Standard Pull
    # ---------------------------------------------------
    $pInfo = New-Object System.Diagnostics.ProcessStartInfo;
    $pInfo.FileName = $adbExe;
    $pInfo.Arguments = "-s `"$serial`" pull `"$src`" `"$dest`"";
    $pInfo.UseShellExecute = $false;
    $pInfo.CreateNoWindow = $true;
    $p = [System.Diagnostics.Process]::Start($pInfo);
    $p.WaitForExit();
    
    if ($p.ExitCode -eq 0) { return 0; }

    # ---------------------------------------------------
    # ATTEMPT 2: PC-Side Temp Pull (Bypasses ADB Drive Bugs)
    # ---------------------------------------------------
    $pcTemp =[System.IO.Path]::GetTempFileName();
    $pInfo2 = New-Object System.Diagnostics.ProcessStartInfo;
    $pInfo2.FileName = $adbExe;
    $pInfo2.Arguments = "-s `"$serial`" pull `"$src`" `"$pcTemp`"";
    $pInfo2.UseShellExecute = $false;
    $pInfo2.CreateNoWindow = $true;
    $p2 = [System.Diagnostics.Process]::Start($pInfo2);
    $p2.WaitForExit();
    
    if ($p2.ExitCode -eq 0) {
        try {
            [System.IO.File]::Copy($pcTemp, $dest, $true);[System.IO.File]::Delete($pcTemp);
            return 0;
        } catch {}
    }
    
    if ([System.IO.File]::Exists($pcTemp)) {[System.IO.File]::Delete($pcTemp); 
    }

    # ---------------------------------------------------
    # ATTEMPT 3: Root Global Mount Fallback (APatch/Magisk)
    # ---------------------------------------------------
    $uuid = [guid]::NewGuid().ToString().Substring(0,8);
    $androidTmp = "/data/local/tmp/jgr_$uuid";
    $rootSrc = $src -replace "^/sdcard", "/data/media/0";
    
    $suArgs = "-s `"$serial`" shell `"su -c 'cp \`"$rootSrc\`" \`"$androidTmp\`" && chmod 777 \`"$androidTmp\`"'`"";
    $pSuInfo = New-Object System.Diagnostics.ProcessStartInfo;
    $pSuInfo.FileName = $adbExe;
    $pSuInfo.Arguments = $suArgs;
    $pSuInfo.UseShellExecute = $false;
    $pSuInfo.CreateNoWindow = $true;
    $pSu =[System.Diagnostics.Process]::Start($pSuInfo);
    $pSu.WaitForExit();
    
    if ($pSu.ExitCode -eq 0) {
        $pPullInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $pPullInfo.FileName = $adbExe;
        $pPullInfo.Arguments = "-s `"$serial`" pull `"$androidTmp`" `"$dest`"";
        $pPullInfo.UseShellExecute = $false;
        $pPullInfo.CreateNoWindow = $true;
        $pPull = [System.Diagnostics.Process]::Start($pPullInfo);
        $pPull.WaitForExit();
        
        $pRmInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $pRmInfo.FileName = $adbExe;
        $pRmInfo.Arguments = "-s `"$serial`" shell `"rm \`"$androidTmp\`" 2>/dev/null`"";
        $pRmInfo.UseShellExecute = $false;
        $pRmInfo.CreateNoWindow = $true;
        $pRm = [System.Diagnostics.Process]::Start($pRmInfo);
        $pRm.WaitForExit();
        
        return $pPull.ExitCode;
    }

    return 1; # Absolute Failure
}

$ActiveJobs = @();
$failedFiles = @();
$completedCount = 0;

foreach ($file in $ToPull) {
    $cleanPath = $file.Substring(2);
    $src = "/sdcard/$cleanPath";
    $safeWinPath = $cleanPath -replace '[<>:"|?*]', '_' -replace '/', '\';
    
    if ($virtDrive -and $safeWinPath -match '\\') {
        $dest = Join-Path $syncTarget $safeWinPath;
    } else {
        $dest = Join-Path $destPath $safeWinPath;
    }

    $PSInstance = [powershell]::Create().AddScript($ScriptBlock).AddArgument($adbExe).AddArgument($serial).AddArgument($src).AddArgument($dest);
    $PSInstance.RunspacePool = $RunspacePool;
    
    $ActiveJobs += [PSCustomObject]@{
        PS = $PSInstance
        Async = $PSInstance.BeginInvoke()
        File = $cleanPath
    };

    while ($ActiveJobs.Count -ge ($MaxThreads * 2)) {
        $done = $ActiveJobs | Where-Object { $_.Async.IsCompleted };
        foreach ($d in $done) {
            $exitCode = $d.PS.EndInvoke($d.Async);
            if ($exitCode -ne 0) { $failedFiles += $d.File };
            $d.PS.Dispose();
            $completedCount++;
        }
        $ActiveJobs = $ActiveJobs | Where-Object { -not $_.Async.IsCompleted };
        
        if ($done.Count -eq 0) { Start-Sleep -Milliseconds 50 };
        if ($completedCount % 5 -eq 0) {
            Write-Progress -Activity "12x Multi-Threaded Titan Pull" -Status "[$completedCount / $totalFiles] Downloaded" -PercentComplete (($completedCount / $totalFiles) * 100);
        }
    }
}

while ($ActiveJobs.Count -gt 0) {
    $done = $ActiveJobs | Where-Object { $_.Async.IsCompleted };
    foreach ($d in $done) {
        $exitCode = $d.PS.EndInvoke($d.Async);
        if ($exitCode -ne 0) { $failedFiles += $d.File };
        $d.PS.Dispose();
        $completedCount++;
    }
    $ActiveJobs = $ActiveJobs | Where-Object { -not $_.Async.IsCompleted };
    if ($done.Count -eq 0) { Start-Sleep -Milliseconds 100 };
    Write-Progress -Activity "12x Multi-Threaded Titan Pull" -Status "[$completedCount / $totalFiles] Downloaded" -PercentComplete (($completedCount / $totalFiles) * 100);
}
Write-Progress -Activity "12x Multi-Threaded Titan Pull" -Completed;

$RunspacePool.Close();
$RunspacePool.Dispose();
if ($virtDrive) { & subst $virtDrive /D | Out-Null };

# ----------------------------------------------------------------
#  7. SUMMARY
# ----------------------------------------------------------------
Write-Host "`n ==============================================================" -ForegroundColor Green;
Write-Host "   SYNC COMPLETED" -ForegroundColor Green;
Write-Host " ==============================================================" -ForegroundColor Green;

if ($failedFiles.Count -gt 0) {
    Write-Host "`n[REPORT] Skipped $($failedFiles.Count) heavily locked system files:" -ForegroundColor Yellow;
    for ($i = 0; $i -lt [Math]::Min($failedFiles.Count, 15); $i++) {
        Write-Host "   > $($failedFiles[$i])" -ForegroundColor DarkRed;
    }
    if ($failedFiles.Count -gt 15) { Write-Host "   > ... and $(($failedFiles.Count) - 15) more." -ForegroundColor DarkRed };
} else {
    Write-Host "`n[SUCCESS] 100% of files downloaded flawlessly!" -ForegroundColor Green;
}

Read-Host "`nPress Enter to exit...";