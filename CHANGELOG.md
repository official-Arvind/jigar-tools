# 📋 Jigar Tools — Evolution Log

> **© 2026 Arvind Ji · All Rights Reserved**
> Official repo: https://github.com/official-Arvind/jigar-tools

---

## 🚀 v39.1 — Interactive Selection Engine *(Current)*
> **Focus: Granular Runtime Control**

- **🌲 TreeView EXCLUDE Menu (Sync)** — Dark-themed WinForms TreeView GUI with lazy node loading. After the Android scan, users can cherry-pick exact folders, subfolders, or individual files to exclude from the backup. All items start unchecked (back up everything by default).
- **🌲 TreeView INCLUDE Menu (Restore)** — Green-themed mirror for the restore flow. Users explicitly select which folders/files to push back to the phone. Items default to unchecked so accidental full-restores are prevented.
- **🧠 Most-Specific-Ancestor Filter** — If `DCIM` is checked but `DCIM/Camera` is later unchecked, the more-specific node wins. Partial selections work correctly at every nesting depth.
- **⚡ Lazy Loading** — Root and second-level nodes load instantly; deeper levels populate only when the user expands a folder. Handles 50 000+ file trees without freezing.
- **🔄 Propagation** — Checking a parent checks all loaded and subsequently-loaded children. Unchecking a child overrides the parent via the most-specific-ancestor rule.
- **📊 Live Status Bar** — Real-time item count updates as selections change.
- **Toolbar Buttons** — `✓ Select All`, `✗ Clear All`, `⊞ Expand All`, `⊟ Collapse`, `▶ Proceed`, `Skip (Backup All / Restore All)`.

---

## ⚙️ v39.0 — God Mode System Upgrade
> **Focus: Automation, Memory, Safety**

- **📁 Dynamic Folder Naming** — Backup destinations are now named `DeviceName_YYYY-MM-DD_HH-mm-ss` using `getprop ro.product.model` via ADB.
- **💾 Location Memory** — `settings.json` saves the last chosen base backup path. On next run: `"Use previous location? [Y/N]"` skips the FolderBrowserDialog.
- **📝 Persistent Logging** — `Start-Transcript` / `Stop-Transcript` writes every session to `Logs\SyncLog_*.txt`, `RestoreLog_*.txt`. All `Write-Host` output captured; `Write-Progress` bars excluded by design.
- **🔢 Smart Restore Menu** — Restore script reads the saved base location, lists all backup snapshots newest-first with colour coding, and presents a numbered console menu. Last option always opens FolderBrowserDialog.
- **⛔ Graceful Ctrl+C** — `[System.Console]::add_CancelKeyPress` sets a global abort flag instead of killing the process. Pull/push loops drain cleanly, then `adb shell "rm /data/local/tmp/jgr_*"` cleans temp files.

---

## 🛡️ v5.0 — Launcher God Mode Upgrade
> **Focus: Maintenance & Reliability**

- **🔄 Auto-Updater (Option 5)** — Hits `api.github.com/repos/official-Arvind/jigar-tools/releases/latest`, compares against local `.version` file, downloads and extracts the release ZIP, copies new files while preserving `settings.json`, `Logs\`, and `directory-ignore-list.ini`, then relaunches automatically.
- **🔌 ADB Daemon Shutdown (Option 6)** — Clean exit: `adb kill-server` → `tasklist` verification → force-kill if needed → "ADB server shutdown confirmed" message. Only triggers on intentional menu exit.
- **🗑️ Uninstaller** — New `Jigar_Tools_Uninstall.bat`: UAC elevation, precise PATH segment removal, shortcut deletion, ADB stop, and optional wipe of `Logs\`, all `DeviceName_*` backup folders, `Smart_Backup\`, and `settings.json`.
- **📌 Version Tracking** — `.version` file written on first setup and updated on each auto-update.

---

## 🏗️ v38.2 — Absolute Velocity (Titan Engine)
> **Focus: Maximum Transfer Speed & Reliability**

- **12x Parallel Threads** — RunspacePool with 12 concurrent ADB sessions for both pull and push.
- **3-Stage Fallback** — Standard pull → PC-side temp pull → Root Global Mount (APatch/Magisk). Unconditionally defeats all known ADB path bugs.
- **Smart Virtual Drive Routing** — `subst` maps backup folder to unused drive letter to defeat MAX_PATH; root files bypass the virtual drive to avoid `Z:\` ADB bugs.
- **APatch Global Mount** — Resolves `/sdcard` in root namespace for fully-rooted devices.
- **Quantum Indexing** — Single `find . -type f -exec stat -c '%s|%n'` shell command maps entire storage in one ADB call.
- **Delta Sync** — Compares file sizes; only queues new or modified files.

---

## 🌱 v4.1 — Bulletproof Update
> **Focus: Stability & Path Handling**

- **Iron-Shield Quoting** — Triple-quote shielding fixed the "space in path" bug. Folders like `Jee Papers` now back up flawlessly.
- **Dynamic Size Audit** — Engine calculates exact size of only selected folders before starting.
- **Native Verification** — Replaced legacy CMD pipes with native PowerShell `Measure-Object` logic.
- **Unified Naming** — `fullbackup.ps1` → `JigarSmartSync.ps1`; `ADB_SmartRestore.ps1` → `JigarSmartRestore.ps1`.

---

## 🔧 v4.0 — Unified Master Launcher
- Combined setup, system audit, and tool menu into `Jigar_Tools_Setup.bat`.
- Persistent Admin tunnel via PowerShell `-NoExit` relaunch.
- True Desktop discovery — auto-detects real Desktop path (handles OneDrive).
- Digital Lotus branding with `logo.ico`.

---

## ⚡ v0.4 — Nitro & Path Refinement
- Absolute pathing (v18.3) — eliminated redundant folder clones in archives.
- Nitro Streaming — optimised ADB binary pipes for maximum transfer speed.
- Machine-level PATH — automated permanent registration to Windows environment.

---

## 🔬 v0.2 — No-Mercy Restore
- 100% Integrity Audit (v2.1) — removed sampling; every byte verified.
- Hybrid APK support — dedicated mapping for user-installed APKs.
- Smart Overwrite — restorer skips identical files to save time.

---

## 🧱 v0.1 — Foundation
- PS 5.1 native logic — manually scrubbed for Windows 10/11 compatibility.
- Core backup and restore pipeline established.

---

**Created with raw energy and zero sugar-coating by Arvind Ji. 🚀**
**© 2026 Arvind Ji — https://github.com/official-Arvind/jigar-tools**
