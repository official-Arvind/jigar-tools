<p align="center">
  <img src="logo.ico" width="128" height="128"><br>
  <strong>Jigar Tools: God Mode Suite</strong><br>
  <em>The world's most aggressive Android backup & restore engine</em>
</p>

<p align="center">
  <a href="https://github.com/official-Arvind/jigar-tools/releases/latest">
    <img src="https://img.shields.io/github/v/release/official-Arvind/jigar-tools?style=for-the-badge&color=blue&label=Latest%20Release" alt="Latest Release">
  </a>
  <a href="https://github.com/official-Arvind/jigar-tools/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/official-Arvind/jigar-tools?style=for-the-badge&color=orange" alt="Contributors">
  </a>
  <a href="LICENSE.md">
    <img src="https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge" alt="License">
  </a>
</p>

> **Built for power users, by Arvind Ji. Personal use only — see [LICENSE.md](LICENSE.md).**

---

## 🛠️ The Arsenal

### 1. 🚀 `JigarSmartSync.ps1` — Titan Backup Engine (v39.1)

**The Smart Backup Syncer**

| Feature | Details |
|---|---|
| **12x Parallel Threads** | RunspacePool with 12 concurrent ADB sessions — maximum throughput |
| **3-Stage Fallback** | Standard pull → PC-side temp → Root Global Mount. Defeats every known ADB bug |
| **Dynamic Folder Naming** | Saves to `DeviceName_YYYY-MM-DD_HH-mm-ss` — never overwrites previous backups |
| **Location Memory** | Remembers last base backup path via `settings.json` |
| **Interactive EXCLUDE Menu** | WinForms TreeView GUI — lazy-loaded, dark-themed, pick exact folders/files to skip |
| **Delta Sync** | Only pulls new or modified files. Resumable at any time |
| **Persistent Logging** | Full transcript saved to `Logs\SyncLog_*.txt` every session |
| **Graceful Ctrl+C** | Safely drains threads and cleans ADB temp files before exit |

### 2. ⚡ `JigarSmartRestore.ps1` — Titan Restore Engine (v39.1)

**The Surgical Restore Tool**

| Feature | Details |
|---|---|
| **12x Parallel Threads** | Same engine as Sync — lightning-fast PC→Phone push |
| **3-Stage Fallback** | Standard push → Temp push via `/data/local/tmp` → Root fallback |
| **Smart Backup Picker** | Numbered console menu lists snapshots newest-first from saved location |
| **Interactive INCLUDE Menu** | WinForms TreeView GUI — pick exactly which folders/files to restore |
| **Delta Restore** | Only pushes files missing or different on device |
| **Location Memory** | Reads `settings.json` to pre-populate the backup picker |
| **Persistent Logging** | Full transcript saved to `Logs\RestoreLog_*.txt` every session |
| **Graceful Ctrl+C** | Cleans ADB temp files and closes runspace pool safely |

### 3. ⚙️ `Jigar_Tools_Setup.bat` — Master Control Center (v5.0)

**The God Mode Launcher**

| Option | Action |
|---|---|
| `[1]` JigarSync Backup | Launches the Titan backup engine |
| `[2]` Smart Restore | Launches the Titan restore engine |
| `[3]` Device Status | Checks ADB connection, shows device serial and model |
| `[4]` Check for Updates | Queries GitHub API, downloads and installs latest release automatically |
| `[5]` Exit | Kills ADB server daemon, verifies termination, then closes cleanly |

### 4. 🗑️ `Jigar_Tools_Uninstall.bat` — Clean Uninstaller (v1.0)

