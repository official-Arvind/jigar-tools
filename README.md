# <p align="center"><img src="logo.ico" width="128" height="128"><br>Jigar Tools: God Mode Suite</p>

<p align="center">
  <a href="https://github.com/official-Arvind/jigar-tools/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/official-Arvind/jigar-tools?style=for-the-badge&color=orange" alt="Contributors">
  </a>
  <a href="#-support--donations">
    <img src="https://img.shields.io/badge/Support-Donate-brightgreen?style=for-the-badge&logo=google-pay" alt="Donate">
  </a>
</p>

> **The world's most aggressive, high-performance Android management utilities. Built for power users, by Arvind Ji.**

---

## 🛠️ The Arsenal

### 1. 🚀 `JigarSmartSync.ps1` (v38.2 Titan Engine)
**The Smart Backup Syncer**
* **12x Parallel Threads**: Massive parallel throughput for ultra-fast file transfers from Android to PC.
* **3-Stage Fallback**: Defeats ADB path bugs with intelligent routing and virtual drive mapping.
* **Smart Routing**: Bypasses Virtual Drive for root files, avoids system-level path conflicts.
* **Delta Sync**: Intelligent file comparison - only pulls new or modified files, skipping what's already backed up.
* **Ignore Rules**: Respect custom ignore patterns from `directory-ignore-list.ini` to skip unwanted folders.
* **Auto Indexing**: Rapid scanning and mapping of Android storage before sync begins.
* **Size Verification**: Validates file integrity between device and PC storage.

### 2. ⚡ `JigarSmartRestore.ps1` (v38.2 Titan Restore)
**The Surgical Restore Tool - Mirror of Backup Power**
* **12x Parallel Threads**: Lightning-fast restore from PC to phone with massive parallel throughput.
* **3-Stage Fallback**: Same 3-stage fallback as backup - defeats ADB path bugs on restore.
* **Delta Restore**: Intelligent comparison - only pushes files missing or different on device.
* **Full Folder Restore**: Automatically scans backup folder and restores entire directory structure to `/sdcard/`.
* **Ignore Rules**: Respects `directory-ignore-list.ini` to skip unwanted folders during restore.
* **Auto Indexing**: Fast scanning and mapping of both backup and device storage before starting.
* **100% Integrity Check**: Validates file sizes before pushing to ensure data integrity.
* **Smart Path Handling**: Correctly handles paths with spaces and special characters flawlessly.

### 3. 🛡️ `paranoid.ps1`
**The Truth Seeker**
* **Deep Audit**: Scans for hidden system files that standard backups might skip.
* **Audit Logs**: Provides a clear count of exactly what was safely tucked away.

---

## 💰 Support & Donations

Bhai, agar Jigar Tools ne tera data ya waqt bachaya hai, toh ek choti si support dikhao taaki main isse aur upgrade kar sakun.

* **UPI ID**: `arvindji@fam`
* **Scan to Pay**: Use any UPI app (GPay, PhonePe, Paytm).

---

## 🤝 Contributing

Together, we'll make the world's most aggressive Android suite.
1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## ⚙️ Installation (The "Flower" Setup)

Don't mess with manual Path settings. We've automated everything with **Launcher v4.0**:

1. **Extract**: Unzip the **Jigar_Tools** folder anywhere on your PC.
2. **Setup**: Double-click `Jigar_Tools_Setup.bat`.
    * Ye **permanently** tumhare folder ko System PATH mein add kar dega.
    * Ye Desktop par ek **Digital Lotus** shortcut "plant" karega.
3. **Launch**: Desktop se **Jigar Tools** app open karo aur apna weapon choose karo.

---

## � Complete Universal Guide

### 🎯 Pre-Flight Checklist

Before you start, ensure you have everything ready:

#### ✅ **On Your PC**
- [ ] Windows 10 or Windows 11
- [ ] PowerShell 5.1 or higher
- [ ] At least 50GB free storage (for backups)
- [ ] USB 3.0+ cable for faster transfers

#### ✅ **On Your Android Device**
- [ ] USB Debugging enabled (Settings → Developer Options → USB Debugging)
- [ ] USB File Transfer mode enabled (Settings → System → USB debugging)
- [ ] Screen unlocked during operations
- [ ] Sufficient storage space

#### ✅ **For Advanced Users (Root)**
- [ ] Magisk or APatch installed
- [ ] Mount Namespace Mode set to Global (Magisk Settings → Superuser → Shell)
- [ ] BusyBox NDK installed (recommended for performance)

---

### 🚀 Quick Start (30 Seconds)

```
1. Extract Jigar_Tools folder anywhere on your PC
2. Double-click: Jigar_Tools_Setup.bat
3. Connect your phone via USB
4. Choose your weapon from the menu
5. Let the Titan Engine do the work!
```

---

### 📋 Step-by-Step Guides

#### **STEP 1️⃣: Initial Setup (One Time Only)**

