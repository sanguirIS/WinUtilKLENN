# Security Policy

Thank you for taking an interest in the security of **WinUtilKLENN**.
This document describes which versions receive security updates, how to
report a vulnerability, and what to expect after you report one.

WinUtilKLENN is a single-file Windows batch utility (`WinUtilKLENN.cmd`)
that self-elevates to Administrator, runs diagnostic / repair PowerShell
and `winget` commands, and (for options 17–19) can install and launch
third-party npm tools. Please keep that scope in mind when evaluating
security impact.

---

## Supported Versions

Security fixes are shipped in new tagged releases on GitHub. Only the
latest release and the current in-tree source are actively maintained.

| Version line      | Supported with security fixes |
| ----------------- | ----------------------------- |
| `2.9.x` (current source) | :white_check_mark: yes |
| `2.8.x` (latest published release, v2.8.0) | :white_check_mark: yes — fixes land as a new patch release |
| `2.7.x` and older `2.x` | :x: no — please upgrade to the latest release |
| `1.x`             | :x: no                        |

If you are on an older release and a security issue affects it, the fix
will be to upgrade to the newest release; there are no back-ports to
old `2.x` or `1.x` tags.

---

## What is (and is not) in Scope

Security reports are welcome for anything shipped in this repository,
in particular:

- `WinUtilKLENN.cmd` itself: the elevation logic, command construction,
  PowerShell invocations, logging, menu input handling, and update
  check against `api.github.com`.
- CI / release workflows under `.github/workflows/`.
- Documentation and helper scripts (`sanity-check-local.ps1`).

The following are **out of scope** for vulnerability reports against
this repository (please report them to their respective upstreams):

- Windows itself, PowerShell, `winget`, DISM, SFC, Windows Defender,
  and other Microsoft components the script calls.
- Third-party tools the script can invoke or install: Node.js / npm,
  [`yoinks`](https://www.npmjs.com/package/yoinks),
  [`@ghgrab/ghgrab`](https://www.npmjs.com/package/@ghgrab/ghgrab),
  Freebuff, and [Chris Titus Tech WinUtil](https://github.com/ChrisTitusTech/winutil).
  See `THIRD_PARTY_LICENSES.md` for the upstream list.
- Behavior of `irm https://christitus.com/win | iex` used by option 24 —
  that command downloads and runs third-party code at launch time; only
  use it if you trust that source.

Also out of scope:

- Social-engineering attacks that trick a user into running the script
  with malicious intent (the script *requires* Administrator and UAC by
  design; only run it yourself on machines you own or administer).
- Issues that require physical access to the machine.
- Log file disclosure — the log under `%ProgramData%\WinUtilKLENN\` is
  readable by any local user and contains command output; do not put
  secrets into command prompts shown in the menu.

---

## Reporting a Vulnerability

Please report suspected security vulnerabilities **privately** before
any public disclosure. The preferred channel is a GitHub Security
Advisory:

1. Go to https://github.com/sanguirIS/WinUtilKLENN/security
2. Click **"Report a vulnerability"**.
3. Fill in the template with:
   - A description of the issue and its impact.
   - Steps to reproduce (a minimal batch/PowerShell snippet, or a diff
     against `WinUtilKLENN.cmd`, is very helpful).
   - Affected version(s) / tag(s) / commit(s).
   - Your suggested fix, if you have one.

If GitHub Security Advisories do not work for you, you may instead open
a regular GitHub issue at
https://github.com/sanguirIS/WinUtilKLENN/issues and mark it with the
prefix `[SECURITY]` in the title. Please **do not** include exploit
details or proof-of-concept payloads in the public issue — just a
high-level description and a way to reach you; the details will move to
a private channel.

There is no bug bounty program. Credit for valid reports will be given
in the release notes of the fix unless you ask to remain anonymous.

---

## What to Expect

- **Acknowledgement:** you should receive an initial response within
  **7 calendar days**, usually faster.
- **Triage:** you will be told whether the report is accepted as a
  security issue, considered out of scope, or needs more information.
- **Fix:** for accepted issues, a fix is prepared in a private branch
  and shipped in the next patch release. You will be notified when the
  fix is published and given a chance to review it before release if
  you wish.
- **Declined reports:** if a report is declined (out of scope, intended
  behavior, already fixed, etc.), you will receive a clear reason.

After the fix is released, the advisory (if any) will be made public
and the issue can be discussed openly.

---

## Security-relevant Design Notes

A few things about how WinUtilKLENN is written, to help you review it:

- **Runs as Administrator.** The script self-elevates through UAC and
  expects admin privileges; most repair actions (service restarts,
  DISM/SFC, spooler cleanup) genuinely need them. The script only
  operates on the local machine.
- **Menu input is sanitized.** Non-digit characters are stripped from
  menu input before dispatch; invalid selections are shown and *not*
  executed.
- **No outbound network calls** except:
  - Option 23: a single HTTPS request to
    `https://api.github.com/repos/sanguirIS/WinUtilKLENN/releases/latest`
    to compare versions (user-agent `WinUtilKLENN/<VERSION>`, 15-second
    timeout, TLS 1.2).
  - Option 24: if you choose to launch Chris Titus Tech WinUtil, an
    `irm https://christitus.com/win | iex` is run, which pulls code
    from a third-party host.
  - Options 17–19: npm registry access when installing/updating the
    third-party packages.
- **Logs.** All actions are appended to
  `%ProgramData%\WinUtilKLENN\WinUtilKLENN.log`, rotated at 512 KB.
  Treat the log as potentially containing hostnames, usernames, and
  command output; it is not uploaded anywhere.
- **No persistence, no telemetry.** The script does not install
  services, scheduled tasks, or auto-run entries beyond what Windows
  already provides. It does not phone home beyond the update check
  above.

If any of the above turns out to be untrue, that is a bug — please
report it.
