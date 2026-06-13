<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0f0c29,50:302b63,100:24243e&height=200&section=header&text=Contributing&fontSize=60&fontColor=ffffff&fontAlignY=38&desc=Join%20the%20God%20Mode%20Builder%20Crew&descAlignY=58&descSize=20&animation=fadeIn" width="100%"/>

<br/>

[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&weight=700&size=18&duration=2500&pause=800&color=7B61FF&center=true&vCenter=true&width=650&lines=Fork+it.+Build+it.+PR+it.+Get+credited.+%F0%9F%9A%80;Every+contributor+lives+in+this+repo+forever.;No+corporate+BS.+Just+raw+good+code.)](https://github.com/official-Arvind/jigar-tools)

<br/>

<a href="https://github.com/official-Arvind/jigar-tools/issues">
  <img src="https://img.shields.io/github/issues/official-Arvind/jigar-tools?style=for-the-badge&logo=github&logoColor=white&color=e74c3c&label=Open%20Issues" alt="Issues"/>
</a>
&nbsp;
<a href="https://github.com/official-Arvind/jigar-tools/pulls">
  <img src="https://img.shields.io/github/issues-pr/official-Arvind/jigar-tools?style=for-the-badge&logo=git&logoColor=white&color=3498db&label=Open%20PRs" alt="Pull Requests"/>
</a>
&nbsp;
<a href="https://github.com/official-Arvind/jigar-tools/graphs/contributors">
  <img src="https://img.shields.io/github/contributors/official-Arvind/jigar-tools?style=for-the-badge&logo=handshake&logoColor=white&color=22c55e&label=Contributors" alt="Contributors"/>
</a>

</div>

---

## 👋 Welcome, Builder

Jigar Tools is a community project. Every improvement you make — even fixing a typo — gets your name in this repo **permanently**. Arvind Ji reviews every PR personally and is happy to chat about ideas, bugs, or anything else.

This is not a corporate project. There is no roadmap committee, no issue triage bot, no three-week review cycle. If your code is solid and doesn't break anything, it gets merged.

---

## 🌲 Project Structure

```
jigar-tools/
├── 📂 .github/workflows/
│   └── release.yml              # Manual release publisher
├── 📂 docs/
│   ├── CHANGELOG.md             # Full version history
│   └── CONTRIBUTING.md          # This file
├── JigarSmartSync.ps1           # Titan Backup Engine (main)
├── JigarSmartRestore.ps1        # Titan Restore Engine (main)
├── Jigar_Tools_Setup.bat        # Master launcher + auto-updater
├── Jigar_Tools_Uninstall.bat    # Clean uninstaller
├── LICENSE.md                   # FriendlySource License
├── README.md                    # Main documentation
└── logo.ico                     # App icon
```

**Auto-generated at runtime (never committed):**
```
settings.json          # Last backup location
.version               # Installed version for auto-updater
Logs/                  # Session transcripts
directory-ignore-list.ini   # User's skip patterns
[DeviceName_Date]/     # Backup snapshot folders
```

---

## 🛠️ How to Contribute

### Step 1 — Fork & Clone

```bash
# Fork on GitHub first, then:
git clone https://github.com/YOUR-USERNAME/jigar-tools.git
cd jigar-tools
```

### Step 2 — Create a Branch

Name your branch after what you're building:

```bash
git checkout -b feature/faster-indexing
git checkout -b fix/adb-path-spaces
git checkout -b docs/better-troubleshooting
```

### Step 3 — Make Your Changes

Read the **Code Standards** section below before writing anything.

### Step 4 — Commit

Use emoji-prefixed commits — the release workflow auto-categorises them:

```bash
git commit -m "✨ Add parallel progress bar for restore"
git commit -m "🐛 Fix ADB path escaping for folders with brackets"
git commit -m "⚡ Reduce indexing time by 40% using batched stat"
git commit -m "📝 Add troubleshooting for OneDrive Desktop redirect"
git commit -m "🗂️ Rename variables for clarity in Titan engine"
```

### Step 5 — Push & Open PR

```bash
git push origin feature/your-branch-name
```

Then open a Pull Request on GitHub. Fill in the PR description — what it does, why it's needed, how you tested it.

---

## 📖 Commit Message Conventions

The release workflow parses these to auto-generate the changelog. Use them correctly and your work shows up in the right category automatically.

| Prefix / Emoji | Category | Example |
|---|---|---|
| `✨` `feat:` `🚀` `🎉` | ✨ New Features | `✨ Add interactive EXCLUDE tree menu` |
| `⚡` `perf:` `🏎️` `🔥` | ⚡ Performance | `⚡ Batch ADB stat calls for 3x faster scan` |
| `🐛` `fix:` `🔧` `🩹` | 🐛 Bug Fixes | `🐛 Fix path escaping for folders with spaces` |
| `📝` `📚` `docs:` | 📝 Documentation | `📝 Add root setup guide to README` |
| `🗂️` `🧹` `chore:` | 🗂️ Cleanup | `🗂️ Move docs to docs/ folder` |
| `🔼` `updat:` `impr:` | 🔼 Improvements | `🔼 Improve error message clarity` |
| `💥` `breaking:` | 💥 Breaking Changes | `💥 Rename settings key BackupPath → LastLocation` |

---

## 🧱 Code Standards

### PowerShell Scripts

```powershell
# ✅ Good — native PS 5.1, no external modules, clear intent
$files = Get-ChildItem $path -Recurse -File | Select-Object FullName, Length

# ❌ Bad — requires external module, breaks on clean Windows
Import-Module SomeThirdPartyModule
```

- **PS 5.1 compatible** — must run on stock Windows 10/11 with zero installs
- **No external modules** — `System.Windows.Forms` and `System.Drawing` are fine (built-in)
- **Raw personality** — comments should sound like a person wrote them, not a manual
- **No bloat** — if it doesn't make the tool faster, safer, or easier to use, it doesn't belong
- **RunspacePool pattern** — parallel operations must use the existing Titan engine pattern, not `Start-Job`

### Batch Files

- Keep it readable — no one-liner spaghetti
- Test UAC elevation on both Win 10 and Win 11
- Always handle the "ADB not found" case gracefully

### Formatting

- **Indentation**: 4 spaces (PS), or 4 spaces (BAT where applicable)
- **Line endings**: CRLF for `.ps1` and `.bat` (Windows native)
- **Semicolons**: used at end of PS statements inside scriptblocks (existing style)

---

## 💡 Ideas We'd Love

> These are areas where contributions would be especially welcome:

- 📱 **Multi-device support** — backup multiple phones in sequence
- 🔢 **Granular progress bar** — File-by-file detail toggle in GUI
- 🌐 **Network ADB** — support `adb connect IP:PORT` for wireless backups
- 🗓️ **Scheduled backups** — Task Scheduler integration
- 📊 **Backup analytics** — Interactive charts in the HTML logs
- 🧪 **Pester tests** — PowerShell unit tests for the filter/delta logic
- 🌍 **Translations** — README and UI strings in other languages

---

## 🐛 Reporting Bugs

Open a **GitHub Issue** with:

1. **What happened** — exact error message or unexpected behaviour
2. **Steps to reproduce** — what you did before it broke
3. **Your setup** — Windows version, PowerShell version, phone model
4. **Log snippet** — from `Logs\SyncLog_*.txt` or `Logs\RestoreLog_*.txt` (the full transcript is there)

```
Template:
**Describe the bug:** ...
**To reproduce:** ...
**Expected behaviour:** ...
**Windows version:** Win 10 / Win 11
**Phone model:** ...
**Log excerpt:**
[paste relevant lines from Logs\ here]
```

---

## 🤝 Code of Conduct

Simple:

- **Be helpful, not condescending.** Everyone started somewhere.
- **Be direct, not rude.** "This logic is wrong because X" is great. "This is terrible" is not.
- **Give credit.** If you improve someone else's idea, mention them.
- **No spam PRs.** Don't open a PR just to add yourself to a list. Contribute real code or docs.

Arvind Ji reserves the right to close any PR or issue that violates the above — no argument, no drama.

---

<div align="center">

<br/>

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:24243e,50:302b63,100:0f0c29&height=120&section=footer&text=Every%20contributor%20makes%20this%20better&fontSize=16&fontColor=ffffff&fontAlignY=65&animation=fadeIn" width="100%"/>

**© 2026 Arvind Ji · [GitHub](https://github.com/official-Arvind) · [Official Repo](https://github.com/official-Arvind/jigar-tools)**

</div>