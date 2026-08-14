$ErrorActionPreference = 'Stop'
$file = 'WinUtilKLENN.cmd'
$raw = Get-Content -LiteralPath $file -Raw
$errors = [System.Collections.Generic.List[string]]::new()

# 1. CRLF line endings
$crlf = ([regex]::Matches($raw, "`r`n")).Count
$lfOnly = ([regex]::Matches($raw, "(?<!`r)`n")).Count
if ($crlf -eq 0 -or $lfOnly -gt 0) {
  $errors.Add("Line endings: expected uniform CRLF, found $lfOnly LF-only breaks (check .gitattributes)")
}

# 2. Pure ASCII
if ($raw -match '[^\x00-\x7F]') {
  $errors.Add("Source contains non-ASCII characters; keep the file pure ASCII")
}

$scriptLines = $raw -split "`r?`n"
$labels = @{}
foreach ($ln in $scriptLines) {
  if ($ln -match '^:([A-Za-z0-9_]+)[ \t]*$') { $labels[$matches[1]] = $true }
}

# 3. Every goto target must exist
foreach ($ln in $scriptLines) {
  if ($ln -match '^\s*goto[ \t]+([A-Za-z0-9_]+)') {
    if (-not $labels.ContainsKey($matches[1])) { $errors.Add("goto target missing: '$($matches[1])'") }
  }
}

# 4. Every call :routine must exist
foreach ($ln in $scriptLines) {
  if ($ln -match '^\s*call[ \t]+:([A-Za-z0-9_]+)') {
    if (-not $labels.ContainsKey($matches[1])) { $errors.Add("call target missing: '$($matches[1])'") }
  }
}

# 5. No duplicate labels
$all = foreach ($ln in $scriptLines) { if ($ln -match '^:([A-Za-z0-9_]+)[ \t]*$') { $matches[1] } }
foreach ($d in ($all | Group-Object | Where-Object Count -gt 1)) {
  $errors.Add("Duplicate label: '$($d.Name)' appears $($d.Count) times")
}

# 6. Balanced parentheses
$open = ([regex]::Matches($raw, '\(')).Count
$close = ([regex]::Matches($raw, '\)')).Count
if ($open -ne $close) {
  $errors.Add("Unbalanced parentheses: $open '(' vs $close ')'")
}

# 7. Every embedded PowerShell -Command one-liner must parse
$psCount = 0
foreach ($ln in $scriptLines) {
  foreach ($m in [regex]::Matches($ln, '-Command\s+"([^"]*)"')) {
    $psCount++
    $cmd = $m.Groups[1].Value
    $cmd = [regex]::Replace($cmd, '%[^%]*%', '')
    $tokens = $null
    $parseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseInput($cmd, [ref]$tokens, [ref]$parseErrors)
    foreach ($e in $parseErrors) {
      $snippet = $ln.Trim()
      if ($snippet.Length -gt 70) { $snippet = $snippet.Substring(0, 70) + '...' }
      $errors.Add("PowerShell parse error in '$snippet': $($e.Message)")
    }
  }
}
if ($psCount -eq 0) {
  $errors.Add("No PowerShell -Command invocations found - extraction may be broken")
}

if ($errors.Count -gt 0) {
  Write-Output "Batch sanity check FAILED"
  foreach ($e in $errors) { Write-Output "  - $e" }
  exit 1
}
Write-Output "All batch sanity checks passed: $($scriptLines.Count) lines, $($labels.Count) labels, $psCount PowerShell one-liners, no errors."
