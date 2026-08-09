# WinUtilKLENN

[![License: GPL-3.0](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-0078D6.svg)](README.md)
[![GitHub: sanguirIS](https://img.shields.io/badge/GitHub-sanguirIS-181717?logo=github&logoColor=white)](https://github.com/sanguirIS)
[![CI](https://github.com/sanguirIS/WinUtilKLENN/actions/workflows/sanity-check.yml/badge.svg)](https://github.com/sanguirIS/WinUtilKLENN/actions/workflows/sanity-check.yml)

**Diagnostics and guided repair tools for Windows 10 / 11.**

> **Repository:** https://github.com/sanguirIS/WinUtilKLENN

WinUtilKLENN is a single-file batch utility that gives you a friendly, color-coded menu of 15 diagnostic and repair actions — audio, video, network, printers, cameras, Windows Update, and more — plus optional integration with the popular [Chris Titus Tech WinUtil](https://github.com/ChrisTitusTech/winutil) toolbox.

- **Single file** — no installation, no dependencies beyond what Windows ships with.
- **Runs as Administrator** — self-elevates via UAC when needed.
- **Everything is logged** — every action is recorded to `%ProgramData%\WinUtilKLENN\WinUtilKLENN.log`.
- **Auto-fitted console** — the window resizes to fit your screen (capped at 68×40) on every screen, so the menu border always renders cleanly.

---

## Features

| # | Category | Option | What it does |
|---|---|---|---|
| 1 | Media | Audio | Audio service + device status; can restart audio services |
| 2 | Media | Video Playback | Lists display adapters and GPU driver details |
| 3 | Media | Windows Media Player | Checks WMP presence and media file associations |
| 4 | Connectivity | Network and Internet | Adapters, IP config, ping/DNS tests, optional Winsock + TCP/IP reset |
| 5 | Connectivity | DNS Flush | Shows DNS servers + cache; flushes the resolver cache |
| 6 | Connectivity | Bluetooth | Lists Bluetooth devices; can restart the Bluetooth service |
| 7 | Devices | Printer | Print Spooler status, installed printers, spooler restart + stuck-job clear |
| 8 | Devices | Camera | Camera devices + webcam privacy setting, PnP rescan |
| 9 | Devices | Graphics Driver Reset | Restarts display adapter(s) via `pnputil` (screen may flicker) |
| 10 | Windows Update | Windows Update | Service status, reboot flags, update-cache reset, DISM + SFC |
| 11 | Windows Update | BITS | BITS service status and active jobs; service restart |
| 12 | Other / Tools | Program Compatibility | Inspects an `.exe` file's version info |
| 13 | Other / Tools | Run ALL Diagnostics | Runs the diagnostic portions of options 1–8 at once |
| 14 | Other / Tools | System Summary | OS, RAM, disk, PowerShell version |
| 15 | Other / Tools | Chris Titus Tech WinUtil | Guided setup of the WinUtil toolbox (see below) |
| 0 | — | Exit | Closes the tool |

## Requirements

- Windows 10 or Windows 11
- PowerShell (ships with Windows; 5.1+ recommended)
- Administrator rights for most repair actions (the script self-elevates; you can also right-click → **Run as administrator**)

## Usage

1. Right-click `WinUtilKLENN.cmd` → **Run as administrator** (or double-click and accept the UAC prompt).
2. Type the number of the option you want and press **Enter**.
3. Follow the on-screen prompts. Most options ask **Y/N** before making any changes.

### Using Chris Titus Tech WinUtil (option 15)

Option 15 walks you through, step by step:

1. Creates `Documents\PowerShell` if it does not exist.
2. Downloads `winutil.ps1` (pinned release **26.08.04** or latest) into that folder.
3. Checks and optionally sets the PowerShell execution policy (Process scope).
4. Tries `winget install --id ChrisTitusTech.winutil` if winget is available.
5. Launches WinUtil with `irm https://christitus.com/win | iex`.

## How it works

- **Self-elevation** — if not running as Administrator, the script restarts itself elevated through UAC. If you cancel the prompt, no changes are made.
- **Logging** — every repair action, plus the applied console window size, is appended to `%ProgramData%\WinUtilKLENN\WinUtilKLENN.log`.
- **Auto-sizing console** — the window grows to the largest size that fits your screen and console font (capped at 68×40, 9000-row buffer). It re-applies on every screen so the 66-character border never wraps.

## Third-party tools & websites (and their licenses)

This tool invokes or integrates the following third-party resources. Each belongs to its respective owner and is governed by its own terms.

| Resource | Website / Source | License | Used for |
|---|---|---|---|
| Chris Titus Tech WinUtil | https://github.com/ChrisTitusTech/winutil · https://christitus.com/win | [MIT](https://github.com/ChrisTitusTech/winutil/blob/main/LICENSE) (© 2022 CT Tech Group LLC) | Option 15 — optional toolbox setup |
| Microsoft Windows built-in tools (`DISM`, `SFC`, `netsh`, `ipconfig`, `pnputil`, `sc`, `winget`) | https://learn.microsoft.com | Subject to [Microsoft Software License Terms](https://www.microsoft.com/en-us/legal/terms-of-use) | Diagnostics and repair actions (options 1–14) |
| Microsoft PowerShell | https://github.com/PowerShell/PowerShell | [MIT](https://github.com/PowerShell/PowerShell/blob/main/LICENSE.txt) | Automation used throughout the script |

> **Responsibility for third-party resources:** WinUtilKLENN only downloads, invokes, or points to these tools. The author of WinUtilKLENN is **not responsible** for the behaviour, availability, licensing, or content of any third-party website or tool. Running third-party scripts (including WinUtil) is at **your own discretion** — review them before executing.

The full license texts of these projects are collected in [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md).

## Disclaimer of responsibility

**Use at your own risk.**

WinUtilKLENN performs actions that change system configuration (services, drivers, the network stack, the Windows Update cache, and more). While the script tries to be careful, the author:

- makes **no warranties** of any kind, express or implied, about this software;
- is **not liable** for any damage, data loss, or system issues — including issues arising from WinUtil or any third-party tool — resulting from the use of this script;
- recommends you **review the script** (`WinUtilKLENN.cmd`) and **back up important data** before running repair actions;
- notes that `DISM`, `SFC`, and driver-reset options can take a long time and may cause temporary display flicker.

By using WinUtilKLENN you agree that you are responsible for your own system.

## Changelog

### v2.4.1 — Licensing and polish fixes
- Added the GPL-3.0 header and the warranty notice (menu and exit screens), as required by the license.
- Startup resize now runs after the log directory exists, so the applied window size is logged on first launch too.
- Screen headers shortened (`RULE_SMALL` 40 → 36 chars) so long titles fit the 68-column window without wrapping.
- Option 15: WinUtil download labels shortened to prevent the long URLs from wrapping at 68 columns.

### v2.4 — Auto-sizing console
- The console window now auto-sizes to the largest size that fits the current screen and console font (capped at 68×40) so the 66-char border always fits on a single line.
- The size is re-applied after every screen so the window snaps back if dragged mid-session, and the applied size is logged on each screen.

### v2.3 — Chris Titus Tech WinUtil (option 15)
- Step-by-step setup: creates `Documents\PowerShell`, downloads `winutil.ps1` (pinned 26.08.04 or latest), execution-policy check, `winget install --id ChrisTitusTech.winutil`, and launch via `irm christitus.com/win | iex`.

### v2.2 — Connectivity & Devices
- Added "DNS Flush" (option 5) under CONNECTIVITY.
- Added "Graphics Driver Reset" (option 9) under DEVICES using `pnputil /restart-device` on each active display adapter.
- Menu renumbered sequentially to 1–14 + Exit.

### v2.1.1 — Elevation fix
- Fixed critical elevation bug: when already running as Administrator the script fell through into the "Elevation cancelled" block instead of showing the menu, so the menu was never reachable. Added `goto MENU` after the elevation check and moved the "Started" log line so it actually runs.

### v2.1 — Cleanup & reorder
- Removed the Essential Tweaks menu and all tweak routines.
- Menu renumbered sequentially (1–12 + Exit); MEDIA section moved to the top of the menu.
- Code sections physically reordered to match the menu; friendly exit message if the UAC elevation prompt is cancelled.

## Publishing

See [PUBLISHING.md](PUBLISHING.md) for step-by-step instructions to create the GitHub repo, push (HTTPS or SSH), tag, and publish the release.

## Releasing a new version

Follow this checklist for every new version (e.g. `v2.5.0`):

1. **Bump the version** in `WinUtilKLENN.cmd` — in all three places:
   - the header comment: `rem  WINUTILKLENN   (vX.Y.Z)`
   - the menu badge: `[ vX.Y.Z ]`
   - a new entry at the **top** of the script's CHANGELOG (newest first)
2. **Update `RELEASE_NOTES.md`** — new title and "What's new" section.
3. **Mirror the changelog** in this README's [Changelog](#changelog) section.
4. **Commit and push** the changes — CI runs the 7 sanity checks automatically (see [CONTRIBUTING.md](CONTRIBUTING.md) for the manual test checklist).
5. **Tag and push the release:**
   ```bash
   git tag -a vX.Y.Z -m "WinUtilKLENN vX.Y.Z"
   git push origin vX.Y.Z --tags
   ```
6. **Done — the release is created automatically** by the *Auto release* workflow, using `RELEASE_NOTES.md` as the body. Verify it at https://github.com/sanguirIS/WinUtilKLENN/releases

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the development setup, testing checklist, and code style conventions.

## License

WinUtilKLENN is released under the **GNU General Public License v3.0** (GPL-3.0) — see [LICENSE](LICENSE).

## Author

[sanguirIS](https://github.com/sanguirIS)

---

*WinUtilKLENN is an independent project and is not affiliated with, endorsed by, or sponsored by Microsoft, Chris Titus Tech, or CT Tech Group LLC.*
