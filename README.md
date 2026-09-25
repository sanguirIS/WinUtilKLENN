# WinUtilKLENN

[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-0078D6.svg)](README.md)
[![GitHub: sanguirIS](https://img.shields.io/badge/GitHub-sanguirIS-181717?logo=github&logoColor=white)](https://github.com/sanguirIS)
[![CI](https://github.com/sanguirIS/WinUtilKLENN/actions/workflows/sanity-check.yml/badge.svg)](https://github.com/sanguirIS/WinUtilKLENN/actions/workflows/sanity-check.yml)
[![Latest release](https://img.shields.io/github/v/release/sanguirIS/WinUtilKLENN?label=Latest)](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.8.0)

**[README](https://github.com/sanguirIS/WinUtilKLENN#)** · **[Contributing](CONTRIBUTING.md)** · **[GPL-3.0 license](LICENSE)** · **[Releases](https://github.com/sanguirIS/WinUtilKLENN/releases)** (6) · **[v2.8.0 Latest](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.8.0)**

**Diagnostics and guided repair tools for Windows 10 / 11.** Dracula theme, auto-fitting text, and word-wrapped boxes.

> **Repository:** https://github.com/sanguirIS/WinUtilKLENN
>
> **Current source:** v2.9.0 (this tree). **Latest published release:** [v2.8.0](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.8.0).

WinUtilKLENN is a single-file batch utility with a Dracula-colored menu of 25 diagnostic, repair, and maintenance actions: audio, video, network, printers, cameras, Windows Update, disk cleanup, a security check, and more. It also launches npm extras (video downloads, GitHub downloads, an AI coding agent) and can set up the [Chris Titus Tech WinUtil](https://github.com/ChrisTitusTech/winutil) toolbox.

- **Single file** - no installation; the built-in options only need what Windows ships with (options 17-19 auto-install their npm tools on first use).
- **Runs as Administrator** - self-elevates via UAC. Paths with spaces or apostrophes survive the relaunch, and the working folder is kept.
- **Everything is logged** - every action is recorded to `%ProgramData%\WinUtilKLENN\WinUtilKLENN.log` (rotated at 512 KB).
- **Dracula theme** - background `#282A36`, foreground `#F8F8F2`, plus pink, purple, cyan, green, red, orange, and yellow from the [Dracula palette](https://draculatheme.com/). Not affiliated with the Dracula Theme project.
- **Responsive boxes** - every screen is framed. The box follows the console width (up to 120 columns). Prose word-wraps inside the box. Tables wrap to the same width.
- **Automated text size** - on startup the font and window fit the screen (about 72-104 columns and up to 50 rows). Drag the window and the next screen reflows. A very narrow or very wide window refits the font automatically.
- **Scrollback kept** - the visible window fits the screen; the buffer stays at 2,000 rows so long diagnostics are not thrown away.

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
| 12 | Maintenance | Disk Cleanup | Deletes temp files and empties the Recycle Bin |
| 13 | Maintenance | Restore Point | Enables System Protection and creates a restore point |
| 14 | Maintenance | Battery Report | Battery status plus a full `powercfg` HTML report |
| 15 | Maintenance | Restart / Shutdown | Schedules a restart or shutdown with a 30-second delay |
| 16 | Maintenance | winget Upgrade | Lists outdated winget apps; upgrade all, or select Ids/Names |
| 17 | Other / Tools | Yoinks - Video Downloader | npm tool - downloads videos from 1,800+ sites |
| 18 | Other / Tools | ghgrab - GitHub Downloader | npm tool - grabs files/folders/release assets from GitHub |
| 19 | Other / Tools | Freebuff - AI Agent | npm tool - free AI coding agent (freebuff.com) |
| 20 | Other / Tools | Program Compatibility | Inspects an `.exe` file's version info |
| 21 | Other / Tools | Run ALL Diagnostics | Runs the diagnostic checks from the media, network, device and update options at once |
| 22 | Other / Tools | System Summary | OS, RAM, disk, PowerShell version |
| 23 | Other / Tools | Check for Updates | Compares the installed version with the latest GitHub release |
| 24 | Other / Tools | Chris Titus Tech WinUtil | Guided setup of the WinUtil toolbox (see below) |
| 25 | Security | Security Check | Defender status, firewall profiles, UAC level, optional quick scan |
| 0 | — | Exit | Closes the tool |

## Requirements

- Windows 10 or Windows 11
- PowerShell (ships with Windows; 5.1+ recommended)
- Administrator rights for most repair actions (the script self-elevates; you can also right-click → **Run as administrator**)

## Usage

1. Right-click `WinUtilKLENN.cmd` → **Run as administrator** (or double-click and accept the UAC prompt).
2. Type the number of the option you want and press **Enter**.
3. Follow the on-screen prompts. Most options ask **Y/N** before making any changes.

### Using Chris Titus Tech WinUtil (option 24)

Option 24 walks you through, step by step:

1. Creates `Documents\PowerShell` if it does not exist.
2. Downloads `winutil.ps1` (pinned release **26.08.04** or latest) into that folder.
3. Checks and optionally sets the PowerShell execution policy (Process scope).
4. Tries `winget install --id ChrisTitusTech.winutil` if winget is available.
5. Launches WinUtil with `irm https://christitus.com/win | iex`.

## How it works

- **Self-elevation** - if not running as Administrator, the script restarts itself elevated through UAC, passing the script path and the current folder. A path with spaces or an apostrophe does not break, and the tool does not land in `System32`. If you cancel the prompt, no changes are made.
- **Logging** - every repair action, plus the applied console size, is appended to `%ProgramData%\WinUtilKLENN\WinUtilKLENN.log`. The log rotates at 512 KB.
- **Dracula theme** - truecolor ANSI on every UI line, a remapped 16-color console palette, and terminal background/foreground sequences so both the classic console and Windows Terminal pick up the palette.
- **Responsive layout** - `:FIT` runs on every screen. It reads the live console size, rebuilds the box, and word-wraps prose with `:SAY`. PowerShell tables use `Format-Table -Wrap` at the same inner width. Startup chooses a readable font and a window that fits the screen. If you drag the window below 60 or past 150 columns, the font is adjusted once so text stays usable.
- **Version check** - the version lives in one `VERSION` variable (shown in the menu). Option 23 compares it with the latest GitHub release (pre-release suffixes are ignored) and offers to open the release page when an update exists.


## Third-party tools & websites (and their licenses)

This tool invokes or integrates the following third-party resources. Each belongs to its respective owner and is governed by its own terms.

| Resource | Website / Source | License | Used for |
|---|---|---|---|
| Chris Titus Tech WinUtil | https://github.com/ChrisTitusTech/winutil · https://christitus.com/win | [MIT](https://github.com/ChrisTitusTech/winutil/blob/main/LICENSE) (© 2022 CT Tech Group LLC) | Option 24 — optional toolbox setup |
| Node.js (npm) | https://nodejs.org | [MIT](https://github.com/nodejs/node/blob/main/LICENSE) | Runtime for options 17–19 (auto-installed via winget if missing) |
| yoinks | https://www.npmjs.com/package/yoinks | [MIT](https://www.npmjs.com/package/yoinks) | Option 17 — video downloads |
| ghgrab | https://www.npmjs.com/package/@ghgrab/ghgrab | See npm package page | Option 18 — GitHub file/release downloads |
| freebuff | https://www.npmjs.com/package/freebuff | See npm package page | Option 19 — AI coding agent |
| Microsoft Windows built-in tools (`DISM`, `SFC`, `netsh`, `ipconfig`, `pnputil`, `sc`, `winget`, `powercfg`, `shutdown`) | https://learn.microsoft.com | Subject to [Microsoft Software License Terms](https://www.microsoft.com/en-us/legal/terms-of-use) | Diagnostics and repair actions (options 1–16, 20–24) |
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

### v2.9.0 — Dracula theme, responsive text, bug fixes

Current source version. Not yet a GitHub release; the latest published tag is still [v2.8.0](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.8.0).

- **Dracula theme** on every screen: palette, truecolor, and terminal background.
- **Responsive boxes and word wrap.** Borders follow the console. Prose wraps on spaces inside the box. Tables wrap to the same width. The font and window auto-fit the screen, and extreme resizes refit the font.
- **Scrollback restored** (2,000 rows) so `ipconfig`, DISM, and winget output can be scrolled.
- **Security check** stays option 25 (Defender, firewall, UAC, optional quick scan).
- **Selective winget upgrades** (option 16): all packages, or one or more Ids/Names, with a per-package result and a FIXED / NOT FIXED verdict.
- **Elevation** uses the script path from the environment, so spaces and apostrophes survive, and the working directory is preserved.
- **winget negative exit codes** are no longer treated as success. Node.js install success is verified by finding `npm`, then the requested package is installed.
- **PATH refresh** reads expanded values, not raw `REG_EXPAND_SZ`.
- **Disk cleanup** passes temp paths through `$env:TEMP` / `$env:SystemRoot`.
- **Windows Update cache reset** waits for services to stop, then checks that the renames actually happened, and always starts the services again.
- **Update check** uses this script's version and ignores pre-release tag suffixes.
- **yoinks** checks for Windows Terminal before option 2, and option 1 waits until the command window closes.
- **Invalid menu input** is reduced to digits and displayed, never executed.
- **Accent colours** `CYAN` and `GREEN` are defined, so status arrows and success text use the Dracula palette.
- **Printer repair** stops the spooler, deletes stuck jobs in the spool folder, then starts the spooler again. Locked files are reported as NOT FIXED instead of success.
- **winget --all** reports NOT FIXED when winget returns a non-zero exit code.
- The box never grows wider than the console window.
- License remains **GPL-3.0**.

### v2.8.0 — Selective winget upgrades and fixes

Published release: [v2.8.0](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.8.0) (latest on the Releases page).

- Option 16 can upgrade all winget packages or a typed list of Ids/Names.
- winget failure codes, PATH refresh, disk-cleanup apostrophes, the update-check user-agent, and the yoinks Windows Terminal check were fixed in that tag.

### v2.7.1 — Bug fixes and improvements
- **More robust update check:** version comparison now handles all version-number formats, and the GitHub API user-agent was updated for reliable checks.
- **Better npm tool handling:** comprehensive logging for Node.js / npm installs, and a friendlier experience when an installation is cancelled.

### v2.7.0 — npm tools & new menu items
- New **winget Upgrade** (16): lists outdated winget apps and upgrades them, with a FIXED / NOT FIXED verdict and a pending-reboot check.
- New **yoinks** (17): downloads videos from YouTube, X, Instagram, TikTok and 1,800+ other sites.
- New **ghgrab** (18): browse and download files, folders or release assets from GitHub repos without cloning.
- New **Freebuff - AI Agent** (19): launches the free AI coding agent CLI from freebuff.com.
- **Auto-installing npm tools:** options 17–19 check whether their npm tool is installed; if not, they ask **Y/N**, install it (`npm install -g`), and launch it directly. If npm / Node.js is missing, the script offers to install Node.js LTS via winget first.
- Menu renumbered sequentially to 1–24 + Exit.

### v2.6.0 — Version and maintenance features
- New **Check for Updates** option (19): compares the installed version with the latest GitHub release (semantic version comparison) and offers to open the release page.
- New **MAINTENANCE** section: **Disk Cleanup** (12) deletes temp files and empties the Recycle Bin, **Restore Point** (13) enables System Protection and creates a restore point, **Battery Report** (14) shows battery status and generates a `powercfg` HTML report, **Restart / Shutdown** (15) schedules a restart or shutdown with a 30-second delay.
- The version is now stored in one `VERSION` variable that drives the menu badge and the update check.
- **Clear verdicts:** every repair option now ends with a `[ FIXED ]` / `[ NOT FIXED ]` verdict and an explicit restart hint, so you always know whether the issue was resolved and whether a reboot is needed.
- Added a `WINUTIL_TEST=1` test mode that skips the UAC prompt for smoke tests.
- Small wording fixes in on-screen messages and docs.

### v2.5.0 — Polish pass
- Option 11 label shortened to "BITS" to match its screen header and section title; log-path line spacing unified across screens. No new menu options.

### v2.4.3 — Buffer matches the window
- Screen buffer height is now 50 rows (same as the window height) instead of 9000, so scrollback mirrors the visible window exactly.

### v2.4.2 — Resize tuning
- Window height cap raised from 40 to 50 rows so the window auto-fits more of a tall screen. Width cap stays at 68 columns; the 9000-row buffer is unchanged.

### v2.4.1 — Licensing and polish fixes
- Added the GPL-3.0 header and the warranty notice (menu and exit screens), as required by the license.
- Startup resize now runs after the log directory exists, so the applied window size is logged on first launch too.
- Screen headers shortened (`RULE_SMALL` 40 → 36 chars) so long titles fit the 68-column window without wrapping.
- Option 15: WinUtil download labels shortened to prevent the long URLs from wrapping at 68 columns.

### v2.4 — Auto-sizing console
- The console window now auto-sizes to the largest size that fits the current screen and console font (capped at 68×40) so the 66-char border always fits on a single line.
- The size is re-applied after every screen so the window snaps back if dragged mid-session, and the applied size is logged on each screen.

### v2.3 — Chris Titus Tech WinUtil (option 15 then; option 24 now)
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

1. **Bump the version** in `WinUtilKLENN.cmd`:
   - the header comment: `rem  WINUTILKLENN   (vX.Y.Z)`
   - the `set "VERSION=vX.Y.Z"` variable (drives the menu badge and Check for Updates)
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

Contributions are licensed under **GPL-3.0**. See [CONTRIBUTING.md](CONTRIBUTING.md) for the development setup, the testing checklist (border fit, word wrap, Dracula colors, options 0-25), and the code style rules.

- Guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Repository: [https://github.com/sanguirIS/WinUtilKLENN#](https://github.com/sanguirIS/WinUtilKLENN#)

## License

WinUtilKLENN is released under the **GNU General Public License v3.0** (GPL-3.0).

- Full text: [LICENSE](LICENSE)
- GPL-3.0: [https://www.gnu.org/licenses/gpl-3.0.html](https://www.gnu.org/licenses/gpl-3.0.html)
- Third-party licenses: [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md)

There is no warranty. The menu and the exit screen say so, as the GPL requires for an interactive program.

## Releases

Published GitHub releases: **6**. Latest published tag: **[v2.8.0](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.8.0)**.

All releases: [https://github.com/sanguirIS/WinUtilKLENN/releases](https://github.com/sanguirIS/WinUtilKLENN/releases)

| Release | Published | Notes |
|---|---|---|
| [v2.8.0](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.8.0) **Latest** | 2026-08-18 | Selective winget upgrades and bug fixes |
| [v2.7.1](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.7.1) | 2026-08-14 | Update-check and npm install fixes |
| [v2.5.0](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.5.0) | 2026-08-09 | Polish pass (BITS label, log spacing) |
| [v2.4.3](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.4.3) | 2026-08-09 | Buffer height matched the window |
| [v2.4.2](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.4.2) | 2026-08-09 | Window height cap raised to 50 rows |
| [v2.4.1](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.4.1) | 2026-08-09 | GPL header, warranty notice, resize fixes |

v2.6.0 and v2.7.0 were source milestones and were not published as GitHub releases. The source tree may be ahead of v2.8.0; see the [Changelog](#changelog).

## Author

[sanguirIS](https://github.com/sanguirIS)

---

*WinUtilKLENN is an independent project and is not affiliated with, endorsed by, or sponsored by Microsoft, Chris Titus Tech, or CT Tech Group LLC.*
