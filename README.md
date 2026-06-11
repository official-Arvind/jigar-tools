<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0f0c29,50:302b63,100:24243e&height=220&section=header&text=Jigar%20Tools&fontSize=72&fontColor=ffffff&fontAlignY=38&desc=God%20Mode%20Android%20Suite&descAlignY=58&descSize=22&animation=fadeIn" width="100%"/>

<br/>

[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&weight=700&size=22&duration=3000&pause=800&color=7B61FF&center=true&vCenter=true&multiline=false&width=700&lines=12x+Parallel+Titan+Engine+%E2%9A%A1;Interactive+TreeView+Selection+%F0%9F%8C%B2;Auto-Updater+from+GitHub+%F0%9F%94%84;Clean+Exit+%E2%80%94+No+Memory+Leaks+%F0%9F%94%8C;Built+by+Arvind+Ji+%F0%9F%9A%80)](https://github.com/official-Arvind/jigar-tools)

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
> Built for power users who refuse to wait. Free forever.

</div>

---

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=12,20,28&height=3&section=header" width="100%"/>
</div>

## ⚡ What Is This?

Jigar Tools is a **Windows-native** toolkit that syncs your Android phone to your PC at **absurd speed** — using 12 parallel ADB threads, a 3-stage fallback engine, and a WinForms GUI that lets you pick exactly what to back up or restore. No cloud. No subscriptions. No nonsense.

```
First backup  (50 GB)  →  5–10 minutes   @ 80–150 MB/s
Delta sync    ( 5 GB)  →  < 2 minutes    @ 120–180 MB/s  
Full restore  (50 GB)  →  8–15 minutes   @ 60–120 MB/s
```

---

## 🗂️ The Arsenal

<table>
<tr>
<td width="50%" valign="top">

### 🚀 `JigarSmartSync.ps1`
**Titan Backup Engine v39.1**

- ⚡ **12x parallel ADB threads**
- 🔁 **3-stage fallback** — defeats every ADB bug
- 📁 **Dynamic folder naming** `DeviceName_YYYY-MM-DD_HH-mm-ss`
- 💾 **Location memory** — remembers last base path
- 🌲 **Interactive EXCLUDE tree** — pick what to skip
- 🔄 **Delta sync** — only new / modified files
- 📝 **Full session transcript** saved to `Logs\`
- ⛔ **Graceful Ctrl+C** — cleans ADB temp files safely

</td>
<td width="50%" valign="top">

### ⚡ `JigarSmartRestore.ps1`
**Titan Restore Engine v39.1**

- ⚡ **12x parallel ADB push threads**
- 🔁 **3-stage fallback** on push side
- 🗂️ **Smart snapshot picker** — numbered menu, newest first
- 🌲 **Interactive INCLUDE tree** — pick exactly what to restore
- 🔄 **Delta restore** — skips files already on device
- 💾 **Location memory** — reads `settings.json`
- 📝 **Full session transcript** saved to `Logs\`
- ⛔ **Graceful Ctrl+C** — never leaves orphaned temp files

</td>
</tr>
<tr>
<td width="50%" valign="top">

### ⚙️ `Jigar_Tools_Setup.bat`
**Master Control Center v5.0**

| # | Option |
|---|---|
| 1 | JigarSync Backup |
| 2 | Smart Restore |
| 3 | Device Status |
| 4 | Check for Updates |
| 5 | Exit + Kill ADB |

</td>
<td width="50%" valign="top">

### 🗑️ `Jigar_Tools_Uninstall.bat`
**Clean Uninstaller v1.0**

- Removes tool dir from System PATH
- Deletes Desktop shortcut
- Stops ADB server daemon
- Optionally wipes all backup data & logs

</td>
</tr>
</table>

---

## 🚀 Getting Started

### Step 1 — Download

Grab the latest release ZIP from the **[Releases page](https://github.com/official-Arvind/jigar-tools/releases/latest)** and extract it anywhere.

### Step 2 — Setup (One time only)

```
Right-click  Jigar_Tools_Setup.bat  →  Run as Administrator
```

The launcher will automatically:
- ✅ Verify PowerShell 5.1+
- ✅ Register tools to System PATH permanently
- ✅ Create a **"Jigar Tools"** shortcut on your Desktop
- ✅ Create `settings.json` and `.version` on first run
- ✅ Enter the God Mode Menu

### Step 3 — Connect Your Phone

```
1.  Plug in via USB
2.  On phone → tap  ALLOW  for USB Debugging
3.  Set connection mode to  File Transfer
4.  Keep screen UNLOCKED during all operations
```

### Step 4 — Pick Your Weapon

```
[1] JigarSync Backup   →  Phone to PC  (backup)
[2] Smart Restore      →  PC to Phone  (restore)
[3] Device Status      →  Check ADB connection
[4] Check for Updates  →  GitHub auto-updater
[5] Exit               →  Clean shutdown + ADB kill
```

---

## 🌲 Interactive Selection Menus

Both tools open an **optional dark-themed WinForms TreeView GUI** after scanning — giving you full granular control before any transfer begins.

<table>
<tr>
<td width="50%" valign="top">

**🔴 Sync — EXCLUDE Menu**

- All items start **unchecked** (back up everything)
- Check items to **skip** them
- Checking a folder skips everything inside
- Uncheck a child to rescue it from an excluded parent
- Click **"Skip"** to bypass and back up everything

</td>
<td width="50%" valign="top">

**🟢 Restore — INCLUDE Menu**

- All items start **unchecked** (nothing restores by default)
- Check exactly what you want **pushed to the phone**
- Partial selections work at any nesting depth
- Click **"Restore All"** to bypass and restore everything

</td>
</tr>
</table>

**Most-Specific-Ancestor Rule** — if `DCIM` is checked but `DCIM/Camera` is unchecked, the deeper node wins. Partial selections always behave correctly, no matter how deep the tree goes.

**Lazy Loading** — the tree opens instantly even with 50,000+ files. Folders only load their children when expanded.

---

## 🔄 Auto-Updater

```
[4] CHECK FOR UPDATES  →  Checks github.com/official-Arvind/jigar-tools

Flow:
  1.  Reads local .version file
  2.  Queries GitHub releases API
  3.  Compares versions
  4.  If newer: shows what changed → asks Y/N
  5.  Downloads ZIP → extracts → copies new files
  6.  PRESERVES: settings.json  •  Logs\  •  your config
  7.  Writes new version → relaunches automatically
```

---

## 🔧 Configuration

> All config files are **auto-generated at runtime**. You don't need to create anything manually.

| File | Created By | Purpose |
|---|---|---|
| `settings.json` | JigarSmartSync / Restore | Remembers last backup base location |
| `.version` | Jigar_Tools_Setup.bat | Tracks installed version for auto-updater |
| `Logs\` | Both PS scripts | Full session transcripts |
| `directory-ignore-list.ini` | JigarSmartSync on first run | Paths to always skip during backup |

**Editing `directory-ignore-list.ini`** — add Android paths to permanently skip:

```ini
# One path per line. Lines starting with # are ignored.
/sdcard/Android/data       # App cache — huge, regenerates automatically
/sdcard/Android/obb        # Game OBB files
/sdcard/Telegram           # Media re-downloads from app
/sdcard/DCIM/.thumbnails   # Thumbnail cache
```

---

## ⚠️ Troubleshooting

<details>
<summary><b>🔴 "No device found"</b></summary>
<br/>

- Check USB cable is properly connected
- Enable USB Debugging: `Settings → Developer Options → USB Debugging`
- Tap **ALLOW** when the permission dialog appears on your phone
- Set phone to **File Transfer** mode (not Charging Only)
- Try a different USB port
- Restart ADB: use option `[5] Exit` to kill the daemon, then relaunch

</details>

<details>
<summary><b>🟡 Permission denied / Read-only files</b></summary>
<br/>

This is **completely normal** for system-protected files. The tool automatically skips them and continues. Your personal files (photos, documents, downloads) will always back up without issues. For full system access, root via Magisk with **Global Mount Namespace**.

</details>

<details>
<summary><b>🟡 Slow transfer speed</b></summary>
<br/>

- Use a **USB 3.0+ cable** (USB 2.0 is the most common bottleneck)
- Connect directly to PC — not through a USB hub
- Disable **Windows Defender real-time scanning** for the backup folder during transfer
- Turn off **battery saver mode** on the phone
- Keep the phone screen **on and unlocked**

</details>

<details>
<summary><b>🟡 Backup interrupted mid-way</b></summary>
<br/>

Just **re-run the backup**. Delta sync means only unfinished files will be retransferred. Already completed files are detected by size comparison and skipped automatically.

</details>

<details>
<summary><b>🔵 PowerShell execution policy error</b></summary>
<br/>

Re-run `Jigar_Tools_Setup.bat` as Administrator. The launcher explicitly passes `-ExecutionPolicy Bypass` to every PowerShell call, so this should never appear under normal conditions.

</details>

---

## 📊 Performance

| Scenario | Speed | Time |
|---|---|---|
| First full backup (50 GB) | 80–150 MB/s | 5–10 min |
| Delta sync (5 GB new files) | 120–180 MB/s | ~2 min |
| Full restore (50 GB) | 60–120 MB/s | 8–15 min |
| Selective restore (chosen folders) | 120–180 MB/s | Depends on selection |

*Actual speeds depend on USB cable generation, phone flash storage speed, PC disk I/O, and system load.*

---

## 📋 Requirements

| Requirement | Details |
|---|---|
| **OS** | Windows 10 / Windows 11 |
| **PowerShell** | 5.1+ (pre-installed on Win 10/11) |
| **ADB** | Auto-detected from PATH or `bin\adb.exe` in the tools folder |
| **USB Debugging** | Must be enabled on the Android device |
| **Root** | Optional — enables 3rd-stage fallback for system files |

**For rooted devices:** Set Mount Namespace Mode to **Global** in Magisk Manager → Superuser → Shell. This enables the APatch Global Mount fallback and gives the engine full `/sdcard` access in the root namespace.

---

## 🤝 Contributing

This project is built by the community, for the community. Every contributor gets their name in this repo **permanently**.

```bash
# 1. Fork this repo
# 2. Create your branch
git checkout -b feature/YourAmazingFeature

# 3. Commit
git commit -m "✨ Add YourAmazingFeature"

# 4. Push
git push origin feature/YourAmazingFeature

# 5. Open a Pull Request — Arvind Ji reviews all PRs personally
```

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for detailed guidelines.

---

## 💰 Support

If Jigar Tools saved your data or your sanity, a small chai contribution goes a long way:

> **UPI ID: `arvindji@fam`**
> *(GPay / PhonePe / Paytm / any UPI app)*

---

## 📜 License — FriendlySource v1.0

Jigar Tools is **free** and will stay that way.

- ✅ Use it personally — no restrictions
- ✅ Use it in your **free** app — with credit + link to this repo
- ✅ Contribute and get your name in this project
- 🚫 **Don't sell it.** That's the only rule.

Full terms → [LICENSE.md](LICENSE.md)

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:24243e,50:302b63,100:0f0c29&height=140&section=footer&text=Made%20with%20raw%20energy%20by%20Arvind%20Ji&fontSize=18&fontColor=ffffff&fontAlignY=65&animation=fadeIn" width="100%"/>

**© 2026 Arvind Ji · [GitHub](https://github.com/official-Arvind) · [Official Repo](https://github.com/official-Arvind/jigar-tools)**

</div>