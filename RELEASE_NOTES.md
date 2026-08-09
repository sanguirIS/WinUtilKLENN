# WinUtilKLENN v2.4.2

Diagnostics and guided repair tools for Windows 10 / 11 — a single-file batch
utility, no installation required.

## What's new in v2.4.2

- **Taller auto-fit window** — the window height cap is raised from 40 to 50
  rows, so the console fills more of a tall screen. The width cap stays at 68
  columns (the 66-char menu border still never wraps) and the 9000-row buffer
  is unchanged.

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
