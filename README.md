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

## 🔑 Requirements

* **ADB Platform Tools**: [Download Latest Here](https://developer.android.com/tools/releases/platform-tools).
* **PowerShell 5.1**: Native compatibility for Windows 10/11.
* **USB Debugging**: Device par enable hona chahiye.
* **Root (Optional)**: **Full Hybrid** (APK) backups ke liye zaroori hai.
* **BusyBox NDK**: High performance ke liye recommended hai.

### ⚠️ Essential Magisk Settings (Rooted):
Magisk Manager > Superuser > Shell mein **Mount Namespace Mode** ko **Global Namespace** par set karein.

---

## 📜 License

Jigar Tools is protected under a **Limited Use License**. Personal use is allowed, but unauthorized redistribution or commercial packaging without permission is strictly prohibited. Check `LICENSE.md` for full details.

---
**Created with raw energy and zero sugar-coating by Arvind Ji. 🚀**