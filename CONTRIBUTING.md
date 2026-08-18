# Contributing to WinUtilKLENN

Thanks for helping out! This project is a single-file Windows batch utility. There is no build step, no dependencies, and no tests to run in the traditional sense — but there are important conventions that keep the script reliable, and a testing checklist that matters because this tool changes real system settings.

By contributing, you agree that your contributions are licensed under the **MIT License** (see [LICENSE](LICENSE)).

---

## Project layout

```
WinUtilKLENN.cmd        The entire tool (single file)
README.md               Overview, features, usage, third-party licenses
THIRD_PARTY_LICENSES.md Full license texts of integrated tools
LICENSE                 MIT
CONTRIBUTING.md         This file
```

## Development setup

- **Windows 10 or 11** — the script only runs on Windows.
- **A text editor** that handles CRLF and pure ASCII. The repo enforces:
  - `*.cmd` → **CRLF** line endings (see `.gitattributes`). LF-only batch files can break `goto`/labels in cmd.exe.
  - Source must stay **pure ASCII** — see the note below about glyphs.
- **No build tools.** To "build", you run the script:

  ```bat
  WinUtilKLENN.cmd
  ```

  Or, to run a quick smoke test without the UAC prompt (no system changes
  are made), set the test-mode flag first:

  ```bat
  set WINUTIL_TEST=1
  cmd /c "WinUtilKLENN.cmd"
  ```

## Testing

Several options change real system state (services, drivers, the Windows Update cache, the network stack). **Always test in a VM or a machine you can afford to repair.**

### Quick smoke test (every change)

1. Run the script and confirm:
   - The window auto-sizes and the **66-char border fits on one line** (no wrap).
   - The warranty notice appears at the bottom of the menu.
   - The menu shows all options **1–24** plus **0**.
2. Press **Enter** with no input — the menu should simply redraw.
3. Enter an invalid number — you should get the "Invalid selection" message, not a crash.
4. Enter **0** — the END screen shows and the process exits.

### Per-option test

- **Read-only options (2, 3, 20–23)** only print information — safe to run.
- **Repair options (1, 4–13, 15, 24)** ask **Y/N** before changing anything. Press **N** first to verify the prompts and navigation; press **Y** only when you are ready to let it act.
- **Option 16 (winget Upgrade)** asks **1 / 2 / 0** after listing the updates: **1** = upgrade all, **2** = type one or more package Ids/Names (space/comma separated) to upgrade only those, **0** = cancel. Test with **0** and with a harmless Id first (e.g. `Git.Git`); a failed Id is retried as a Name and reported with a ✗ line plus failure counts in the verdict.
- **Options 17–19 (yoinks, ghgrab, freebuff)** are npm tools: on first use they ask **Y/N** before installing the package (and Node.js via winget if npm is missing), then launch the tool. Testing them needs Node.js and an internet connection.
- **Option 14 (Battery Report)** writes an HTML report to the log folder but changes no system settings.
- **Option 15 (Restart / Shutdown)** really does restart or shut down the PC — answer carefully. It schedules a 30-second delay you can cancel with `shutdown /a`.
- After a repair, confirm the **FIXED / NOT FIXED** verdict (`:VERDICT`) and the restart hint (`:RESTARTNOTE`) match what actually happened.
- After any repair, check the log:

  ```bat
  type "%ProgramData%\WinUtilKLENN\WinUtilKLENN.log"
  ```

  You should see a timestamped entry for the action and a `Window size applied: WxH` line per screen.

### Checking the console resize

The `:RESIZE` routine runs on startup and after every screen. Verify it by:

```bat
powershell -NoProfile -Command "$ui=(Get-Host).UI.RawUI; $ui.MaxWindowSize"
```

The window must never exceed `68` columns (hard cap) or the screen maximum, whichever is smaller. The window height auto-fits the screen up to `50` rows, and the buffer height is set to match the window (no scrollback beyond the visible area).

## Code style

### 1. Keep the source pure ASCII

**cmd.exe misparses multi-byte characters stored in the file.** Do **not** paste Unicode box-drawing characters (`─`, `►`, `✓`, `✗`, `●`) into `echo` lines. All glyphs are generated at runtime by the *Icons and rules* block near the top of the script and stored in `%SYM_*%` / `%RULE_*%` variables — use those.

### 2. Use the ANSI colour variables

Colours are defined once at the top (`%R%`, `%RED%`, `%GRN%`, `%CYN%`, `%BOLD%`, `%DIM%`, …). Never hardcode escape sequences; always reset with `%R%` at the end of every line.

### 3. Fit the window: keep lines short

The console is capped at **68 columns**. Keep every echoed line short enough to render without wrapping — aim for **≤ 66 characters** of visible text.

### 4. Structure

- Section banners use the `rem ====...====` style; keep the header comment's `WINUTILKLENN (vX.Y.Z)` in sync.
- Use small `:SUBROUTINE` helpers with `goto :eof` (see `:HEADER`, `:SVCSTATUS`, `:CHECKSVC`, `:RESIZE`, `:VERDICT`, `:RESTARTNOTE`, `:WGUPGRADE`) instead of duplicating logic.
- Prefix subroutine-local variables (e.g. `SVC*`, `GFX_*`, `WINUTIL_*`) and `set "VAR="` before use.
- Never put `goto`/labels inside parenthesised blocks; keep `call :HELPER` calls at the top level of each screen.

### 5. Locale safety

Windows is locale-sensitive. Avoid parsing English command output directly — prefer the existing patterns (`sc query` with `findstr /C:"STATE"` and `: 4  ` matches, PowerShell `-ErrorAction SilentlyContinue`).

### 6. Log every action

Every repair must write to the log in the existing style:

```bat
echo [%date% %time%] Your action here >> "%LOGFILE%"
```

### 7. Adding a new menu option

1. Add the option line to `:MENU` and renumber if needed.
2. Add a `choice` / `set /p` handler and a `goto` target.
3. Update the version (see below) and the README features table.

### 8. Versioning & changelog

- Bump the version in **four** places:
  1. the header comment `rem  WINUTILKLENN   (vX.Y.Z)`,
  2. the `set "VERSION=vX.Y.Z"` variable (it drives the menu badge and the **Check for Updates** option),
  3. a new entry at the **top** of the CHANGELOG (newest first), matching the existing style,
  4. the docs: this README's Changelog section and `RELEASE_NOTES.md`.
- `X` for feature additions that change the menu, `Y` for fixes and internal changes.

## Commit messages

Short, imperative, prefixed by area when it helps:

```text
Add option 16: Storage Sense diagnostics
Fix elevation fall-through when already admin
docs: document the :RESIZE routine in README
```

## Definition of done

- [ ] Script still runs, border fits, menu renders all options.
- [ ] New/changed options tested with **N** (navigation) and, where safe, **Y**.
- [ ] Log lines written correctly.
- [ ] Version bumped and changelog updated.
- [ ] README updated if the menu, behaviour, or dependencies changed.
- [ ] File kept ASCII, CRLF (`.gitattributes` does this automatically on checkout).

## Questions?

Open an issue or PR on the repository — the author is [sanguirIS](https://github.com/sanguirIS).