Reverses everything Setup does:
- Removes tools directory from System PATH
- Deletes the Desktop shortcut
- Stops the ADB server
- Optionally deletes `Logs\`, all backup snapshots, `Smart_Backup\`, and `settings.json`

---

## ⚙️ Installation

1. **Download** the latest release ZIP from the [Releases page](https://github.com/official-Arvind/jigar-tools/releases/latest).
2. **Extract** the `Jigar_Tools` folder anywhere on your PC.
3. **Double-click** `Jigar_Tools_Setup.bat` — it will:
   - Verify PowerShell 5.1+
   - Register the tools folder to System PATH permanently
   - Create a **"Jigar Tools"** shortcut on your Desktop
   - Enter the God Mode Menu automatically
4. **Connect** your Android phone via USB, enable USB Debugging, and choose your weapon.

---

## 🚀 Quick Start (30 seconds)

```
1. Extract Jigar_Tools folder anywhere on your PC
2. Double-click: Jigar_Tools_Setup.bat  (run as Admin if prompted)
3. Connect phone via USB — tap ALLOW on the phone
4. Choose [1] JIGARSYNC BACKUP
5. Select base backup folder (e.g. D:\Backups)
6. Optionally use the EXCLUDE menu to skip WhatsApp media etc.
7. Let the 12x Titan Engine do the work!
```

---

## 📋 Step-by-Step Guide

### ✅ Pre-Flight Checklist

**On Your PC:**
- [ ] Windows 10 or Windows 11
- [ ] PowerShell 5.1 or higher (comes pre-installed on Win 10/11)
- [ ] Sufficient free storage for backups (50GB+ recommended)
- [ ] USB 3.0+ cable for faster transfers

**On Your Android Device:**
- [ ] USB Debugging enabled: `Settings → Developer Options → USB Debugging`
- [ ] USB File Transfer mode selected (not "Charging only")
- [ ] Screen **unlocked** during all operations

**For Rooted Devices (Optional):**
- [ ] Magisk or APatch installed
- [ ] Mount Namespace Mode → **Global** (`Magisk Settings → Superuser → Shell`)
- [ ] BusyBox NDK installed (performance boost)

---

### 🗂️ How Backup Works

```
LAUNCH: Choose [1] JIGARSYNC BACKUP

FLOW:
  1. Fetches device model → builds folder name (e.g. Galaxy_S23_2026-06-11_21-40-00)
  2. Checks settings.json for last location → asks Y/N to reuse
  3. Creates: [BaseFolder]\[DeviceName_Date_Time]\
  4. Maps all files on /sdcard/ via single ADB stat call
  5. Maps existing local backup (delta comparison)
  6. [OPTIONAL] Launches EXCLUDE TreeView GUI — pick folders to skip
  7. Queues only new/modified files
  8. Engages 12x parallel Titan threads
  9. Real-time progress bar (does not appear in log — by design)
 10. Saves full transcript to Logs\SyncLog_*.txt
```

**Output:** `[BaseLocation]\[DeviceName_YYYY-MM-DD_HH-mm-ss]\` — a complete mirror of `/sdcard/`

---

### ♻️ How Restore Works

```
LAUNCH: Choose [2] JIGAR SMART RESTORE

FLOW:
  1. Reads settings.json → shows numbered backup list (newest first)
  2. User picks snapshot by number — or browses for another folder
  3. Maps backup files on PC
  4. Maps current files on device (/sdcard/)
  5. [OPTIONAL] Launches INCLUDE TreeView GUI — pick only what to restore
  6. Queues only files missing or changed on device
  7. Pre-allocates remote directories via mkdir -p
  8. Engages 12x parallel push threads
  9. Saves full transcript to Logs\RestoreLog_*.txt
```

---

### 🌲 Interactive Selection Menus

Both Sync and Restore offer an **optional TreeView GUI** for granular control:

**Sync — EXCLUDE Menu (red theme)**
- All items start **unchecked** (back up everything by default)
- Check folders/files you want to **skip**
- Checking a folder skips everything inside it
- Uncheck a subfolder of a checked parent to rescue it from exclusion
- Press **"Skip (Backup All)"** to bypass the filter entirely

**Restore — INCLUDE Menu (green theme)**
- All items start **unchecked** (nothing included by default)
- Check folders/files you want to **push to the phone**
- Press **"Restore All (Skip)"** to restore everything

**Both menus feature:**
- `✓ Select All` / `✗ Clear All` / `⊞ Expand All` / `⊟ Collapse`
- Live item count in the status bar
- Lazy loading — instant open even with 50,000+ files
- Most-specific-ancestor logic: partial selections are handled correctly

---

### 🔄 Auto-Updater

```
LAUNCH: Choose [4] CHECK FOR UPDATES

FLOW:
  1. Reads local .version file
  2. Queries api.github.com/repos/official-Arvind/jigar-tools/releases/latest
  3. Compares versions
  4. If newer: shows changelog → asks Y/N to update
  5. Downloads release ZIP → extracts → overwrites script files
  6. PRESERVES: settings.json, Logs\, directory-ignore-list.ini, .version
  7. Writes new version tag to .version
  8. Relaunches automatically
