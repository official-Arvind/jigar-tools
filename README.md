<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0f0c29,50:302b63,100:24243e&height=220&section=header&text=Jigar%20Tools&fontSize=72&fontColor=ffffff&fontAlignY=38&desc=God%20Mode%20Android%20Suite&descAlignY=58&descSize=22&animation=fadeIn" width="100%"/>

<br/>

[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&weight=700&size=22&duration=3000&pause=800&color=7B61FF&center=true&vCenter=true&multiline=false&width=700&lines=20x+Parallel+Titan+Engine+%E2%9A%A1;Interactive+TreeView+Selection+%F0%9F%8C%B2;Auto-Updater+from+GitHub+%F0%9F%94%84;Clean+Exit+%E2%80%94+No+Memory+Leaks+%F0%9F%94%8C;Built+by+Arvind+Ji+%F0%9F%9A%80)](https://github.com/official-Arvind/jigar-tools)

<br/>

<a href="https://github.com/official-Arvind/jigar-tools/releases/latest">
  <img src="https://img.shields.io/github/v/release/official-Arvind/jigar-tools?style=for-the-badge&logo=github&logoColor=white&label=Latest%20Release&color=7B61FF" alt="Latest Release"/>
</a>
&nbsp;
<a href="https://github.com/official-Arvind/jigar-tools/stargazers">
  <img src="https://img.shields.io/github/stars/official-Arvind/jigar-tools?style=for-the-badge&logo=starship&logoColor=white&color=f7c948" alt="Stars"/>
</a>
&nbsp;
<a href="https://github.com/official-Arvind/jigar-tools/graphs/contributors">
  <img src="https://img.shields.io/github/contributors/official-Arvind/jigar-tools?style=for-the-badge&logo=handshake&logoColor=white&color=22c55e" alt="Contributors"/>
</a>
&nbsp;
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-FriendlySource-orange?style=for-the-badge&logo=opensourceinitiative&logoColor=white" alt="License"/>
</a>

<br/><br/>

> **The world's most aggressive, high-performance Android backup & restore suite.**
> Engineered for power users who refuse to wait. Free forever.

</div>

---

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=12,20,28&height=3&section=header" width="100%"/>
</div>

## ⚡ What Is This?

Jigar Tools is a **Windows-native toolkit** designed to sync your Android device to your PC at **absolute maximum velocity**. It leverages a 20-thread parallel ADB architecture, a robust 3-stage fallback engine, and an elegant WinForms GUI that grants you surgical precision over what to back up or restore. No cloud dependencies. No subscriptions. Pure performance.

```
Initial Backup  (50 GB)  →  5–10 minutes   @ 80–150 MB/s
Delta Sync      ( 5 GB)  →  < 2 minutes    @ 120–180 MB/s  
Full Restore    (50 GB)  →  8–15 minutes   @ 60–120 MB/s
```

---

## 🗂️ The Arsenal

<table>
<tr>
<td width="50%" valign="top">

### 🚀 `JigarSmartSync.ps1`
**Titan Backup Engine**

- ⚡ **20x Parallel ADB Threads** — Maximize USB bandwidth.
- 🔁 **3-Stage Fallback** — Circumvents all known ADB path limitations.
- 📁 **Dynamic Device Folder** — Creates/uses a backup folder named after the device model (e.g. `22101316G`) for clean, in-place Delta Sync.
- 💾 **Location Memory** — Automatically recalls your previous backup destination.
- 🌲 **Interactive EXCLUDE Menu** — Exclude specific folders/files via an intuitive UI.
- 🔄 **Delta Sync** — Intelligently transfers only modified or new files.
- 📝 **Persistent Logging** — Comprehensive transcripts saved to `Logs\`.
- ⛔ **Graceful Abortion** — Safely cleans ADB temporary files on `Ctrl+C`.

</td>
<td width="50%" valign="top">

### ⚡ `JigarSmartRestore.ps1`
**Titan Restore Engine**

- ⚡ **20x Parallel ADB Push Threads** — Lightning-fast data restoration.
- 🔁 **3-Stage Fallback** — Bulletproof injection into the Android filesystem.
- 🗂️ **Smart Backup Picker** — Automatically lists available device backups in a numbered console menu.
- 🌲 **Interactive INCLUDE Menu** — Surgically select exact files/folders to restore.
- 🔄 **Delta Restore** — Bypasses identical files already present on the device.
- 💾 **Location Memory** — Pre-loads snapshots based on your `settings.json`.
- 📝 **Persistent Logging** — Detailed operational logs preserved in `Logs\`.
- ⛔ **Graceful Abortion** — Halts cleanly without leaving orphaned temp files.

</td>
</tr>
<tr>
<td width="50%" valign="top">

### ⚙️ `Jigar_Tools_Setup.bat`
**Master Control Center**

| Option | Action |
|---|---|
| `[1]` | JigarSync Backup (20x Threads) |
| `[2]` | Jigar Smart Restore (Full / Selective) |
| `[3]` | Device Status (Check Connection) |
| `[4]` | Check for Updates (Auto-Updater) |
| `[5]` | Exit (Kills ADB Server) |

</td>
<td width="50%" valign="top">

### 🗑️ `Jigar_Tools_Uninstall.bat`
**Clean System Uninstaller**

- Strips the tool directory from your System `PATH`.
- Removes the Desktop shortcut cleanly.
- Halts the background ADB server daemon.
- Offers optional total wipe of all local backup data and logs.

</td>
</tr>
</table>

---

## 🚀 Getting Started

### Step 1 — Download

Acquire the latest release ZIP from the **[Releases page](https://github.com/official-Arvind/jigar-tools/releases/latest)** and extract the contents anywhere on your system.

### Step 2 — Initial Setup

```
Right-click on Jigar_Tools_Setup.bat → Run as Administrator
```

The God Mode Launcher will autonomously:
- ✅ Validate PowerShell 5.1+ compatibility.
- ✅ Inject the tools directory into your System `PATH` permanently.
- ✅ Generate a **"Jigar Tools"** shortcut on your Desktop.
- ✅ Initialize core configuration files (`settings.json` and `.version`).
- ✅ Boot directly into the Master Control Menu.

### Step 3 — Device Connection

```
1.  Connect your Android device via USB.
2.  On the device → tap ALLOW for USB Debugging authorization.
3.  Set the USB connection mode to File Transfer.
4.  Keep the screen UNLOCKED throughout the operation.
```

### Step 4 — Engage

```
[1] JigarSync Backup   →  Pull data: Phone to PC (20x Threads)
[2] Smart Restore      →  Push data: PC to Phone (20x Threads)
[3] Device Status      →  Check connection status of device
[4] Check for Updates  →  Trigger the GitHub auto-updater
[5] Exit               →  Clean shutdown + ADB server termination
```

---

## 🌲 Interactive Selection Menus

Both core scripts launch an **optional, dark-themed WinForms TreeView GUI** post-scan—granting you absolute, granular control over the data payload before a single byte is transferred.

<table>
<tr>
<td width="50%" valign="top">

**🔴 Sync — EXCLUDE Interface**

- All nodes begin **unchecked** (Full Backup default).
- Check nodes to explicitly **skip** them.
- Checking a directory recursively skips its entire contents.
- Uncheck a nested child to rescue it from a skipped parent.
- Click **"Skip"** to bypass the menu and execute a full mirror.

</td>
<td width="50%" valign="top">

**🟢 Restore — INCLUDE Interface**

- All nodes begin **unchecked** (Zero Restore default).
- Check exact nodes you want **pushed back to the device**.
- Precise partial selections are fully supported at any depth.
- Click **"Restore All"** to bypass the menu and restore the entire snapshot.

</td>
</tr>
</table>

**Most-Specific-Ancestor Logic** — If `/sdcard/DCIM` is excluded, but `/sdcard/DCIM/Camera` is explicitly included, the deeper instruction takes precedence. Complex selection matrices are handled flawlessly.

**Asynchronous Lazy Loading** — The GUI renders instantly, even when parsing 50,000+ files. Subdirectories are populated dynamically only upon expansion.

---

## 🔄 Intelligent Auto-Updater

```
[4] CHECK FOR UPDATES  →  Pings github.com/official-Arvind/jigar-tools

Update Sequence:
  1.  Parses local .version manifest.
  2.  Queries the GitHub Releases API for the latest tag.
  3.  Executes a version comparison.
  4.  If an update exists: displays the changelog → prompts Y/N.
  5.  Downloads release payload → extracts → overwrites core binaries.
  6.  PRESERVES: settings.json, Logs\, and your local configurations.
  7.  Updates local manifest → relaunches automatically.
```

---

## 🔧 Configuration Architecture

> Core configuration files are **auto-generated dynamically at runtime**. Manual intervention is not required.

| Artifact | Generated By | Function |
|---|---|---|
| `settings.json` | Titan Engine (Sync/Restore) | Persists your preferred base backup directory. |
| `.version` | Master Control Center | Tracks the active build for the Auto-Updater. |
| `Logs\` | Titan Engine (Sync/Restore) | Archives comprehensive operation transcripts. |
| `directory-ignore-list.ini` | Titan Engine (Initial Sync) | Defines static paths to bypass during scans. |

**Modifying `directory-ignore-list.ini`** — Append absolute Android paths to permanently exclude them from operations:

```ini
# One path per line. Lines prefixed with # are ignored.
# (Note: /sdcard/Android/data and /sdcard/Android/obb are ignored by the script automatically)
/sdcard/Telegram           # Media re-downloaded natively by the app
/sdcard/DCIM/.thumbnails   # Disposable thumbnail cache
```

---

## ⚠️ Troubleshooting Protocol

<details>
<summary><b>🔴 "No device found" / Connection Failure</b></summary>
<br/>

- Verify physical USB connection integrity.
- Ensure **USB Debugging** is active: `Settings → Developer Options → USB Debugging`.
- Acknowledge the RSA fingerprint prompt on the device (tap **ALLOW**).
- Confirm the USB mode is set to **File Transfer** (MTP), not Charging Only.
- Attempt a different physical USB port or cable.
- Execute option `[5] Exit` to terminate the ADB daemon, then restart the toolkit.

</details>

<details>
<summary><b>🟡 Permission Denied / Read-Only Errors</b></summary>
<br/>

This is **expected behavior** for protected system directories. The Titan Engine automatically logs these and proceeds without interruption. Your personal payload (media, documents, downloads) will sync flawlessly. For absolute system access, root your device via Magisk and enforce a **Global Mount Namespace**.

</details>

<details>
<summary><b>🟡 Sub-Optimal Transfer Velocity</b></summary>
<br/>

- Ensure you are utilizing a **certified USB 3.0+ cable** (USB 2.0 is the primary bottleneck).
- Connect directly to the motherboard; bypass external USB hubs.
- Temporarily disable **Windows Defender Real-Time Protection** for your target backup directory.
- Disable battery saver modes on the Android device.
- Ensure the device screen remains **active and unlocked**.

</details>

<details>
<summary><b>🟡 Operation Interrupted Mid-Transfer</b></summary>
<br/>

Simply **re-initiate the operation**. The Delta Sync engine will automatically compare file sizes and existence, bypassing already transferred data and seamlessly resuming from the point of failure.

</details>

<details>
<summary><b>🔵 PowerShell Execution Policy Restrictions</b></summary>
<br/>

Execute `Jigar_Tools_Setup.bat` with Administrator privileges. The Master Control Center natively bypasses execution policies via `-ExecutionPolicy Bypass`, neutralizing this error under normal conditions.

</details>

---

## 📊 Performance Matrix

| Operation Profile | Bandwidth | Expected Duration |
|---|---|---|
| Initial Full Sync (50 GB) | 80–150 MB/s | 5–10 min |
| Delta Sync (5 GB modified) | 120–180 MB/s | ~2 min |
| Full Snapshot Restore (50 GB) | 60–120 MB/s | 8–15 min |
| Surgical Restore (Targeted) | 120–180 MB/s | Variable based on payload |

*Real-world throughput is contingent upon USB cable specifications, NAND flash write speeds, host PC disk I/O, and ambient system overhead.*

---

## 📋 System Prerequisites

| Prerequisite | Specification |
|---|---|
| **Host OS** | Windows 10 / Windows 11 |
| **Environment** | PowerShell 5.1+ (Native to Windows 10/11) |
| **ADB Binary** | Auto-detected globally or executed locally via `bin\adb.exe` |
| **Device State** | USB Debugging authorized and active |
| **Root Access** | Optional — unlocks the 3rd-stage system fallback |

**For Rooted Hardware:** Enforce the Mount Namespace Mode to **Global** via Magisk Manager → Superuser → Shell. This activates the APatch Global Mount fallback, granting the Titan Engine absolute `/sdcard` dominance within the root namespace.

---

## 🤝 Join the Builder Crew

Jigar Tools is forged by the community. Every validated contribution permanently etches your name into this repository.

```bash
# 1. Fork the repository
# 2. Spin up a feature branch
git checkout -b feature/QuantumOptimization

# 3. Commit your enhancements
git commit -m "✨ Implement Quantum Optimization"

# 4. Push to origin
git push origin feature/QuantumOptimization

# 5. Open a PR — Arvind Ji personally reviews all submissions.
```

Consult the [CONTRIBUTING.md](docs/CONTRIBUTING.md) manifesto for advanced guidelines.

---

## 💰 Fuel the Project

If Jigar Tools salvaged your data or optimized your workflow, consider fueling further development:

> **UPI ID: `arvindji@fam`**
> *(Compatible with GPay, PhonePe, Paytm, and all UPI clients)*

---

## 📜 FriendlySource License v1.0

Jigar Tools is **free** and will permanently remain so.

- ✅ **Deploy it** for personal operations without restriction.
- ✅ **Integrate it** into your **free** software (attribution and repo link required).
- ✅ **Contribute** and elevate the project.
- 🚫 **Do not monetize or sell this codebase.** That is the only non-negotiable rule.

Review the complete manifesto → [LICENSE.md](LICENSE.md)

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:24243e,50:302b63,100:0f0c29&height=140&section=footer&text=Engineered%20with%20raw%20energy%20by%20Arvind%20Ji&fontSize=18&fontColor=ffffff&fontAlignY=65&animation=fadeIn" width="100%"/>

**© 2026 Arvind Ji · [GitHub](https://github.com/official-Arvind) · [Official Repo](https://github.com/official-Arvind/jigar-tools)**

</div>