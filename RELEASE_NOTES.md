# WinUtilKLENN v2.9.0

Diagnostics and guided repair tools for Windows 10 / 11. Single-file batch
utility, no installation required. Licensed under GPL-3.0.

This file describes the current source. The latest **published** GitHub
release is still [v2.8.0](https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.8.0).
All six published releases: https://github.com/sanguirIS/WinUtilKLENN/releases

## What's new in v2.9.0

- **Dracula theme** on every screen: truecolor, a remapped console palette,
  and terminal background/foreground sequences.
- **Responsive boxes and word wrap.** Borders follow the console (up to 120
  columns, never wider than the window). Prose wraps inside the box. Tables
  wrap to the same width.
- **Automated text size.** Startup picks a readable font and a window that
  fits the screen (about 72-104 columns, up to 50 rows). A very narrow or
  very wide window refits the font. Scrollback stays at 2,000 rows.
- **Security check** remains option 25 (Defender, firewall, UAC, optional
  quick scan).
- **Selective winget upgrades** (option 16): all packages, or chosen
  Ids/Names. A failed `winget upgrade --all` is NOT FIXED.
- Elevation survives spaces and apostrophes and keeps the working folder.
- winget negative exit codes are not treated as success. Node.js install
  success is checked by finding `npm`, then the requested package installs.
- PATH refresh reads expanded values. Disk cleanup uses `$env:TEMP`.
- Windows Update cache reset waits for services to stop, checks the renames,
  and always starts the services again.
- Update check uses this script's version and ignores pre-release suffixes.
- yoinks checks for Windows Terminal before option 2. Option 1 waits until
  the command window closes.
- Printer repair clears stuck jobs in the spool folder after the spooler
  stops, then starts the spooler again.
- Invalid menu input is reduced to digits and shown, never executed.
- License remains **GPL-3.0**.

## What's new in v2.8.0

Published release: https://github.com/sanguirIS/WinUtilKLENN/releases/tag/v2.8.0

- Option 16 can upgrade all winget packages or a typed list of Ids/Names.
- Fixes for winget failure codes, PATH refresh, disk-cleanup apostrophes,
  the update-check user-agent, and the yoinks Windows Terminal check.

## What's new in v2.7.1

- Update check handles more version-number formats.
- Better logging when a Node.js or npm install is cancelled.
- GitHub API user-agent updated for more reliable update checks.

## Earlier

v2.7.0 added winget upgrade, yoinks, ghgrab, and freebuff. v2.6.0 added the
update check, maintenance options, and FIXED / NOT FIXED verdicts. See
README.md Changelog for the full history.