```

---

### 🔧 Configuration

#### `directory-ignore-list.ini`

Controls what is **always skipped** during backup and restore (in addition to the interactive menu):

```ini
# Syntax: one path per line. Lines starting with # are comments.
/sdcard/Android/data         # App cache — huge, auto-regenerates
/sdcard/Android/obb          # OBB game data
```

**Common patterns to add:**
```ini
/sdcard/Telegram             # Telegram media (re-downloads from app)
/sdcard/Download             # Downloads folder
/sdcard/DCIM/.thumbnails     # Thumbnail cache
```

#### `settings.json`

Auto-created on first run. Stores:
```json
{ "LastBackupLocation": "D:\\Backups" }
```

Do not edit manually unless relocating your backup drive.

---

### ⚠️ Troubleshooting

| Problem | Solution |
|---|---|
| `No device found` | Check USB cable · Enable USB Debugging · Tap ALLOW · Try different port |
| `Permission denied` | Normal for system files — tool skips and continues |
| Slow speed | USB 3.0 cable · Direct port (no hub) · Disable AV on temp folder |
| Interrupted backup | Re-run — delta sync picks up from where it stopped |
| PowerShell policy error | Re-run `Jigar_Tools_Setup.bat` as Administrator |
| ADB stuck | Menu `[5] Exit` kills the daemon cleanly · Or: Task Manager → end `adb.exe` |

---

### 📊 Performance Metrics

| Scenario | Speed | Estimated Time |
|---|---|---|
| First full backup (50 GB) | 80–150 MB/s | 5–10 min |
| Delta sync (5 GB new files) | 120–180 MB/s | 1–2 min |
| Full restore (50 GB) | 60–120 MB/s | 8–15 min |

*Actual speeds depend on: USB cable quality, phone storage chip speed, PC I/O, and system load.*

---

### 🛡️ Safety Precautions

- ✅ **Never delete phone data** until you have verified the backup
- ✅ **Keep multiple dated snapshots** — the dynamic folder naming makes this effortless
- ✅ **Check `Logs\`** after each session for the full operation transcript
- ✅ **Stable power** — use a UPS or keep laptop plugged in during long transfers
- ✅ **Screen unlocked** — lock screen during ADB transfer causes disconnection

---

### 📞 Getting Help

1. Check `Logs\` — the full transcript shows exact errors.
2. Re-run — most issues are transient ADB hiccups.
3. Restart phone, disconnect and reconnect USB.
4. Open a GitHub Issue at [official-Arvind/jigar-tools](https://github.com/official-Arvind/jigar-tools/issues) with the relevant log snippet.

---

## 🔑 Requirements

| Requirement | Details |
|---|---|
| **OS** | Windows 10 or Windows 11 |
| **PowerShell** | 5.1+ (pre-installed on Win 10/11) |
| **ADB** | Auto-downloaded by the script on first run |
| **USB Debugging** | Must be enabled on the Android device |
| **Root** | Optional — unlocks 3rd-stage fallback for system files |

---

## 💰 Support & Donations

If Jigar Tools saved your data or your time, a small support goes a long way:

- **UPI ID**: `arvindji@fam`
- Pay via GPay, PhonePe, Paytm, or any UPI app.

---

## 🤝 Contributing

1. Fork the repository.
2. Create your feature branch: `git checkout -b feature/YourFeature`
3. Commit your changes: `git commit -m 'Add YourFeature'`
4. Push: `git push origin feature/YourFeature`
5. Open a Pull Request — Arvind Ji reviews all PRs personally.

---

## 📜 License — FriendlySource v1.0

Jigar Tools is **free** and intended to stay that way. Here's the short version:

- ✅ **Use it** — personal, educational, whatever you need.
- ✅ **Contribute** — PRs welcome. Your name goes in the contributors list permanently.
- ✅ **Use it in your app** — as long as your app is **free** and you credit Arvind Ji + link here.
- 🚫 **Don't sell it** — that's the only real rule. Don't be that person.

Full terms: [LICENSE.md](LICENSE.md) · Official repo: **https://github.com/official-Arvind/jigar-tools**

---

**© 2026 Arvind Ji — All Rights Reserved.**
**Created with raw energy and zero sugar-coating. 🚀**