```
ACTION: Double-click Jigar_Tools_Setup.bat

WHAT HAPPENS:
✓ Checks PowerShell version (must be 5.1+)
✓ Verifies all scripts are present
✓ Registers tools to Windows System PATH
✓ Creates "Jigar Tools" shortcut on Desktop
✓ Enters the God Mode Menu

TIME: ~5-10 seconds
```

---

#### **STEP 2️⃣: Connect Your Android Device**

Before running ANY tool, ensure proper connection:

```
1. Plug in phone via USB cable
2. On phone: Tap "Allow" for USB Debugging permission
3. On PC: Wait for "Device Connected & Verified!" message
4. Phone screen should stay UNLOCKED during operations
5. Select "File Transfer" mode on phone (not charging only)
```

⚠️ **Connection Issues?**
- Try different USB port
- Use original USB cable
- Update ADB drivers from [Android Developer Tools](https://developer.android.com/tools/releases/platform-tools)
- Restart adb: Manually delete `%appdata%\.android` folder and reconnect

---

#### **STEP 3️⃣: JigarSmartSync (Backup)**

**What it does:** Backs up your entire `/sdcard/` from phone to PC at lightning speed.

```
LAUNCH: Choose [1] JIGARSYNC BACKUP

PROCESS:
1. Auto-detects your connected device
2. Creates "Smart_Backup" folder in the tools directory
3. Scans phone storage (may take 30-60 seconds)
4. Compares with existing backup
5. Shows files to download (delta sync)
6. Starts 12x parallel download threads
7. Real-time progress bar
8. Shows summary (successful + skipped)

TIME: 5-30 minutes (depending on data size)
OUTPUT: ./Smart_Backup/ folder with complete /sdcard/ copy
```

**Features:**
- ✓ Only downloads NEW or MODIFIED files (delta sync)
- ✓ Skips ignored folders from directory-ignore-list.ini
- ✓ Handles paths with spaces and special characters
- ✓ Validates file sizes for integrity
- ✓ Recovers from ADB disconnections (3-stage fallback)

**Best Practices:**
- Backup frequently (weekly recommended)
- Don't interrupt during download (let it finish)
- Keep phone screen on during backup
- Use faster USB 3.0+ cables
- Disable antivirus scanning of temp files (improves speed)

---

#### **STEP 4️⃣: JigarSmartRestore (Restore)**

**What it does:** Restores your backed-up files from PC back to phone's `/sdcard/`.

```
LAUNCH: Choose [2] JIGAR SMART RESTORE

PROCESS:
1. Auto-detects your connected device
2. Prompts: "Select Backup Folder" (choose Smart_Backup)
3. Scans backup folder on PC
4. Compares with phone storage
5. Shows files to restore (only new/different)
6. Starts 12x parallel upload threads
7. Real-time progress bar
8. Shows summary (successful + skipped read-only files)

TIME: 5-20 minutes (depending on data size)
RESULT: Phone's /sdcard/ synchronized with backup
```

**Features:**
- ✓ Intelligent delta restore (only missing files)
- ✓ Respects ignore list patterns
- ✓ Full folder structure restoration
- ✓ Smart path conversion
- ✓ 3-stage fallback if files are locked

**When to Use:**
- After factory reset
- To transfer phone backups to new device
- To recover accidentally deleted files
- Migration from old to new phone

**Important Notes:**
- Read-only system files may fail (normal - skipped)
- Some app data may restore but require app reinstall
- Certain privileged system files need root access
- Keep phone screen on during restore

---

#### **STEP 5️⃣: Paranoid Audit (Verify)**

**What it does:** Deep verification that backup matches device storage exactly.

```
LAUNCH: Choose [3] PARANOID CHECK

PROCESS:
1. Connects to device
2. Prompts: Select folder to verify
3. Choice [1] Verify Everything OR [2] Selective (GUI checkbox)
4. Scans every single file
5. Compares sizes: PC vs Phone
6. Reports mismatches
7. Shows final count (X files verified clean)

TIME: 2-10 minutes (depends on file count)
OUTPUT: [REPORT] Verified Clean: 5000 / 5000
```

**Use Cases:**
- After backup to ensure integrity
- Before restoring to catch corruptions
- Verify both devices are in sync
- Peace of mind check

**Interpretation:**
```
✓ Verified Clean: 5000 / 5000  → Everything is perfect!
✓ Verified Clean: 4998 / 5000  → 2 files mismatched (investigate)
⚠ [MISMATCH] path/to/file      → This specific file differs
```

---

### 🔧 Configuration Files

#### **directory-ignore-list.ini**

This file controls what gets SKIPPED during backup/restore:

```
# Syntax: One path per line
# Format: /sdcard/path/to/ignore

/sdcard/.transforms
/sdcard/Android
# Add more paths below (one per line)
```

**How to Edit:**
1. Open `directory-ignore-list.ini` with Notepad
2. Add paths you want to ignore (one per line)
3. Save and re-run backup/restore
4. Those paths will be skipped

**Common Ignore Patterns:**
```
/sdcard/Android/data         # App cache (huge, auto-regenerates)
/sdcard/Android/obb          # OBB files (app data)
/sdcard/Telegram             # Telegram media (can be auto-recovered)
/sdcard/Download             # Downloads folder (can redownload)
/sdcard/DCIM/.thumbnails    # Thumbnail cache
```

---

### ⚠️ Troubleshooting Guide

#### **Problem: "No device found"**
```
✓ Check USB cable connection
✓ Enable USB Debugging on phone
✓ Tap "Allow" when permission prompt appears
✓ Try different USB port
✓ Restart adb: Remove %appdata%\.android folder
✓ Update Android Platform Tools
```

#### **Problem: Permission denied / Read-only files**
```
✓ This is NORMAL for system files
✓ Root access (Magisk) helps but not required
✓ Tool will skip and continue
✓ User files will be backed up fine
```

#### **Problem: Slow transfer speed**
```
✓ Use USB 3.0+ cable (USB 2.0 is slow)
✓ Connect directly to PC (not via hub)
✓ Close other programs using USB
✓ Disable Windows Defender during backup
✓ Phone: Disable battery saver mode
```

#### **Problem: Interrupted backup/restore**
```
✓ Reconnect device
✓ Run again - Delta sync will resume
✓ Already transferred files won't be re-transferred
✓ Safe to retry as many times as needed
```

#### **Problem: PowerShell execution policy error**
```
✓ Already handled by our launcher
✓ If still occurs: Restart Setup.bat with Admin
✓ Let it run the PowerShell verification
✓ Should automatically fix permissions
```

---

### 🎮 Advanced Tips

#### **Selective Backup/Restore with GUI**

The tools remember your preferences:
- Choose [2] for selective mode
- Checkbox GUI appears with folder list
- Select specific folders to backup/restore
- Faster when you only need certain data

#### **Custom Ignore Patterns**

Edit `directory-ignore-list.ini`:
```
/sdcard/MyLargeFolder
/sdcard/CacheFolder
# Backup will skip these folders
```

#### **Root Privileges (Magisk)**

For best results with rooted devices:
1. Install Magisk
2. Enable "Mount Namespace Mode: Global"
3. Install BusyBox NDK
4. Run backup/restore (3-stage fallback uses root)
5. Achieves 100% system file access

#### **Batch Scheduling**

Create a `.bat` file to run backups automatically:
```batch
@echo off
cd /d "C:\path\to\Jigar_Tools"
REM Wait for device connection
timeout /t 10
REM Run backup
powershell -NoProfile -ExecutionPolicy Bypass -File "JigarSmartSync.ps1"
```

---

### 📊 Performance Metrics

Expected transfer speeds:

| Scenario | Speed | Time |
|----------|-------|------|
| First backup (50GB) | 80-150 MB/s | 5-10 min |
| Delta sync (5GB) | 120-180 MB/s | 1-2 min |
| Restore (50GB) | 60-120 MB/s | 8-15 min |
| Audit check | 500+ files/sec | Fast |

*Depends on: USB cable, phone speed, storage type, system load*

---

### 🛡️ Safety Precautions

✓ **Backup before restore** - Always keep original backup safe
✓ **Test restore** - Verify restore on new device first
✓ **Power stable** - Use UPS to prevent power loss during ops
✓ **Keep originals** - Don't delete phone data until verified
✓ **Monitor space** - Ensure PC has enough free space
✓ **Track versions** - Keep multiple backup dates

---

### 📞 Getting Help

If something goes wrong:

1. **Check Logs**: Last operation shows detailed error messages
2. **Try Again**: Many issues resolve with retry
3. **Restart Device**: Disconnect, restart phone, reconnect
4. **Check Connection**: Try different USB port/cable
5. **Report Issue**: Open GitHub issue with error message
6. **Request Permission**: Contact Arvind Ji for special cases

---

## 🔑 Requirements

* **ADB Platform Tools**: [Download Latest Here](https://developer.android.com/tools/releases/platform-tools).
* **PowerShell 5.1**: Native compatibility for Windows 10/11.
* **USB Debugging**: Device par enable hona chahiye.
* **Root (Optional)**: **Full System Access** ke liye zaroori hai, but everything works without root.
* **BusyBox NDK**: High performance ke liye recommended hai.

### ⚠️ Essential Magisk Settings (Rooted):
Magisk Manager > Superuser > Shell mein **Mount Namespace Mode** ko **Global Namespace** par set karein.

---

## 📜 License

Jigar Tools is protected under a **Limited Use License**. Personal use is allowed, but unauthorized redistribution or commercial packaging without permission is strictly prohibited. Check `LICENSE.md` for full details.

---
**Created with raw energy and zero sugar-coating by Arvind Ji. 🚀**