# WinUtilKLENN v2.8.0

Diagnostics and guided repair tools for Windows 10 / 11 — a single-file batch
utility, no installation required.

## What's new in v2.8.0

- **Selective winget upgrades (option 16):** after `winget upgrade` lists the available
  updates you now choose **[1] ALL**, **[2] SELECT** (type one or more package Ids or
  Names, space/comma separated), or **[0] Cancel**. Selected packages are upgraded one
  by one with a per-package ✓/✗ result, an automatic Id→Name retry, a failure count,
  the remaining-updates list, a FIXED / NOT FIXED verdict, and a pending-reboot check.
- **Fixed: winget failure detection** — winget returns large *negative* exit codes on
  failure, so `if errorlevel 1` never caught them. The Node.js install check now
  verifies npm directly, and the WinUtil install check uses exit codes instead of
  matching English winget output (locale-independent).
- **Fixed: PATH refresh** — `:REFRESHPATH` could corrupt `PATH` because `reg query`
  returns raw `REG_EXPAND_SZ` text with unexpanded `%SystemRoot%` references. `PATH`
  is now read fully expanded via PowerShell.
- **Fixed: Disk Cleanup** broke for user names containing an apostrophe (`TEMP` is now
  passed to PowerShell via `$env:TEMP`).
- **Fixed: update check** — the GitHub API user-agent now uses the real script version
  (was hardcoded `2.7.1`), and pre-release tags (e.g. `v2.8.0-beta`) no longer break
  the version comparison.
- **Fixed: yoinks option 2** now checks that Windows Terminal (`wt.exe`) is installed
  before launching it.
- **Relicensed from GPL-3.0 to the MIT License** — see [LICENSE](LICENSE).

## What it does

24 guided menu options: Audio · Video Playback · Windows Media Player · Network &
Internet · DNS Flush · Bluetooth · Printer · Camera · Graphics Driver Reset ·
Windows Update · BITS · Disk Cleanup · Restore Point · Battery Report · Restart /
Shutdown · winget Upgrade (all or selected packages) · Yoinks · ghgrab · Freebuff ·
Program Compatibility · Complete Diagnostics · System Summary · Check for Updates ·
Chris Titus Tech WinUtil integration.

## Run

```bat
WinUtilKLENN.cmd
```

Run as Administrator (the script self-elevates via UAC).
Logs to `%ProgramData%\WinUtilKLENN\WinUtilKLENN.log`.

## License

MIT — see [LICENSE](LICENSE).
Third-party licenses (WinUtil, PowerShell): [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md).

---

*By [sanguirIS](https://github.com/sanguirIS)*
