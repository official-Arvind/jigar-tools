<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0f0c29,50:302b63,100:24243e&height=200&section=header&text=Changelog&fontSize=60&fontColor=ffffff&fontAlignY=38&desc=Every%20update.%20Every%20improvement.%20Every%20commit.&descAlignY=58&descSize=20&animation=fadeIn" width="100%"/>

<br/>

[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&weight=700&size=18&duration=2500&pause=800&color=7B61FF&center=true&vCenter=true&width=650&lines=The+Evolution+of+God+Mode;Constant+improvements+and+refinements;Pushing+the+limits+of+what's+possible)](https://github.com/official-Arvind/jigar-tools)

<br/>

<a href="https://github.com/official-Arvind/jigar-tools/releases/latest">
  <img src="https://img.shields.io/github/v/release/official-Arvind/jigar-tools?style=for-the-badge&logo=github&logoColor=white&color=7B61FF&label=Latest%20Release" alt="Latest Release"/>
</a>
</div>

---

## <img src="https://img.shields.io/badge/v2.0_Gold_Edition-Current-FFD700?style=for-the-badge" align="left" alt="v2.0 Gold Edition"/> &nbsp; God Mode Unlocked
<br>

**Release Date**: June 12, 2026

### 🏆 Major Milestones & Architecture Refactor
- **The Titan Fallback Engine**: Fully rewritten 3-stage fallback system unconditionally bypasses ADB virtual drive write errors across non-rooted devices, Magisk, KernelSU, and APatch.
- **PowerShell Pipeline Bug Exterminated**: Fixed a deeply rooted PowerShell pipeline bug causing false-positive failure reports due to PSDataCollection evaluation issues. The script is now mathematically 100% accurate.
- **HTML Ledger Verified**: Hardened JSON serialization ensures bulletproof, uncorruptable log generation regardless of folder/file names.
- **Unified Codebase**: Synchronized robust Titan architecture between both Sync and Restore tools.

---

## <img src="https://img.shields.io/badge/v39.1-Current-7B61FF?style=for-the-badge" align="left" alt="v39.1"/> &nbsp; Interactive Selection Engine
<br>

> **Focus: Granular Runtime Control**

- ✨ **TreeView EXCLUDE Menu (Sync)** — Dark-themed WinForms TreeView GUI with lazy node loading. After the Android scan, users can cherry-pick exact folders, subfolders, or individual files to exclude from the backup. All items start unchecked (back up everything by default).
- ✨ **TreeView INCLUDE Menu (Restore)** — Green-themed mirror for the restore flow. Users explicitly select which folders/files to push back to the phone. Items default to unchecked so accidental full-restores are prevented.
- 🧠 **Most-Specific-Ancestor Filter** — If `DCIM` is checked but `DCIM/Camera` is later unchecked, the more-specific node wins. Partial selections work correctly at every nesting depth.
- ⚡ **Lazy Loading** — Root and second-level nodes load instantly; deeper levels populate only when the user expands a folder. Handles 50 000+ file trees without freezing.
- 🔄 **Propagation** — Checking a parent checks all loaded and subsequently-loaded children. Unchecking a child overrides the parent via the most-specific-ancestor rule.
- 📊 **Live Status Bar** — Real-time item count updates as selections change.
- 🛠️ **Toolbar Buttons** — `✓ Select All`, `✗ Clear All`, `⊞ Expand All`, `⊟ Collapse`, `▶ Proceed`, `Skip (Backup All / Restore All)`.

---

## <img src="https://img.shields.io/badge/v39.0-God%20Mode%20System%20Upgrade-blue?style=for-the-badge" align="left" alt="v39.0"/> &nbsp; God Mode System Upgrade
<br>

> **Focus: Automation, Memory, Safety**

- 📁 **Dynamic Folder Naming** — Backup destinations are now named `DeviceName_YYYY-MM-DD_HH-mm-ss` using `getprop ro.product.model` via ADB.
- 💾 **Location Memory** — `settings.json` saves the last chosen base backup path. On next run: `"Use previous location? [Y/N]"` skips the FolderBrowserDialog.
- 📝 **Persistent Logging** — `Start-Transcript` / `Stop-Transcript` writes every session to `Logs\SyncLog_*.txt`, `RestoreLog_*.txt`. All `Write-Host` output captured; `Write-Progress` bars excluded by design.
- 🔢 **Smart Restore Menu** — Restore script reads the saved base location, lists all backup snapshots newest-first with colour coding, and presents a numbered console menu. Last option always opens FolderBrowserDialog.
- ⛔ **Graceful Ctrl+C** — `[System.Console]::add_CancelKeyPress` sets a global abort flag instead of killing the process. Pull/push loops drain cleanly, then `adb shell "rm /data/local/tmp/jgr_*"` cleans temp files.

---

## <img src="https://img.shields.io/badge/v5.0-Launcher%20God%20Mode%20Upgrade-blue?style=for-the-badge" align="left" alt="v5.0"/> &nbsp; Launcher God Mode Upgrade
<br>

> **Focus: Maintenance & Reliability**

- 🔄 **Auto-Updater (Option 5)** — Hits `api.github.com/repos/official-Arvind/jigar-tools/releases/latest`, compares against local `.version` file, downloads and extracts the release ZIP, copies new files while preserving `settings.json`, `Logs\`, and `directory-ignore-list.ini`, then relaunches automatically.
- 🔌 **ADB Daemon Shutdown (Option 6)** — Clean exit: `adb kill-server` → `tasklist` verification → force-kill if needed → "ADB server shutdown confirmed" message. Only triggers on intentional menu exit.
- 🗑️ **Uninstaller** — New `Jigar_Tools_Uninstall.bat`: UAC elevation, precise PATH segment removal, shortcut deletion, ADB stop, and optional wipe of `Logs\`, all `DeviceName_*` backup folders, `Smart_Backup\`, and `settings.json`.
- 📌 **Version Tracking** — `.version` file written on first setup and updated on each auto-update.

---

## <img src="https://img.shields.io/badge/v38.2-Absolute%20Velocity%20(Titan%20Engine)-blue?style=for-the-badge" align="left" alt="v38.2"/> &nbsp; Absolute Velocity (Titan Engine)
<br>

> **Focus: Maximum Transfer Speed & Reliability**

- 🚀 **12x Parallel Threads** — RunspacePool with 12 concurrent ADB sessions for both pull and push.
- 🛡️ **3-Stage Fallback** — Standard pull → PC-side temp pull → Root Global Mount (APatch/Magisk). Unconditionally defeats all known ADB path bugs.
- 🛣️ **Smart Virtual Drive Routing** — `subst` maps backup folder to unused drive letter to defeat MAX_PATH; root files bypass the virtual drive to avoid `Z:\` ADB bugs.
- 🌍 **APatch Global Mount** — Resolves `/sdcard` in root namespace for fully-rooted devices.
- 🔎 **Quantum Indexing** — Single `find . -type f -exec stat -c '%s|%n'` shell command maps entire storage in one ADB call.
- 🔄 **Delta Sync** — Compares file sizes; only queues new or modified files.

---

## <img src="https://img.shields.io/badge/v4.1-Bulletproof%20Update-blue?style=for-the-badge" align="left" alt="v4.1"/> &nbsp; Bulletproof Update
<br>

> **Focus: Stability & Path Handling**

- 🛡️ **Iron-Shield Quoting** — Triple-quote shielding fixed the "space in path" bug. Folders like `Jee Papers` now back up flawlessly.
- 📊 **Dynamic Size Audit** — Engine calculates exact size of only selected folders before starting.
- ✅ **Native Verification** — Replaced legacy CMD pipes with native PowerShell `Measure-Object` logic.
- 📝 **Unified Naming** — `fullbackup.ps1` → `JigarSmartSync.ps1`; `ADB_SmartRestore.ps1` → `JigarSmartRestore.ps1`.

---

## <img src="https://img.shields.io/badge/v4.0-Unified%20Master%20Launcher-blue?style=for-the-badge" align="left" alt="v4.0"/> &nbsp; Unified Master Launcher
<br>

- ⚙️ Combined setup, system audit, and tool menu into `Jigar_Tools_Setup.bat`.
- 🚇 Persistent Admin tunnel via PowerShell `-NoExit` relaunch.
- 🖥️ True Desktop discovery — auto-detects real Desktop path (handles OneDrive).
- 🪷 Digital Lotus branding with `logo.ico`.

---

## <img src="https://img.shields.io/badge/v0.4-Nitro%20&%20Path%20Refinement-blue?style=for-the-badge" align="left" alt="v0.4"/> &nbsp; Nitro & Path Refinement
<br>

- 📂 Absolute pathing (v18.3) — eliminated redundant folder clones in archives.
- 🏎️ Nitro Streaming — optimised ADB binary pipes for maximum transfer speed.
- ⚙️ Machine-level PATH — automated permanent registration to Windows environment.

---

## <img src="https://img.shields.io/badge/v0.2-No--Mercy%20Restore-blue?style=for-the-badge" align="left" alt="v0.2"/> &nbsp; No-Mercy Restore
<br>

- 🔬 100% Integrity Audit (v2.1) — removed sampling; every byte verified.
- 📦 Hybrid APK support — dedicated mapping for user-installed APKs.
- 🧠 Smart Overwrite — restorer skips identical files to save time.

---

## <img src="https://img.shields.io/badge/v0.1-Foundation-22c55e?style=for-the-badge" align="left" alt="v0.1"/> &nbsp; Foundation
<br>

- 💻 PS 5.1 native logic — manually scrubbed for Windows 10/11 compatibility.
- 🏗️ Core backup and restore pipeline established.

---

<div align="center">

<br/>

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:24243e,50:302b63,100:0f0c29&height=120&section=footer&text=Built%20version%20by%20version,%20with%20raw%20energy&fontSize=16&fontColor=ffffff&fontAlignY=65&animation=fadeIn" width="100%"/>

**© 2026 Arvind Ji · [GitHub](https://github.com/official-Arvind) · [Official Repo](https://github.com/official-Arvind/jigar-tools)**

</div>

