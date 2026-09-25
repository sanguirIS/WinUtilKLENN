# Contributing to WinUtilKLENN

Thanks for helping out! This project is a single-file Windows batch utility. There is no build step, no dependencies, and no tests to run in the traditional sense — but there are important conventions that keep the script reliable, and a testing checklist that matters because this tool changes real system settings.

By contributing, you agree that your contributions are licensed under the **GPL-3.0** (see [LICENSE](LICENSE)).

---

## Project layout

```
WinUtilKLENN.cmd        The entire tool (single file)
README.md               Overview, features, usage, third-party licenses
THIRD_PARTY_LICENSES.md Full license texts of integrated tools
LICENSE                 GPL-3.0
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
   - The window auto-fits the screen and the **box stays inside the window** (no border wrap).
   - Prose word-wraps inside the box. Drag the window narrower and open another screen: the box and the text reflow.
   - Dracula colours show (pink title, cyan accents, green success, red failure). Background is `#282A36` in Windows Terminal.
   - The warranty notice appears at the bottom of the menu.
   - The menu shows options **1-25** plus **0** (25 is Security Check).
2. Press **Enter** with no input. The menu should simply redraw.
3. Enter an invalid number. You should get the "Invalid selection" message, not a crash. The echoed value is digits only.
4. Enter **0**. The END screen shows the warranty notice and the process exits.

`set WINUTIL_TEST=1` skips the UAC prompt and the one-second boot pause. It does not skip repairs if you confirm them.

### Per-option test

- **Read-only options (2, 3, 20-23)** only print information. Safe to run.
- **Repair options (1, 4-13, 15, 16, 24, 25)** ask **Y/N** before changing anything. Press **N** first to verify the prompts and navigation; press **Y** only when you are ready to let it act.
- **Options 17-19 (yoinks, ghgrab, freebuff)** are npm tools. On first use they ask **Y/N** before installing the package (and Node.js via winget if npm is missing), then launch the tool. Testing them needs Node.js and an internet connection.
- **Option 14 (Battery Report)** writes an HTML report to the log folder but changes no system settings.
- **Option 15 (Restart / Shutdown)** really does restart or shut down the PC. Answer carefully. It schedules a 30-second delay you can cancel with `shutdown /a`.
- **Option 25 (Security Check)** can start a Defender quick scan if you answer **Y**.
- After a repair, confirm the **FIXED / NOT FIXED** verdict (`:VERDICT`) and the restart hint (`:RESTARTNOTE`) match what actually happened. A non-zero winget exit must not say FIXED.
- After any repair, check the log:

  ```bat
  type "%ProgramData%\WinUtilKLENN\WinUtilKLENN.log"
  ```

  You should see a timestamped entry for the action and a `Window WxH box ... theme Dracula` line when the size changes.

### Checking the layout

`:FIT` runs on startup and on every screen (`:HEADER`, the menu, and the exit screen). It reads `mode con`, with a PowerShell fallback when the words Columns/Lines are translated.

- Comfortable window: about **72-104** columns and up to **50** rows.
- Box width follows the window, capped at **120**, and never wider than the window.
- Buffer height stays at **2000** so long diagnostics can be scrolled.
- Below 60 columns or above 150, the font is adjusted once so text stays usable.

## Code style

### 1. Keep the source pure ASCII

**cmd.exe misparses multi-byte characters stored in the file.** Do **not** paste Unicode box-drawing characters into `echo` lines. Glyphs are generated at runtime by `:GLYPHS` and stored in `%SYM_*%` / `%BOX_*%`. If the horizontal glyph is not a single character, the box falls back to ASCII `+`, `-`, and `:`.

Do not use `echo(`. The CI parenthesis counter treats `(` as a block opener. Use `echo.` for a blank line.

### 2. Use the ANSI colour variables

Colours are defined once at the top. The names used in screens are `%R%`, `%RED%`, `%GREEN%`, `%CYAN%`, `%ORG%`, `%YLW%`, `%PINK%`, `%PUR%`, `%COM%`, `%FG%`, `%BOLD%`, `%DIM%`. `%CYAN%` and `%GREEN%` are aliases of the Dracula cyan and green sequences. Never hardcode escape sequences. `%R%` resets and reapplies the Dracula foreground and background.

### 3. Wrap prose; do not hard-code a 66-column line

The window is not capped at 68 columns. Put sentences in `MSG` and `call :SAY` (or `call :SAY "text"`). `:SAY` word-wraps to the live inner width and draws both side borders. Keep `goto` and labels out of parenthesised blocks. PowerShell tables should end with `Format-Table -Wrap | Out-String -Width $env:WUK_W`.

`:ASK` ends with `choice`. The next line must test `errorlevel`. Do not `call` anything between them.

### 4. Structure

- Section banners use the `rem ====...====` style. Keep the header comment's `WINUTILKLENN vX.Y.Z` in sync with `VERSION`.
- Use the helpers (`:HEADER`, `:SAY`, `:FIT`, `:SVCSTATUS`, `:CHECKSVC`, `:VERDICT`, `:RESTARTNOTE`, `:ASK`, `:WORK`) instead of duplicating logic.
- Prefix subroutine-local variables and `set "VAR="` before use.
- Never put `goto` or labels inside parenthesised blocks.

### 5. Locale safety

Windows is locale-sensitive. Avoid parsing English command output directly. Prefer the existing patterns (`sc query` with `findstr /C:"STATE"` and `: 4  ` matches, PowerShell `-ErrorAction SilentlyContinue`).

### 6. Log every action

Every repair must write to the log in the existing style:

```bat
echo [%date% %time%] Your action here >> "%LOGFILE%"
```

### 7. Adding a new menu option

1. Add the option line to `:MENU`. Keep numbers stable if you can; 25 is Security, 24 is WinUtil.
2. Add a `set /p` handler and a `goto` target. Run input through `:SANITIZE` if it is a menu number.
3. Update the version (see below) and the README features table.

### 8. Versioning and changelog

- Bump the version in **four** places:
  1. the header comment `rem  WinUtilKLENN vX.Y.Z`,
  2. the `set "VERSION=vX.Y.Z"` variable (menu badge and Check for Updates),
  3. a new entry at the **top** of the script CHANGELOG comment (newest first),
  4. the docs: README Changelog, and `RELEASE_NOTES.md`.
- Do not rewrite a published GitHub release. Source ahead of the latest tag is a new version. The Releases page currently has **6** releases; **v2.8.0** is Latest.
- Keep the license **GPL-3.0**.

Embedded PowerShell must be a single `-Command "..."` with **no** double quote inside the string. CI strips `%VAR%` and parses the result. A bare `|` inside that string is fine for PowerShell, but a bare `|` in an `echo` line is a cmd pipe. Do not set an ASCII bar glyph to `|`.

## Commit messages

Short, imperative, prefixed by area when it helps:

```text
Add option 16: Storage Sense diagnostics
Fix elevation fall-through when already admin
docs: document the :FIT routine in README
```

## Definition of done

- [ ] Script still runs. Box fits. Text wraps. Menu renders options 0-25.
- [ ] Dracula colours still come from the variables, not hardcoded sequences.
- [ ] New or changed options tested with **N** (navigation) and, where safe, **Y**.
- [ ] Log lines written correctly.
- [ ] Version bumped and changelog updated.
- [ ] README updated if the menu, behaviour, or dependencies changed.
- [ ] File kept ASCII and CRLF (`.gitattributes` does this on checkout).
- [ ] Parentheses balance, and every `goto` / `call :` target exists.

## Questions?

Open an issue or PR on the repository — the author is [sanguirIS](https://github.com/sanguirIS).
