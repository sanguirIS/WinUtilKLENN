# WinUtilKLENN v2.4.1

Diagnostics and guided repair tools for Windows 10 / 11 — a single-file batch utility, no installation required.

## What's new in v2.4.1

- **GPL-3.0 licensing** — license header added to the script, plus the warranty notice on the menu and exit screens, as the license requires.
- **Fixed window-size logging** — the startup resize now runs after the log directory exists, so the applied size is recorded on first launch too.
- **Headers fit the window** — screen title rules shortened (`RULE_SMALL` 40 → 36) so long titles never wrap at the 68-column cap.
- **Cleaner option 15** — WinUtil download labels shortened so the long URLs no longer wrap.

## Also in v2.4

- **Auto-sizing console** — the window grows to the largest size that fits your screen and console font (capped at 68×40), re-applies after every screen so it snaps back if dragged, and logs the applied size on each screen.

## What it does

15 guided menu options: Audio · Video Playback · Windows Media Player · Network & Internet · DNS Flush · Bluetooth · Printer · Camera · Graphics Driver Reset · Windows Update · BITS · Program Compatibility · Complete Diagnostics · System Summary · Chris Titus Tech WinUtil integration.

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
