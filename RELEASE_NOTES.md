# WinUtilKLENN v2.5.0

Diagnostics and guided repair tools for Windows 10 / 11 — a single-file batch
utility, no installation required.

## What's new in v2.5.0

- **Polish pass** — no new menu options in this release:
  - Option 11 label shortened to "BITS" so it matches its screen header and
    the section title.
  - Log-path line spacing unified across screens.
  - Window behaviour unchanged: 68-column cap, 50-row window, buffer matches
    the window (50 rows).

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
