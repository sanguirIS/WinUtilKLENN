# Third-Party Licenses

This file collects the full license texts of third-party software that WinUtilKLENN downloads, invokes, or integrates with.

WinUtilKLENN itself is licensed under the GNU General Public License v3.0 — see [LICENSE](LICENSE). The tools below are the property of their respective owners and are governed by **their own** license terms, reproduced here for reference and compliance.

---

## 1. Chris Titus Tech WinUtil

- **Website / Source:** https://github.com/ChrisTitusTech/winutil · https://christitus.com/win
- **License:** MIT License
- **Used for:** Option 15 — optional WinUtil toolbox setup (download, winget install, launch)

```
MIT License
Copyright (c) 2022 CT Tech Group LLC
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 2. Microsoft PowerShell

- **Website / Source:** https://github.com/PowerShell/PowerShell
- **License:** MIT License
- **Used for:** Automation throughout the script (queries, resizing, downloads, and more)

```
Copyright (c) Microsoft Corporation.
MIT License
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 3. Microsoft Windows built-in tools

- **Tools used:** `DISM`, `SFC`, `netsh`, `ipconfig`, `pnputil`, `sc`, `winget`
- **Website / Source:** https://learn.microsoft.com
- **License:** These tools ship as part of Windows and are covered by the [Microsoft Software License Terms](https://www.microsoft.com/en-us/legal/terms-of-use). No additional license text is reproduced here; no redistribution of these tools is performed by WinUtilKLENN — they are simply invoked on the system where it runs.

---

*This document was assembled from the official license files of the respective projects. If any license text above is outdated, refer to the linked source repositories.*
