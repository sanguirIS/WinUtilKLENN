# WinUtilKLENN v2.7.1

Diagnostics and guided repair tools for Windows 10 / 11 — a single-file batch
utility, no installation required.

## What's new in v2.7.1

- **Improved version comparison**: Fixed update check to properly handle all version number formats
- **Better npm tool error handling**: Added comprehensive logging for Node.js and npm package installations
- **Enhanced GitHub API compatibility**: Updated user-agent string for more reliable update checks
- **Robust cancellation handling**: Better user experience when cancelling installations

## What's new in v2.7.0

- **winget Upgrade** (16): lists all outdated winget apps and upgrades them in
  one go, with a FIXED / NOT FIXED verdict and a pending-reboot check.
- **yoinks** (17): download videos from YouTube, X, Instagram, TikTok and
  1,800+ other sites straight from the terminal.
- **ghgrab** (18): browse and download files, folders or release assets from
  any GitHub repo — no cloning needed.
- **Freebuff - AI Agent** (19): launches the free AI coding agent CLI from
  freebuff.com.
- **Auto-installing npm tools:** options 17–19 check whether their npm tool is
  installed; if not, they ask **Y/N**, install it with `npm install -g`, and
  launch it directly. If npm / Node.js is missing, the script offers to install
  Node.js LTS via winget first.
- Menu renumbered sequentially to 1–24 + Exit.

## What's new in v2.6.0

- **Check for Updates**: compares the installed version with the latest GitHub
  release (semantic version comparison) and offers to open the release page.
- **MAINTENANCE section**: Disk Cleanup (12), Restore Point (13), Battery
  Report (14) and Restart / Shutdown (15).
- **Clear verdicts**: every repair option ends with a `[ FIXED ]` / `[ NOT
  FIXED ]` verdict and an explicit restart hint.
- The version now lives in one `VERSION` variable that drives the menu badge
  and the update check.
- `WINUTIL_TEST=1` test mode that skips the UAC prompt for smoke tests.

## What it does

24 guided menu options: Audio · Video Playback · Windows Media Player · Network &
Internet · DNS Flush · Bluetooth · Printer · Camera · Graphics Driver Reset ·
Windows Update · BITS · Disk Cleanup · Restore Point · Battery Report · Restart /
Shutdown · winget Upgrade · Yoinks · ghgrab · Freebuff · Program Compatibility ·
Complete Diagnostics · System Summary · Check for Updates · Chris Titus Tech
WinUtil integration.

## Run

```bat
WinUtilKLENN.cmd
```

Run as Administrator (the script self-elevates via UAC).
Logs to `%ProgramData%\WinUtilKLENN\WinUtilKLENN.log`.

## License

GPL-3.0 — see [LICENSE](LICENSE).
Third-party licenses (WinUtil, PowerShell): [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md).

---

*By [sanguirIS](https://github.com/sanguirIS)*