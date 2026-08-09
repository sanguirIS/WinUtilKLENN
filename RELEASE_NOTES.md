# WinUtilKLENN v2.4.3

Diagnostics and guided repair tools for Windows 10 / 11 — a single-file batch
utility, no installation required.

## What's new in v2.4.3

- **Buffer matches the window** — the screen buffer height is now 50 rows
  (the same as the window height) instead of 9000, so scrollback mirrors the
  visible window exactly. Width stays at 68 columns and the window height cap
  stays at 50 rows.

## What it does

15 guided menu options: Audio · Video Playback · Windows Media Player · Network &
Internet · DNS Flush · Bluetooth · Printer · Camera · Graphics Driver Reset ·
Windows Update · BITS · Program Compatibility · Complete Diagnostics · System
Summary · Chris Titus Tech WinUtil integration.

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
