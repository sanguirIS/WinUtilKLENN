@echo off
rem ================================================================
rem  WinUtilKLENN v2.9.0
rem  Diagnostics and guided repair tools for Windows 10 / 11.
rem  Copyright (C) 2026 sanguirIS (https://github.com/sanguirIS)
rem  License: GNU GPL v3. NO WARRANTY. See the LICENSE file and
rem  https://www.gnu.org/licenses/gpl-3.0.html
rem
rem  Theme palette is the Dracula specification:
rem  Background #282A36  Foreground #F8F8F2  Comment #6272A4
rem  Red #FF5555  Orange #FFB86C  Yellow #F1FA8C  Green #50FA7B
rem  Cyan #8BE9FD  Purple #BD93F9  Pink #FF79C6  Selection #44475A
rem
rem  v2.9.0
rem  - Dracula theme on every screen (truecolor, palette, terminal).
rem  - Responsive boxes: width follows the console, text word-wraps
rem    inside the box, and the font/window auto-fit the screen.
rem  - Very narrow or very wide windows are refit automatically.
rem  - Scrollback kept (buffer 2000) so long diagnostics are not lost.
rem  - Elevation survives spaces and apostrophes and keeps the folder.
rem  - Restored selective winget upgrades (all, or chosen Ids/Names).
rem  - winget negative exit codes no longer look like success.
rem  - PATH refresh reads expanded values, not raw REG_EXPAND_SZ.
rem  - Disk cleanup no longer breaks on apostrophes in the user name.
rem  - Update check uses this version and ignores pre-release suffixes.
rem  - Windows Update cache reset waits, then verifies the renames.
rem  - yoinks checks for Windows Terminal before launching it.
rem  - Node.js install continues into the requested npm package.
rem  - Invalid menu input is shown, never executed.
rem  - Security check remains option 25.
rem  - Accent colours CYAN and GREEN are defined (theme was missing them).
rem  - Printer repair clears the spool folder after the spooler stops.
rem  - winget --all no longer reports FIXED when winget fails.
rem  - The box never grows wider than the console window.
rem  Earlier notes: README.md Changelog.
rem ================================================================
chcp 65001 >nul
setlocal EnableExtensions
title WinUtilKLENN
color 07

set "LOGDIR=%ProgramData%\WinUtilKLENN"
set "LOGFILE=%LOGDIR%\WinUtilKLENN.log"
set "VERSION=v2.9.0"
set "THEME=Dracula"
set "WUK_W=72"
set "INNER=72"
set "BOX_W=76"
set "RULE_NEED=74"
set "NOW_W=80"
set "NOW_H=40"
set "FONT_HOLD="
set "SAY_COLOR="

if /i "%CD%"=="%SystemRoot%\System32" cd /d "%~dp0"
if /i "%CD%"=="%SystemRoot%\SysWOW64" cd /d "%~dp0"
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1

rem ------- ANSI colour engine (Dracula truecolor) ----------------
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "R=%ESC%[0m%ESC%[38;2;248;248;242m%ESC%[48;2;40;42;54m"
set "BOLD=%ESC%[1m"
set "DIM=%ESC%[2m%ESC%[38;2;98;114;164m"
set "EL=%ESC%[K"
set "BLK=%ESC%[38;2;40;42;54m"
set "RED=%ESC%[38;2;255;85;85m"
set "GRN=%ESC%[38;2;80;250;123m"
set "YLW=%ESC%[38;2;241;250;140m"
set "CYN=%ESC%[38;2;139;233;253m"
set "WHT=%ESC%[38;2;248;248;242m"
set "MAG=%ESC%[38;2;255;121;198m"
set "PUR=%ESC%[38;2;189;147;249m"
set "ORG=%ESC%[38;2;255;184;108m"
set "COM=%ESC%[38;2;98;114;164m"
set "BRED=%ESC%[1m%ESC%[38;2;255;85;85m"
set "BGRN=%ESC%[1m%ESC%[38;2;80;250;123m"
set "BYLW=%ESC%[1m%ESC%[38;2;255;184;108m"
set "BCYN=%ESC%[1m%ESC%[38;2;139;233;253m"
set "BWHT=%ESC%[1m%ESC%[38;2;248;248;242m"
set "BMAG=%ESC%[1m%ESC%[38;2;189;147;249m"
set "BGRED=%ESC%[48;2;255;85;85m"
set "BGGRN=%ESC%[48;2;80;250;123m"
set "BGYLW=%ESC%[48;2;241;250;140m"
set "BGBLU=%ESC%[48;2;68;71;90m"
set "BGMAG=%ESC%[48;2;255;121;198m"
set "BGCYN=%ESC%[48;2;139;233;253m"
set "SEL=%ESC%[48;2;68;71;90m"
set "FG=%ESC%[38;2;248;248;242m"
set "CYAN=%CYN%"
set "GREEN=%GRN%"
set "PINK=%ESC%[1m%ESC%[38;2;255;121;198m"
set "VCOL=%ESC%[38;2;98;114;164m"

rem  ASCII box fallbacks. Unicode glyphs replace these when available.
set "SYM_ARROW=>"
set "SYM_OK=v"
set "SYM_NO=x"
set "SYM_BULLET=o"
set "SYM_STAR=*"
set "SYM_H=-"
set "SYM_V=:"
set "BOX_TL=+"
set "BOX_TR=+"
set "BOX_BL=+"
set "BOX_BR=+"
set "BOX_ML=+"
set "BOX_MR=+"
set "SPACES= "

call :THEME
call :GLYPHS
call :SPACES
set "WUK_FONTDIR=F"
call :SETFONT
call :WINSIZE
call :FIT
call :SECLOGROTATE
echo [%date% %time%] Theme Dracula applied >> "%LOGFILE%"

if /i "%WINUTIL_TEST%"=="1" goto MENU
call :BOOT

rem ------- Self-elevate so repair actions can run ----------------
net session >nul 2>&1
if "%errorlevel%"=="0" goto ELEVATED
cls
call :FIT
call :TOP
set "SAY_COLOR=%ORG%"
set "MSG=  Administrator permission is required."
call :SAY
set "SAY_COLOR=%FG%"
set "MSG=  Accept the UAC prompt. The tool restarts elevated."
call :SAY
call :BOT
set "WINUTIL_SELF=%~f0"
set "WINUTIL_CWD=%CD%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -LiteralPath $env:WINUTIL_SELF -Verb RunAs -WorkingDirectory $env:WINUTIL_CWD" >nul 2>&1
if errorlevel 1 goto UAC_CANCELLED
exit /b

:ELEVATED
echo [%date% %time%] Started >> "%LOGFILE%"
goto MENU

:UAC_CANCELLED
cls
call :FIT
call :TOP
set "SAY_COLOR=%RED%"
set "MSG=  Elevation cancelled - no changes were made."
call :SAY
set "SAY_COLOR=%FG%"
set "MSG=  Some repairs need Administrator rights."
call :SAY
set "MSG=  Right-click this script and choose Run as administrator."
call :SAY
call :BOT
call :KEY
exit /b

:MENU
cls
call :FIT
call :TOP
set "SAY_COLOR=%PINK%"
set "MSG=  WINUTILKLENN"
call :SAY
set "SAY_COLOR=%CYAN%"
set "MSG=  Diagnostics and repair  -  Windows 10 / 11"
call :SAY
set "SAY_COLOR=%PUR%"
set "MSG=  %THEME% theme   %VERSION%   text auto-fits this window"
call :SAY
set "SAY_COLOR=%COM%"
set "MSG=  Drag the window. Boxes and text reflow. Extremes refit the font."
call :SAY
call :MID
set "SAY_COLOR=%PINK%"
set "MSG=  MEDIA"
call :SAY
call :ITEM 1 "Audio"
call :ITEM 2 "Video Playback"
call :ITEM 3 "Windows Media Player"
set "SAY_COLOR=%PINK%"
set "MSG=  CONNECTIVITY"
call :SAY
call :ITEM 4 "Network and Internet"
call :ITEM 5 "DNS Flush"
call :ITEM 6 "Bluetooth"
set "SAY_COLOR=%PINK%"
set "MSG=  DEVICES"
call :SAY
call :ITEM 7 "Printer"
call :ITEM 8 "Camera"
call :ITEM 9 "Graphics Driver Reset"
set "SAY_COLOR=%PINK%"
set "MSG=  WINDOWS UPDATE"
call :SAY
call :ITEM 10 "Windows Update"
call :ITEM 11 "BITS"
set "SAY_COLOR=%PINK%"
set "MSG=  MAINTENANCE"
call :SAY
call :ITEM 12 "Disk Cleanup"
call :ITEM 13 "Restore Point"
call :ITEM 14 "Battery Report"
call :ITEM 15 "Restart / Shutdown"
call :ITEM 16 "winget Upgrade"
set "SAY_COLOR=%PINK%"
set "MSG=  SECURITY"
call :SAY
call :ITEM 25 "Security Check - Defender, Firewall, UAC"
set "SAY_COLOR=%PINK%"
set "MSG=  OTHER / TOOLS"
call :SAY
call :ITEM 17 "Yoinks - Video Downloader"
call :ITEM 18 "ghgrab - GitHub Downloader"
call :ITEM 19 "Freebuff - AI Agent"
call :ITEM 20 "Program Compatibility"
call :ITEM 21 "Run ALL Diagnostics"
call :ITEM 22 "System Summary"
call :ITEM 23 "Check for Updates"
call :ITEM 24 "Chris Titus Tech WinUtil"
call :ITEM 0 "Exit"
call :MID
set "SAY_COLOR=%COM%"
set "MSG=  Log: %LOGFILE%"
call :SAY
set "MSG=  WinUtilKLENN  Copyright (C) 2026 sanguirIS"
call :SAY
set "MSG=  This program comes with ABSOLUTELY NO WARRANTY."
call :SAY
set "MSG=  Free software: redistribute under the GNU GPL v3. See LICENSE."
call :SAY
call :BOT
echo.
set "CHOICE="
set /p "CHOICE=%R%%SEL%%BOLD%  Select an option [0-25]: %R%"
if not defined CHOICE goto MENU
call :SANITIZE
if not defined CHOICE goto MENU
if "%CHOICE%"=="" goto MENU
if "%CHOICE%"=="1" goto AUDIO
if "%CHOICE%"=="2" goto VIDEO
if "%CHOICE%"=="3" goto WMP
if "%CHOICE%"=="4" goto NETWORK
if "%CHOICE%"=="5" goto DNSFLUSH
if "%CHOICE%"=="6" goto BLUETOOTH
if "%CHOICE%"=="7" goto PRINTER
if "%CHOICE%"=="8" goto CAMERA
if "%CHOICE%"=="9" goto GFXRESET
if "%CHOICE%"=="10" goto UPDATE
if "%CHOICE%"=="11" goto BITS
if "%CHOICE%"=="12" goto DISKCLEAN
if "%CHOICE%"=="13" goto RESTOPOINT
if "%CHOICE%"=="14" goto BATTERY
if "%CHOICE%"=="15" goto POWER
if "%CHOICE%"=="16" goto WINGETUP
if "%CHOICE%"=="17" goto YOINK
if "%CHOICE%"=="18" goto GHGRAB
if "%CHOICE%"=="19" goto FREEBUFF
if "%CHOICE%"=="20" goto COMPAT
if "%CHOICE%"=="21" goto ALL
if "%CHOICE%"=="22" goto SUMMARY
if "%CHOICE%"=="23" goto UPDATECHECK
if "%CHOICE%"=="24" goto WINUTIL
if "%CHOICE%"=="25" goto SECURITY
if "%CHOICE%"=="0" goto END
echo.
call :SHOWBAD
call :KEY
goto MENU

rem ================================================================
rem  1. AUDIO
rem ================================================================
:AUDIO
cls
call :HEADER "AUDIO TROUBLESHOOTER"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Service status:%EL%
call :SVCSTATUS AudioEndpointBuilder "Audio Endpoint Builder"
call :SVCSTATUS Audiosrv "Windows Audio"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Sound devices detected by Windows:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Sound -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName,Manufacturer | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
call :ASK "Restart the Windows Audio services?"
if errorlevel 2 goto MENU
call :WORK "Restarting audio services"
net stop Audiosrv /y >nul 2>&1
net stop AudioEndpointBuilder /y >nul 2>&1
net start AudioEndpointBuilder >nul 2>&1
net start Audiosrv >nul 2>&1
call :WORKDONE
call :CHECKSVC AudioEndpointBuilder "Audio Endpoint Builder"
call :CHECKSVC Audiosrv "Windows Audio"
sc query Audiosrv 2>nul | findstr /C:": 4  " >nul
if errorlevel 1 goto AUDIO_FAIL
call :VERDICT FIXED "Audio services are running again."
call :RESTARTNOTE NO
goto AUDIO_LOG
:AUDIO_FAIL
call :VERDICT NOT "Audio services failed to start."
call :RESTARTNOTE YES
:AUDIO_LOG
echo [%date% %time%] Audio repair >> "%LOGFILE%"
call :PAUSE
goto MENU

rem ================================================================
rem  2. VIDEO PLAYBACK
rem ================================================================
:VIDEO
cls
call :HEADER "VIDEO PLAYBACK"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Display adapters:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Display -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName,Manufacturer | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%GPU driver details:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,DriverDate,VideoModeDescription | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
set "SAY_COLOR=%ORG%"
set "MSG=Tip: stutter or a black picture? Update the GPU driver, disable hardware acceleration in the player, or change the refresh rate."
call :SAY
call :PAUSE
goto MENU

rem ================================================================
rem  3. WINDOWS MEDIA PLAYER
rem ================================================================
:WMP
cls
call :HEADER "WINDOWS MEDIA PLAYER"
echo.
set "WMPSYS=%ProgramFiles%\Windows Media Player\wmplayer.exe"
if exist "%WMPSYS%" goto WMP_OK
echo %R%%RED%%SYM_NO%%R%  %WHT%Windows Media Player%R%  %DIM%not found on this system%EL%
goto WMP_MEDIA
:WMP_OK
echo %R%%BGRN%%SYM_OK%%R%  %WHT%Windows Media Player found:%EL%
set "MSG=  %WMPSYS%"
set "SAY_COLOR=%CYAN%"
call :SAY
:WMP_MEDIA
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Media file associations:%EL%
assoc .mp3
assoc .mp4
assoc .wmv
assoc .avi
assoc .wav
echo.
set "SAY_COLOR=%ORG%"
set "MSG=Tip: files opening in the wrong player? Change default apps in Windows Settings, Apps, Default apps."
call :SAY
call :PAUSE
goto MENU

rem ================================================================
rem  4. NETWORK AND INTERNET
rem ================================================================
:NETWORK
cls
call :HEADER "NETWORK AND INTERNET"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Network adapters:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object Name,Status,LinkSpeed,MacAddress | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%IP configuration:%EL%
ipconfig /all
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Internet reachability and DNS:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "foreach($x in '1.1.1.1','8.8.8.8'){Write-Host ('   ' + $x + ' reachable: ' + (Test-Connection -ComputerName $x -Count 2 -Quiet))}; Resolve-DnsName www.microsoft.com -ErrorAction SilentlyContinue | Select-Object Name,Type,IPAddress | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
call :ASK "Reset Winsock, the TCP/IP stack and the DNS cache?"
if errorlevel 2 goto MENU
echo %R%%CYAN%%SYM_ARROW%%R%  Flushing DNS cache...%EL%
ipconfig /flushdns >nul
echo %R%%CYAN%%SYM_ARROW%%R%  Resetting Winsock...%EL%
netsh winsock reset
echo.
echo %R%%CYAN%%SYM_ARROW%%R%  Resetting TCP/IP stack...%EL%
netsh int ip reset
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Network check after the reset:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ok=0; foreach($x in '1.1.1.1','8.8.8.8'){ if(Test-Connection -ComputerName $x -Count 2 -Quiet){ $ok++ } }; Write-Host ('   Reachable: ' + $ok + ' of 2 test addresses.'); if($ok -eq 0){ exit 1 }"
if errorlevel 1 goto NET_FAIL
call :VERDICT FIXED "Network is reachable."
goto NET_END
:NET_FAIL
call :VERDICT NOT "Network is still unreachable."
:NET_END
call :RESTARTNOTE YES
echo [%date% %time%] Network reset >> "%LOGFILE%"
call :PAUSE
goto MENU

rem ================================================================
rem  5. DNS FLUSH
rem ================================================================
:DNSFLUSH
cls
call :HEADER "DNS FLUSH"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%DNS servers in use:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.ServerAddresses } | Select-Object InterfaceAlias,ServerAddresses | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Resolver cache entries:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Write-Host ('   ' + (Get-DnsClientCache -ErrorAction SilentlyContinue | Measure-Object).Count + ' cached entries')"
echo.
call :ASK "Flush the DNS resolver cache?"
if errorlevel 2 goto MENU
echo %R%%CYAN%%SYM_ARROW%%R%  Flushing DNS cache...%EL%
ipconfig /flushdns
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$c=@(Get-DnsClientCache -ErrorAction SilentlyContinue).Count; Write-Host ('   Cache entries now: ' + $c); if($c -eq 0){ exit 0 } else { exit 1 }"
if errorlevel 1 goto DNSF_NOTCLEAR
call :VERDICT FIXED "The DNS cache is empty."
goto DNSF_END
:DNSF_NOTCLEAR
call :VERDICT FIXED "DNS cache was flushed."
:DNSF_END
call :RESTARTNOTE NO
echo [%date% %time%] DNS cache flushed >> "%LOGFILE%"
call :PAUSE
goto MENU

rem ================================================================
rem  6. BLUETOOTH
rem ================================================================
:BLUETOOTH
cls
call :HEADER "BLUETOOTH"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Bluetooth devices:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName,Manufacturer | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Bluetooth service status:%EL%
call :SVCSTATUS bthserv "Bluetooth Support Service"
echo.
call :ASK "Restart the Bluetooth Support Service?"
if errorlevel 2 goto MENU
call :WORK "Restarting Bluetooth service"
net stop bthserv /y >nul 2>&1
net start bthserv >nul 2>&1
call :WORKDONE
call :CHECKSVC bthserv "Bluetooth Support Service"
sc query bthserv 2>nul | findstr /C:": 4  " >nul
if errorlevel 1 goto BT_FAIL
call :VERDICT FIXED "The Bluetooth service is running again."
call :RESTARTNOTE NO
goto BT_END
:BT_FAIL
call :VERDICT NOT "The Bluetooth service failed to start."
call :RESTARTNOTE YES
:BT_END
echo [%date% %time%] Bluetooth service restarted >> "%LOGFILE%"
call :PAUSE
goto MENU

rem ================================================================
rem  7. PRINTER
rem ================================================================
:PRINTER
cls
call :HEADER "PRINTER"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Print Spooler status:%EL%
call :SVCSTATUS Spooler "Print Spooler"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Installed printers:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-Printer -ErrorAction SilentlyContinue | Select-Object Name,DriverName,PortName,PrinterStatus,WorkOffline | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
call :ASK "Restart the Print Spooler and clear stuck jobs?"
if errorlevel 2 goto MENU
call :WORK "Restarting spooler and clearing stuck jobs"
net stop Spooler /y >nul 2>&1
del /q /f "%SystemRoot%\System32\spool\PRINTERS\*" >nul 2>&1
set "PRN_LEFT=0"
dir /a-d /b "%SystemRoot%\System32\spool\PRINTERS" 2>nul | findstr /R "." >nul && set "PRN_LEFT=1"
net start Spooler >nul 2>&1
call :WORKDONE
call :CHECKSVC Spooler "Print Spooler"
sc query Spooler 2>nul | findstr /C:": 4  " >nul
if errorlevel 1 goto PRN_FAIL
if "%PRN_LEFT%"=="1" goto PRN_JOBS
call :VERDICT FIXED "The Print Spooler is running and stuck jobs were cleared."
call :RESTARTNOTE NO
goto PRN_END
:PRN_JOBS
call :VERDICT NOT "The spooler is running, but some spool files are still locked."
set "SAY_COLOR=%COM%"
set "MSG=Reboot, then run this option again so the locked jobs can be deleted."
call :SAY
call :RESTARTNOTE YES
goto PRN_END
:PRN_FAIL
call :VERDICT NOT "The Print Spooler failed to start."
call :RESTARTNOTE YES
:PRN_END
echo [%date% %time%] Printer spooler reset >> "%LOGFILE%"
call :PAUSE
goto MENU

rem ================================================================
rem  8. CAMERA
rem ================================================================
:CAMERA
cls
call :HEADER "CAMERA"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Camera devices:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Camera -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName,Manufacturer | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Camera privacy setting:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam' -ErrorAction SilentlyContinue | Select-Object Value | Format-List | Out-String -Width $env:WUK_W"
echo.
call :ASK "Rescan Plug and Play devices?"
if errorlevel 2 goto MENU
echo %R%%CYAN%%SYM_ARROW%%R%  Scanning for hardware changes...%EL%
pnputil.exe /scan-devices
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$n=@(Get-PnpDevice -Class Camera -ErrorAction SilentlyContinue).Count; Write-Host ('   Camera devices found: ' + $n); if($n -gt 0){ exit 0 } else { exit 1 }"
if errorlevel 1 goto CAM_FAIL
call :VERDICT FIXED "Camera devices are detected."
call :RESTARTNOTE NO
goto CAM_END
:CAM_FAIL
call :VERDICT NOT "No camera devices found."
set "SAY_COLOR=%COM%"
set "MSG=Check the webcam privacy setting or the driver."
call :SAY
call :RESTARTNOTE NO
:CAM_END
echo [%date% %time%] Camera PnP rescan >> "%LOGFILE%"
call :PAUSE
goto MENU

rem ================================================================
rem  9. GRAPHICS DRIVER RESET
rem ================================================================
:GFXRESET
cls
call :HEADER "GRAPHICS DRIVER RESET"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Display adapters:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Display -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
set "SAY_COLOR=%ORG%"
set "MSG=The screen may flicker or go black for a few seconds."
call :SAY
call :ASK "Restart the display drivers now?"
if errorlevel 2 goto MENU
set "GFX_DONE=0"
for /f "delims=" %%d in ('powershell.exe -NoProfile -Command "Get-PnpDevice -Class Display -Status OK -ErrorAction SilentlyContinue | ForEach-Object { $_.InstanceId }"') do (
    echo %R%%CYAN%%SYM_ARROW%%R%  Restarting display adapter%EL%
    pnputil.exe /restart-device "%%d"
    if not errorlevel 1 set "GFX_DONE=1"
)
if "%GFX_DONE%"=="0" goto GFX_FAIL
call :VERDICT FIXED "The display driver was restarted."
call :RESTARTNOTE NO
echo [%date% %time%] Graphics driver reset >> "%LOGFILE%"
goto GFX_END
:GFX_FAIL
call :VERDICT NOT "No display adapter could be restarted."
set "SAY_COLOR=%COM%"
set "MSG=Try updating the driver, or restart the PC instead."
call :SAY
call :RESTARTNOTE YES
:GFX_END
call :PAUSE
goto MENU

rem ================================================================
rem  10. WINDOWS UPDATE
rem ================================================================
:UPDATE
cls
call :HEADER "WINDOWS UPDATE"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Service status:%EL%
call :SVCSTATUS wuauserv "Windows Update"
call :SVCSTATUS bits "Background Intelligent Transfer"
call :SVCSTATUS cryptsvc "Cryptographic Services"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Pending restart flags:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$p=@('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'); foreach($x in $p){Write-Host ($x + ' = ' + (Test-Path $x))}"
echo.
call :ASK "Reset the Windows Update cache?"
if errorlevel 2 goto UPDATE_SFC
call :WORK "Stopping update services"
call :WAITSTOP wuauserv
call :WAITSTOP bits
call :WAITSTOP cryptsvc
call :WORK "Moving the update cache aside"
call :RENAMEONE "%SystemRoot%\SoftwareDistribution" "SoftwareDistribution.old"
set "SD_OK=%RN_OK%"
call :RENAMEONE "%SystemRoot%\System32\catroot2" "catroot2.old"
set "CR_OK=%RN_OK%"
echo %R%%CYAN%%SYM_ARROW%%R%  Restarting update services...%EL%
net start cryptsvc >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
call :WORKDONE
call :CHECKSVC wuauserv "Windows Update"
if not "%SD_OK%"=="1" goto UPDC_FAIL
if not "%CR_OK%"=="1" goto UPDC_FAIL
sc query wuauserv 2>nul | findstr /C:": 4  " >nul
if errorlevel 1 goto UPDC_FAIL
call :VERDICT FIXED "Update cache reset and services are running."
call :RESTARTNOTE NO
goto UPDC_END
:UPDC_FAIL
call :VERDICT NOT "Cache reset incomplete or Windows Update did not start."
set "SAY_COLOR=%COM%"
set "MSG=A folder was still locked, or a service did not return to Running. Reboot and run this option again."
call :SAY
call :RESTARTNOTE YES
:UPDC_END
echo [%date% %time%] Windows Update cache reset >> "%LOGFILE%"
echo.
:UPDATE_SFC
set "SAY_COLOR=%COM%"
set "MSG=This can take 10 to 30 minutes. DISM needs internet access."
call :SAY
call :ASK "Run DISM component repair and sfc /scannow?"
if errorlevel 2 goto MENU
echo %R%%CYAN%%SYM_ARROW%%R%  %BOLD%Running DISM /RestoreHealth...%EL%
DISM.exe /Online /Cleanup-Image /RestoreHealth
echo.
echo %R%%CYAN%%SYM_ARROW%%R%  %BOLD%Running SFC /scannow...%EL%
sfc.exe /scannow
echo.
call :REBOOTCHECK
if errorlevel 1 goto SFC_RESTART
call :VERDICT FIXED "System file repair completed."
call :RESTARTNOTE NO
goto SFC_END
:SFC_RESTART
call :VERDICT FIXED "System file repair completed."
call :RESTARTNOTE YES
:SFC_END
echo [%date% %time%] DISM+SFC run >> "%LOGFILE%"
call :PAUSE
goto MENU
rem ================================================================
rem  11. BITS
rem ================================================================
:BITS
cls
call :HEADER "BITS"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%BITS service status:%EL%
call :SVCSTATUS bits "Background Intelligent Transfer"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Active BITS jobs:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue | Select-Object DisplayName,JobState,BytesTransferred,BytesTotal | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
call :ASK "Restart BITS and Windows Update services?"
if errorlevel 2 goto MENU
call :WORK "Restarting BITS and Windows Update"
net stop bits /y >nul 2>&1
net stop wuauserv /y >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
call :WORKDONE
call :CHECKSVC bits "BITS"
call :CHECKSVC wuauserv "Windows Update"
sc query bits 2>nul | findstr /C:": 4  " >nul
if errorlevel 1 goto BITS_FAIL
call :VERDICT FIXED "BITS and Windows Update are running again."
call :RESTARTNOTE NO
goto BITS_END
:BITS_FAIL
call :VERDICT NOT "BITS or Windows Update failed to start."
call :RESTARTNOTE YES
:BITS_END
echo [%date% %time%] BITS service restart >> "%LOGFILE%"
call :PAUSE
goto MENU

rem ================================================================
rem  12. DISK CLEANUP
rem ================================================================
:DISKCLEAN
cls
call :HEADER "DISK CLEANUP"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Free space before cleanup:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { Write-Host ('   Disk '+$_.DeviceID+'  '+[math]::Round($_.FreeSpace/1GB,1)+' GB free') }"
echo.
set "SAY_COLOR=%COM%"
set "MSG=Only temp files are removed. Personal files are left alone."
call :SAY
call :ASK "Delete temporary files and empty the Recycle Bin?"
if errorlevel 2 goto MENU
call :WORK "Removing temp files and emptying the Recycle Bin"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$paths=@($env:TEMP,(Join-Path $env:SystemRoot 'Temp')); foreach($p in $paths){ Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }; Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
call :WORKDONE
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Free space after cleanup:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { Write-Host ('   Disk '+$_.DeviceID+'  '+[math]::Round($_.FreeSpace/1GB,1)+' GB free') }"
call :VERDICT FIXED "Cleanup completed."
call :RESTARTNOTE NO
echo [%date% %time%] Disk cleanup >> "%LOGFILE%"
call :PAUSE
goto MENU

rem ================================================================
rem  13. SYSTEM RESTORE POINT
rem ================================================================
:RESTOPOINT
cls
call :HEADER "SYSTEM RESTORE POINT"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Existing restore points:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-ComputerRestorePoint -ErrorAction SilentlyContinue | Select-Object SequenceNumber,Description,CreationTime | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
set "SAY_COLOR=%COM%"
set "MSG=System Protection is enabled first if it is off."
call :SAY
call :ASK "Create a restore point now?"
if errorlevel 2 goto MENU
echo %R%%CYAN%%SYM_ARROW%%R%  Enabling System Protection on the system drive...%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Enable-ComputerRestore -Drive ($env:SystemDrive + '\') -ErrorAction SilentlyContinue"
call :WORK "Creating restore point"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { Checkpoint-Computer -Description 'WinUtilKLENN restore point' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop; exit 0 } catch { exit 1 }"
set "RP_RC=%errorlevel%"
call :WORKDONE
if not "%RP_RC%"=="0" goto RESTORE_FAIL
call :VERDICT FIXED "Restore point created."
call :RESTARTNOTE NO
echo [%date% %time%] Restore point created >> "%LOGFILE%"
goto RESTORE_END
:RESTORE_FAIL
call :VERDICT NOT "Could not create a restore point."
set "SAY_COLOR=%COM%"
set "MSG=Open System Properties, System Protection, and enable protection for the system drive, then try again."
call :SAY
:RESTORE_END
call :PAUSE
goto MENU

rem ================================================================
rem  14. BATTERY REPORT
rem ================================================================
:BATTERY
cls
call :HEADER "BATTERY REPORT"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Battery status:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$b=Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue; if(-not $b){Write-Host '   No battery detected - this looks like a desktop PC.'}else{$s=switch($b.BatteryStatus){1{'Discharging'}2{'On AC power'}3{'Fully charged'}4{'Low'}5{'Critical'}6{'Charging'}default{'Code '+$_}}; Write-Host ('   Charge: '+$b.EstimatedChargeRemaining+' percent   Status: '+$s)}"
echo.
call :ASK "Generate the full battery report?"
if errorlevel 2 goto MENU
echo %R%%CYAN%%SYM_ARROW%%R%  Generating battery report...%EL%
powercfg /batteryreport /output "%LOGDIR%\battery-report.html" >nul 2>&1
if not exist "%LOGDIR%\battery-report.html" goto BATTERY_FAIL
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%Battery report saved.%EL%
set "MSG=  %LOGDIR%\battery-report.html"
set "SAY_COLOR=%CYAN%"
call :SAY
call :ASK "Open it in the default browser?"
if errorlevel 2 goto BATTERY_END
start "" "%LOGDIR%\battery-report.html"
goto BATTERY_END
:BATTERY_FAIL
echo %R%%RED%%SYM_NO%%R%  %WHT%Could not generate the battery report.%EL%
set "SAY_COLOR=%COM%"
set "MSG=This usually means the PC has no battery, for example a desktop."
call :SAY
:BATTERY_END
echo [%date% %time%] Battery report >> "%LOGFILE%"
call :PAUSE
goto MENU

rem ================================================================
rem  15. RESTART / SHUTDOWN
rem ================================================================
:POWER
cls
call :HEADER "RESTART / SHUTDOWN"
set "SAY_COLOR=%FG%"
set "MSG=What do you want to do?"
call :SAY
call :ITEM 1 "Restart the PC"
call :ITEM 2 "Shut down the PC"
call :ITEM 0 "Cancel - back to the menu"
echo.
echo %R%%SEL%%BOLD%  Press 1, 2, or 0.%EL%
choice /C 120 /N
if errorlevel 3 goto MENU
if errorlevel 2 goto POWER_OFF
call :ASK "Restart the PC in 30 seconds?"
if errorlevel 2 goto MENU
shutdown /r /t 30
echo [%date% %time%] Restart scheduled >> "%LOGFILE%"
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%Restart scheduled in 30 seconds.%EL%
set "SAY_COLOR=%ORG%"
set "MSG=To cancel, open another Command Prompt and run: shutdown /a"
call :SAY
call :PAUSE
goto MENU
:POWER_OFF
call :ASK "Shut down the PC in 30 seconds?"
if errorlevel 2 goto MENU
shutdown /s /t 30
echo [%date% %time%] Shutdown scheduled >> "%LOGFILE%"
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%Shutdown scheduled in 30 seconds.%EL%
set "SAY_COLOR=%ORG%"
set "MSG=To cancel, open another Command Prompt and run: shutdown /a"
call :SAY
call :PAUSE
goto MENU

rem ================================================================
rem  16. WINGET UPGRADE
rem ================================================================
:WINGETUP
cls
call :HEADER "WINGET UPGRADE"
winget --version >nul 2>&1
if errorlevel 1 goto WINGET_MISSING
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Available updates:%EL%
winget upgrade --accept-source-agreements
echo.
set "SAY_COLOR=%CYAN%"
set "MSG=  Choose what to upgrade"
call :SAY
call :ITEM 1 "ALL packages"
call :ITEM 2 "SELECT packages by Id or Name"
call :ITEM 0 "Cancel"
echo.
echo %R%%SEL%%BOLD%  Press 1, 2, or 0.%EL%
choice /C 120 /N
if errorlevel 3 goto WINGET_CANCEL
if errorlevel 2 goto WINGET_SELECT
set "SAY_COLOR=%COM%"
set "MSG=Some apps may need to close. This can take a while."
call :SAY
winget upgrade --all --accept-package-agreements --accept-source-agreements
set "WG_ALLRC=%errorlevel%"
echo [%date% %time%] winget upgrade --all exit %WG_ALLRC% >> "%LOGFILE%"
if "%WG_ALLRC%"=="0" goto WINGET_AFTER
set "SAY_COLOR=%ORG%"
set "MSG=winget reported a non-zero exit code. Check the list above."
call :SAY
echo.
call :REBOOTCHECK
if errorlevel 1 goto WINGET_ALLFAIL_R
call :VERDICT NOT "winget upgrade --all did not finish cleanly."
call :RESTARTNOTE NO
goto WINGET_END
:WINGET_ALLFAIL_R
call :VERDICT NOT "winget upgrade --all did not finish cleanly."
call :RESTARTNOTE YES
goto WINGET_END
:WINGET_SELECT
echo.
set "SAY_COLOR=%FG%"
set "MSG=Type one or more package Ids, separated by spaces or commas."
call :SAY
set "SAY_COLOR=%COM%"
set "MSG=Example: Git.Git VideoLAN.VLC Mozilla.Firefox"
call :SAY
echo.
set "WG_LIST="
set /p "WG_LIST=%R%%SEL%%BOLD%  Ids to upgrade: %R%"
if not defined WG_LIST goto WINGET_CANCEL
set "WG_LIST=%WG_LIST:"=%"
set "WG_LIST=%WG_LIST:&=%"
set "WG_LIST=%WG_LIST:|=%"
set "WG_LIST=%WG_LIST:<=%"
set "WG_LIST=%WG_LIST:>=%"
set "WG_LIST=%WG_LIST:(=%"
set "WG_LIST=%WG_LIST:)=%"
set "WG_LIST=%WG_LIST:^=%"
if "%WG_LIST%"=="" goto WINGET_CANCEL
set /a WG_OK=0
set /a WG_FAIL=0
echo [%date% %time%] winget upgrade selected: %WG_LIST% >> "%LOGFILE%"
for %%p in (%WG_LIST%) do call :WGUPGRADE %%p
echo [%date% %time%] winget selected: %WG_OK% ok, %WG_FAIL% failed >> "%LOGFILE%"
set /a WG_TOT=WG_OK+WG_FAIL
if %WG_TOT%==0 goto WINGET_CANCEL
if %WG_FAIL% GTR 0 goto WINGET_PARTIAL
:WINGET_AFTER
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Remaining updates:%EL%
winget upgrade --accept-source-agreements
echo.
call :REBOOTCHECK
if errorlevel 1 goto WINGET_RESTART
call :VERDICT FIXED "The winget upgrade finished."
call :RESTARTNOTE NO
goto WINGET_END
:WINGET_RESTART
call :VERDICT FIXED "The winget upgrade finished."
call :RESTARTNOTE YES
goto WINGET_END
:WINGET_PARTIAL
echo.
call :REBOOTCHECK
if errorlevel 1 goto WINGET_PARTIAL_R
call :VERDICT NOT "Some selected packages could not be upgraded."
call :RESTARTNOTE NO
goto WINGET_END
:WINGET_PARTIAL_R
call :VERDICT NOT "Some selected packages could not be upgraded."
call :RESTARTNOTE YES
goto WINGET_END
:WINGET_CANCEL
set "SAY_COLOR=%ORG%"
set "MSG=Cancelled - no packages were upgraded."
call :SAY
echo [%date% %time%] winget upgrade cancelled >> "%LOGFILE%"
goto WINGET_END
:WINGET_MISSING
echo %R%%RED%%SYM_NO%%R%  %WHT%winget is not installed.%EL%
set "SAY_COLOR=%COM%"
set "MSG=Install App Installer from the Microsoft Store, then run this option again."
call :SAY
echo [%date% %time%] winget upgrade failed - winget not installed >> "%LOGFILE%"
:WINGET_END
call :PAUSE
goto MENU

rem ================================================================
rem  25. SECURITY CHECK
rem ================================================================
:SECURITY
cls
call :HEADER "SECURITY CHECK"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Windows Defender real-time protection:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { $p=Get-MpComputerStatus -ErrorAction Stop; Write-Host ('   Antivirus enabled : ' + $p.AntivirusEnabled); Write-Host ('   Real-time guard   : ' + $p.RealTimeProtectionEnabled); Write-Host ('   Signatures        : ' + $p.AntivirusSignatureLastUpdated) } catch { Write-Host '   Defender status unavailable.' }"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Firewall profiles:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-NetFirewallProfile -ErrorAction SilentlyContinue | Select-Object Name,Enabled | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%UAC level:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$v=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -ErrorAction SilentlyContinue).EnableLUA; if($v -eq 0){ Write-Host '   EnableLUA = 0  -  Disabled. This is insecure.' } elseif($v -eq 1){ Write-Host '   EnableLUA = 1  -  Enabled.' } else { Write-Host '   EnableLUA is unknown.' }"
echo.
call :ASK "Run a Defender quick scan now?"
if errorlevel 2 goto SEC_END
call :WORK "Defender quick scan"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { Start-MpScan -ScanType QuickScan -ErrorAction Stop; exit 0 } catch { exit 1 }"
set "SEC_RC=%errorlevel%"
call :WORKDONE
if not "%SEC_RC%"=="0" goto SEC_SCAN_FAIL
call :VERDICT FIXED "Defender quick scan finished."
call :RESTARTNOTE NO
echo [%date% %time%] Security check + Defender quick scan >> "%LOGFILE%"
goto SEC_END
:SEC_SCAN_FAIL
call :VERDICT NOT "Defender quick scan did not finish."
set "SAY_COLOR=%COM%"
set "MSG=Defender may be unavailable, or another scan is already running."
call :SAY
echo [%date% %time%] Security check scan failed >> "%LOGFILE%"
:SEC_END
call :PAUSE
goto MENU

rem ================================================================
rem  17. YOINKS
rem ================================================================
:YOINK
cls
call :HEADER "YOINKS - VIDEO DOWNLOADER"
set "SAY_COLOR=%FG%"
set "MSG=Download videos from YouTube, X, Instagram, Threads, TikTok and 1,800+ other sites."
call :SAY
set "SAY_COLOR=%COM%"
set "MSG=Videos are saved to your Downloads folder."
call :SAY
echo.
call :NPMSETUP yoinks yoinks "yoinks video downloader"
if errorlevel 1 goto YOINK_END
echo.
set "SAY_COLOR=%CYAN%"
set "MSG=  Choose how to launch yoinks"
call :SAY
call :ITEM 1 "CMD - types yoinks and waits for a link"
call :ITEM 2 "Windows Terminal - new window"
call :ITEM 0 "Cancel"
echo.
set "YOINK_CHOICE="
set /p "YOINK_CHOICE=%R%%SEL%%BOLD%  Select [0-2]: %R%"
if not defined YOINK_CHOICE goto YOINK_END
set "CHOICE=%YOINK_CHOICE%"
call :SANITIZE
set "YOINK_CHOICE=%CHOICE%"
if "%YOINK_CHOICE%"=="" goto YOINK_BAD
if "%YOINK_CHOICE%"=="0" goto YOINK_END
if "%YOINK_CHOICE%"=="1" goto YOINK_CMD
if "%YOINK_CHOICE%"=="2" goto YOINK_WT
goto YOINK_BAD
:YOINK_CMD
set "SAY_COLOR=%COM%"
set "MSG=A command window opens and yoinks is typed for you. Paste a link, then press Enter. This menu returns when that window closes."
call :SAY
powershell -NoProfile -Command "$wshell = New-Object -ComObject WScript.Shell; $p = Start-Process cmd.exe -PassThru; Start-Sleep -Milliseconds 800; $wshell.AppActivate($p.Id); Start-Sleep -Milliseconds 150; $wshell.SendKeys('yoinks '); $p.WaitForExit()"
goto YOINK_OK
:YOINK_WT
where wt.exe >nul 2>&1
if errorlevel 1 goto YOINK_WTMISS
set "SAY_COLOR=%COM%"
set "MSG=Yoinks opens in a new Windows Terminal window. This menu returns when that window closes."
call :SAY
start "" /wait wt.exe new-tab --suppressApplicationTitle yoinks
goto YOINK_OK
:YOINK_WTMISS
echo %R%%RED%%SYM_NO%%R%  %WHT%Windows Terminal was not found.%EL%
set "SAY_COLOR=%COM%"
set "MSG=Install Windows Terminal from the Microsoft Store, or use option 1."
call :SAY
echo [%date% %time%] yoinks: Windows Terminal not found >> "%LOGFILE%"
goto YOINK_END
:YOINK_BAD
echo %R%%RED%  Invalid selection.%EL%
goto YOINK_END
:YOINK_OK
echo.
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%yoinks closed. Videos are in your Downloads folder.%EL%
echo [%date% %time%] yoinks video downloader run >> "%LOGFILE%"
:YOINK_END
call :PAUSE
goto MENU

rem ================================================================
rem  18. GHGRAB
rem ================================================================
:GHGRAB
cls
call :HEADER "GHGRAB - GITHUB DOWNLOADER"
set "SAY_COLOR=%FG%"
set "MSG=Browse and download files, folders or release assets from a GitHub repo without cloning it."
call :SAY
echo.
call :NPMSETUP @ghgrab/ghgrab ghgrab "ghgrab"
if errorlevel 1 goto GHGRAB_END
echo.
set "SAY_COLOR=%COM%"
set "MSG=Paste a repo link, or run ghgrab rel owner/repo for release assets."
call :SAY
call :RESIZE_MAX
call ghgrab
call :FIT
echo.
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%ghgrab closed.%EL%
echo [%date% %time%] ghgrab run >> "%LOGFILE%"
:GHGRAB_END
call :PAUSE
goto MENU

rem ================================================================
rem  19. FREEBUFF
rem ================================================================
:FREEBUFF
cls
call :HEADER "FREEBUFF - AI AGENT"
set "SAY_COLOR=%FG%"
set "MSG=Freebuff is a free AI coding agent that runs in this terminal. Ask it about an error, or to explain a repair step."
call :SAY
echo.
call :NPMSETUP freebuff freebuff "freebuff"
if errorlevel 1 goto FREEBUFF_END
echo.
set "SAY_COLOR=%COM%"
set "MSG=It opens in the folder this script was started from."
call :SAY
call :RESIZE_MAX
call freebuff
call :FIT
echo.
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%freebuff closed.%EL%
echo [%date% %time%] freebuff run >> "%LOGFILE%"
:FREEBUFF_END
call :PAUSE
goto MENU

rem ================================================================
rem  20. PROGRAM COMPATIBILITY
rem ================================================================
:COMPAT
cls
call :HEADER "PROGRAM COMPATIBILITY"
set "SAY_COLOR=%FG%"
set "MSG=Enter the full path to an .exe file to inspect it."
call :SAY
set "SAY_COLOR=%COM%"
set "MSG=Example: C:\Program Files\Example\app.exe"
call :SAY
echo.
set "EXE="
set /p "EXE=%R%%CYAN%  Path: %R%"
if not defined EXE goto MENU
if not exist "%EXE%" goto COMPAT_ERR
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$f=Get-Item -LiteralPath $env:EXE; $v=$f.VersionInfo; [pscustomobject]@{Path=$f.FullName;FileVersion=$v.FileVersion;Product=$v.ProductName;Company=$v.CompanyName;SizeMB=[math]::Round($f.Length/1MB,2)} | Format-List | Out-String -Width $env:WUK_W"
echo.
set "SAY_COLOR=%ORG%"
set "MSG=Tip: prefer a current version of the application. Use compatibility settings only when you need them."
call :SAY
call :PAUSE
goto MENU
:COMPAT_ERR
echo.
echo %R%%RED%%SYM_NO%%R%  %WHT%File not found.%EL%
powershell.exe -NoProfile -Command "Write-Host $env:EXE"
call :PAUSE
goto MENU

rem ================================================================
rem  21. COMPLETE DIAGNOSTICS
rem ================================================================
:ALL
cls
call :HEADER "COMPLETE DIAGNOSTICS"
set "SAY_COLOR=%FG%"
set "MSG=Scanning the system. This can take a few moments."
call :SAY
echo.
echo %R%%PINK%[1] AUDIO%EL%
call :SVCSTATUS Audiosrv "Windows Audio"
call :SVCSTATUS AudioEndpointBuilder "Audio Endpoint Builder"
echo.
echo %R%%PINK%[2] NETWORK%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object Name,Status,LinkSpeed | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
echo %R%%PINK%[3] PRINTER%EL%
call :SVCSTATUS Spooler "Print Spooler"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-Printer -ErrorAction SilentlyContinue | Select-Object Name,PrinterStatus | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
echo %R%%PINK%[4] WINDOWS UPDATE%EL%
call :SVCSTATUS wuauserv "Windows Update"
call :SVCSTATUS bits "BITS"
call :SVCSTATUS cryptsvc "Cryptographic Services"
echo.
echo %R%%PINK%[5] BLUETOOTH%EL%
call :SVCSTATUS bthserv "Bluetooth Support Service"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
echo %R%%PINK%[6] CAMERA%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Camera -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
echo %R%%PINK%[7] DISPLAY / VIDEO%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion | Format-Table -Wrap | Out-String -Width $env:WUK_W"
echo.
echo %R%%PINK%[8] WINDOWS MEDIA PLAYER%EL%
if exist "%ProgramFiles%\Windows Media Player\wmplayer.exe" goto ALL_WMP_OK
echo %R%%RED%%SYM_NO%%R%  %WHT%Windows Media Player%R%  %DIM%not installed%EL%
goto ALL_SEC
:ALL_WMP_OK
echo %R%%BGRN%%SYM_OK%%R%  %WHT%Windows Media Player%R%  %GRN%installed%EL%
:ALL_SEC
echo.
echo %R%%PINK%[9] SECURITY%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$v=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -ErrorAction SilentlyContinue).EnableLUA; if($v -eq 1){ Write-Host '   UAC is enabled.' } elseif($v -eq 0){ Write-Host '   UAC is disabled.' } else { Write-Host '   UAC state unknown.' }"
echo.
echo %R%%BGGRN%%BLK% DONE %R%  %BGRN%Complete diagnostics finished.%EL%
echo [%date% %time%] Complete diagnostics >> "%LOGFILE%"
call :PAUSE
goto MENU

rem ================================================================
rem  22. SYSTEM SUMMARY
rem ================================================================
:SUMMARY
cls
call :HEADER "SYSTEM SUMMARY"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Computer:%R%  %CYAN%%COMPUTERNAME%%EL%
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%User:%R%  %CYAN%%USERNAME%%EL%
echo.
ver
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture | Format-List | Out-String -Width $env:WUK_W"
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Memory and disk:%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$os=Get-CimInstance Win32_OperatingSystem; $tm=[math]::Round($os.TotalVisibleMemorySize/1MB,1); $fm=[math]::Round($os.FreePhysicalMemory/1MB,1); Write-Host ('   RAM free: '+$fm+' GB / '+$tm+' GB total'); Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { Write-Host ('   Disk '+$_.DeviceID+'  '+[math]::Round($_.FreeSpace/1GB,1)+' GB free / '+[math]::Round($_.Size/1GB,1)+' GB total') }"
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%PowerShell version:%EL%
powershell.exe -NoProfile -Command "$PSVersionTable.PSVersion.ToString()"
echo.
set "MSG=  Log: %LOGFILE%"
set "SAY_COLOR=%COM%"
call :SAY
call :PAUSE
goto MENU

rem ================================================================
rem  23. CHECK FOR UPDATES
rem ================================================================
:UPDATECHECK
cls
call :HEADER "CHECK FOR UPDATES"
set "SAY_COLOR=%COM%"
set "MSG=Checking the GitHub repository for the latest release..."
call :SAY
set "UPD_STATUS="
for /f "delims=" %%v in ('powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; try { $r=Invoke-RestMethod -Uri 'https://api.github.com/repos/sanguirIS/WinUtilKLENN/releases/latest' -Headers @{ 'User-Agent'='WinUtilKLENN/%VERSION%' } -TimeoutSec 15; $local=('%VERSION%'.TrimStart('v') -replace '-.*$',''); $remote=($r.tag_name.TrimStart('v') -replace '-.*$',''); $lv=[version]$local; $rv=[version]$remote; if ($rv -gt $lv) { 'NEW:'+$r.tag_name } elseif ($rv -lt $lv) { 'LOCAL' } else { 'SAME' } } catch { 'ERR' }"') do set "UPD_STATUS=%%v"
echo.
if "%UPD_STATUS%"=="SAME" goto UPD_SAME
if "%UPD_STATUS%"=="LOCAL" goto UPD_LOCAL
if "%UPD_STATUS:~0,4%"=="NEW:" goto UPD_NEW
goto UPD_ERR
:UPD_SAME
echo %R%%BGRN%%SYM_OK%%R%  %WHT%You are running the latest version%R%  %CYAN%%VERSION%%EL%
echo [%date% %time%] Update check: up to date (%VERSION%) >> "%LOGFILE%"
goto UPD_END
:UPD_LOCAL
set "SAY_COLOR=%GREEN%"
set "MSG=You are running %VERSION%, which is newer than the latest GitHub release. Nothing to update."
call :SAY
echo [%date% %time%] Update check: local version ahead of latest release >> "%LOGFILE%"
goto UPD_END
:UPD_NEW
set "UPD_NEW=%UPD_STATUS:~4%"
echo %R%%ORG%!%R%  %WHT%A newer version is available:%R%  %CYAN%%UPD_NEW%%EL%
set "SAY_COLOR=%COM%"
set "MSG=You are running %VERSION%."
call :SAY
call :ASK "Open the release page in your browser?"
if errorlevel 2 goto UPD_END
start "" "https://github.com/sanguirIS/WinUtilKLENN/releases/latest"
echo [%date% %time%] Update check: new version %UPD_NEW% >> "%LOGFILE%"
goto UPD_END
:UPD_ERR
echo %R%%RED%%SYM_NO%%R%  %WHT%Could not check for updates.%EL%
set "SAY_COLOR=%COM%"
set "MSG=Check your internet connection, or visit the releases page."
call :SAY
set "SAY_COLOR=%CYAN%"
set "MSG=  https://github.com/sanguirIS/WinUtilKLENN/releases"
call :SAY
echo [%date% %time%] Update check failed >> "%LOGFILE%"
:UPD_END
call :PAUSE
goto MENU

rem ================================================================
rem  24. CHRIS TITUS TECH WINUTIL
rem ================================================================
:WINUTIL
cls
call :HEADER "CHRIS TITUS TECH WINUTIL"
set "SAY_COLOR=%FG%"
set "MSG=Step-by-step setup of the WinUtil toolbox."
call :SAY
set "SAY_COLOR=%COM%"
set "MSG=Chris Titus Tech - github.com/ChrisTitusTech/winutil"
call :SAY
echo.
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Step 1 - Documents\PowerShell folder%EL%
call :ASK "Create it if it does not exist?"
if errorlevel 2 goto WINUTIL_STEP2
powershell.exe -NoProfile -Command "$d=Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell'; if (Test-Path $d) { Write-Host ('   Already exists: ' + $d) } else { New-Item -ItemType Directory -Path $d | Out-Null; Write-Host ('   Created: ' + $d) }"
if errorlevel 1 goto WINUTIL_STEP1FAIL
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%PowerShell folder ready.%EL%
echo.
goto WINUTIL_STEP2
:WINUTIL_STEP1FAIL
echo %R%%RED%%SYM_NO%%R%  %WHT%Could not create the folder. Check permissions.%EL%
echo.
:WINUTIL_STEP2
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Step 2 - Download winutil.ps1%EL%
set "SAY_COLOR=%COM%"
set "MSG=1 pinned release 26.08.04, or 2 latest release."
call :SAY
call :ASK "Download it into Documents\PowerShell?"
if errorlevel 2 goto WINUTIL_STEP3
echo.
call :ITEM 1 "Pinned release 26.08.04"
call :ITEM 2 "Latest release"
echo %R%%SEL%%BOLD%  Press 1 or 2.%EL%
choice /C 12 /N
if errorlevel 2 goto WINUTIL_DL_LATEST
set "WINUTIL_URL=https://github.com/ChrisTitusTech/winutil/releases/download/26.08.04/winutil.ps1"
echo %R%%CYAN%%SYM_ARROW%%R%  Downloading winutil.ps1 26.08.04...%EL%
goto WINUTIL_DL
:WINUTIL_DL_LATEST
set "WINUTIL_URL=https://github.com/ChrisTitusTech/winutil/releases/latest/download/winutil.ps1"
echo %R%%CYAN%%SYM_ARROW%%R%  Downloading winutil.ps1 latest...%EL%
:WINUTIL_DL
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $d=Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell'; New-Item -ItemType Directory -Force -Path $d | Out-Null; Invoke-WebRequest -Uri '%WINUTIL_URL%' -OutFile (Join-Path $d 'winutil.ps1') -UseBasicParsing; $f=Get-Item (Join-Path $d 'winutil.ps1'); Write-Host ('   Saved: ' + $f.FullName + '  (' + [math]::Round($f.Length/1KB,1) + ' KB)')"
if errorlevel 1 goto WINUTIL_DLFAIL
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%winutil.ps1 downloaded.%EL%
echo [%date% %time%] WinUtil script downloaded >> "%LOGFILE%"
goto WINUTIL_STEP3
:WINUTIL_DLFAIL
echo %R%%RED%%SYM_NO%%R%  %WHT%Download failed. Check the connection or the URL.%EL%
echo.
:WINUTIL_STEP3
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Step 3 - PowerShell execution policy%EL%
powershell.exe -NoProfile -Command "try { $p=(Get-ExecutionPolicy -Scope Process).ToString() } catch { $p='unknown' }; Write-Host ('   Current policy, Process scope: ' + $p); if ($p -eq 'Restricted') { Write-Host '   Policy is Restricted - a Bypass is recommended.' } elseif ($p -ne 'unknown') { Write-Host '   No change needed.' }"
call :ASK "Set execution policy Bypass for this process?"
if errorlevel 2 goto WINUTIL_STEP4
powershell.exe -NoProfile -Command "Set-ExecutionPolicy -Scope Process Bypass -Force"
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%Execution policy set to Bypass for this process.%EL%
echo.
:WINUTIL_STEP4
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Step 4 - winget install ChrisTitusTech.winutil%EL%
winget --version >nul 2>&1
if errorlevel 1 goto WINUTIL_NOWINGET
call :ASK "Run winget install for ChrisTitusTech.winutil?"
if errorlevel 2 goto WINUTIL_STEP5
call :WORK "Installing via winget"
winget install --id ChrisTitusTech.winutil -e --accept-package-agreements --accept-source-agreements
set "WG_RC=%errorlevel%"
call :WORKDONE
if not "%WG_RC%"=="0" goto WINUTIL_WINFAIL
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%WinUtil installed via winget.%EL%
echo [%date% %time%] winget install ChrisTitusTech.winutil >> "%LOGFILE%"
goto WINUTIL_STEP5
:WINUTIL_WINFAIL
echo %R%%RED%%SYM_NO%%R%  %WHT%winget could not install ChrisTitusTech.winutil.%EL%
set "SAY_COLOR=%COM%"
set "MSG=It may not be in the winget sources. Use step 2 to download the script, then step 5 to launch it."
call :SAY
echo.
goto WINUTIL_STEP5
:WINUTIL_NOWINGET
echo %R%%RED%%SYM_NO%%R%  %WHT%winget is not installed.%EL%
call :ASK "Open the Microsoft Store page for App Installer?"
if errorlevel 2 goto WINUTIL_STEP5
start "" "ms-windows-store://pdp/?productid=9NBLGGH4NNS1"
set "SAY_COLOR=%CYAN%"
set "MSG=Store page opened. Install App Installer, then run this option again."
call :SAY
echo [%date% %time%] Opened App Installer store page >> "%LOGFILE%"
echo.
:WINUTIL_STEP5
echo %R%%BWHT%%SYM_BULLET%%R%  %BOLD%Step 5 - Launch WinUtil%EL%
set "SAY_COLOR=%COM%"
set "MSG=Launch command: irm https://christitus.com/win then iex"
call :SAY
set "MSG=Close the WinUtil window to return to this menu."
call :SAY
call :ASK "Launch WinUtil now in an elevated PowerShell?"
if errorlevel 2 goto WINUTIL_END
echo %R%%CYAN%%SYM_ARROW%%R%  Launching WinUtil...%EL%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://christitus.com/win | iex"
echo [%date% %time%] WinUtil launched >> "%LOGFILE%"
:WINUTIL_END
echo.
echo %R%%BGGRN%%BLK% DONE %R%  %BGRN%WinUtil setup finished.%EL%
call :PAUSE
goto MENU

rem ================================================================
rem  EXIT
rem ================================================================
:END
cls
call :FIT
call :TOP
set "SAY_COLOR=%GREEN%"
set "MSG=  WinUtilKLENN closed. Thank you."
call :SAY
set "SAY_COLOR=%COM%"
set "MSG=  Log saved to: %LOGFILE%"
call :SAY
set "MSG=  Tip: option 23 checks for a newer version."
call :SAY
set "MSG=  WinUtilKLENN  Copyright (C) 2026 sanguirIS"
call :SAY
set "MSG=  This program comes with ABSOLUTELY NO WARRANTY."
call :SAY
set "MSG=  Free software: redistribute under the GNU GPL v3. See LICENSE."
call :SAY
call :BOT
echo [%date% %time%] Closed >> "%LOGFILE%"
endlocal
exit /b 0

rem ================================================================
rem  HELPERS
rem ================================================================

rem  Read console size. mode con is instant; PowerShell is the
rem  locale-safe fallback when the words Columns/Lines are translated.
:READSIZE
set "NOW_W="
set "NOW_H="
for /f "tokens=1,* delims=:" %%a in ('mode con 2^>nul ^| findstr /I /C:"Columns"') do set "NOW_W=%%b"
for /f "tokens=1,* delims=:" %%a in ('mode con 2^>nul ^| findstr /I /C:"Lines"') do set "NOW_H=%%b"
if defined NOW_W set "NOW_W=%NOW_W: =%"
if defined NOW_H set "NOW_H=%NOW_H: =%"
echo %NOW_W%| findstr /R "^[0-9][0-9]*$" >nul
if errorlevel 1 set "NOW_W="
echo %NOW_H%| findstr /R "^[0-9][0-9]*$" >nul
if errorlevel 1 set "NOW_H="
if defined NOW_W if defined NOW_H goto :eof
for /f "tokens=1,2 delims=|" %%a in ('powershell -NoProfile -Command "try { $u=(Get-Host).UI.RawUI.WindowSize; Write-Output ($u.Width.ToString()+[char]124+$u.Height.ToString()) } catch { Write-Output ('80'+[char]124+'40') }"') do (
    set "NOW_W=%%a"
    set "NOW_H=%%b"
)
if not defined NOW_W set "NOW_W=80"
if not defined NOW_H set "NOW_H=40"
goto :eof

rem  Box width follows the window, capped so prose stays readable.
:METRICS
set /a BOX_W=NOW_W-1
if %BOX_W% GTR 120 set BOX_W=120
if %BOX_W% LSS 12 set BOX_W=12
set /a RULE_NEED=BOX_W-2
if %RULE_NEED% LSS 8 set RULE_NEED=8
set /a INNER=BOX_W-4
if %INNER% LSS 8 set INNER=8
set "WUK_W=%INNER%"
set "CON_WIDTH=%BOX_W%"
goto :eof

rem  Reflow every screen. Refit the font only when the window is
rem  extremely narrow or extremely wide, so a normal drag just wraps.
:FIT
call :READSIZE
if %NOW_W% LSS 60 if not "%FONT_HOLD%"=="S" goto FIT_SHRINK
if %NOW_W% GTR 150 if not "%FONT_HOLD%"=="G" goto FIT_GROW
goto FIT_METRICS
:FIT_SHRINK
set "WUK_FONTDIR=S"
call :SETFONT
set "FONT_HOLD=S"
call :WINSIZE
call :READSIZE
goto FIT_METRICS
:FIT_GROW
set "WUK_FONTDIR=G"
call :SETFONT
set "FONT_HOLD=G"
call :WINSIZE
call :READSIZE
goto FIT_METRICS
:FIT_METRICS
if %NOW_W% GEQ 60 if %NOW_W% LEQ 150 set "FONT_HOLD="
call :METRICS
call :BUILDRULES
set "VBAR=%SYM_V%"
call :LOGSIZE
goto :eof
:FITCHECK
goto FIT

:LOGSIZE
if "%NOW_W%"=="%LAST_LOG_W%" if "%NOW_H%"=="%LAST_LOG_H%" goto :eof
set "LAST_LOG_W=%NOW_W%"
set "LAST_LOG_H=%NOW_H%"
echo [%date% %time%] Window %NOW_W%x%NOW_H% box %BOX_W% theme Dracula >> "%LOGFILE%"
goto :eof

:BUILDRULES
if not defined SYM_H set "SYM_H=-"
if not defined RULE_NEED set "RULE_NEED=70"
setlocal EnableDelayedExpansion
set "HL=0"
:HL_LOOP
if "!SYM_H:~%HL%,1!"=="" goto HL_DONE
set /a HL+=1
if !HL! GTR 3 goto HL_DONE
goto HL_LOOP
:HL_DONE
endlocal & set "HL=%HL%"
if not "%HL%"=="1" goto BOX_ASCII
goto BOX_BUILD
:BOX_ASCII
set "SYM_H=-"
set "SYM_V=:"
set "BOX_TL=+"
set "BOX_TR=+"
set "BOX_BL=+"
set "BOX_BR=+"
set "BOX_ML=+"
set "BOX_MR=+"
:BOX_BUILD
setlocal EnableDelayedExpansion
set "RULE=!SYM_H!"
set "RL=1"
:BR_DBL
if !RL! GEQ !RULE_NEED! goto BR_CUT
set "RULE=!RULE!!RULE!"
set /a RL*=2
if !RL! GTR 512 goto BR_CUT
goto BR_DBL
:BR_CUT
set "RULE=!RULE:~0,%RULE_NEED%!"
endlocal & set "RULE=%RULE%"
goto :eof

:SPACES
set "SPACES= "
setlocal EnableDelayedExpansion
set "SL=1"
:SP_DBL
if !SL! GEQ 200 goto SP_DONE
set "SPACES=!SPACES!!SPACES!"
set /a SL*=2
goto SP_DBL
:SP_DONE
endlocal & set "SPACES=%SPACES%"
goto :eof

:TOP
echo.%R%%VCOL%%BOX_TL%%RULE%%BOX_TR%%EL%
goto :eof
:MID
echo.%R%%VCOL%%BOX_ML%%RULE%%BOX_MR%%EL%
goto :eof
:BOT
echo.%R%%VCOL%%BOX_BL%%RULE%%BOX_BR%%EL%
goto :eof

:HEADER
call :FIT
call :TOP
set "SAY_COLOR=%PINK%"
set "MSG=  %~1"
call :SAY
set "SAY_COLOR=%FG%"
call :MID
goto :eof

:PAUSE
echo.
call :BOT
call :KEY
goto :eof
:KEY
echo %R%%COM%  Press any key to continue...%EL%
pause >nul
goto :eof

rem  Ask Y/N. Caller must read errorlevel immediately. 2 means No.
:ASK
set "MSG=%~1  [Y/N]"
set "SAY_COLOR=%ORG%"
call :SAY
set "SAY_COLOR=%FG%"
choice /C YN /N
goto :eof

:ITEM
set "INUM=%~1"
set "ILAB=%~2"
if "%INUM:~1%"=="" set "INUM= %INUM%"
set "MSG=   %INUM%  %SYM_ARROW%  %ILAB%"
set "SAY_COLOR=%FG%"
call :SAY
goto :eof

rem  Word-wrap MSG or %1 to the inner box width, then draw both borders.
:SAY
if not "%~1"=="" set "SAY_TXT=%~1"
if "%~1"=="" set "SAY_TXT=%MSG%"
if not defined SAY_TXT goto :eof
if not defined SAY_COLOR set "SAY_COLOR=%FG%"
if not defined INNER set "INNER=72"
setlocal EnableDelayedExpansion
set "SAY_TXT=!SAY_TXT:&=and!"
set "SAY_TXT=!SAY_TXT:|= !"
set "SAY_TXT=!SAY_TXT:>= !"
set "SAY_TXT=!SAY_TXT:<= !"
:SAY_LOOP
if "!SAY_TXT!"=="" goto SAY_DONE
set "SAY_I=0"
:SAY_CLEN
if "!SAY_TXT:~%SAY_I%,1!"=="" goto SAY_CLEN_DONE
set /a SAY_I+=1
if !SAY_I! GTR 500 goto SAY_CLEN_DONE
goto SAY_CLEN
:SAY_CLEN_DONE
if !SAY_I! GTR !INNER! goto SAY_NEEDCUT
set "SAY_LINE=!SAY_TXT!"
call :ROW
goto SAY_DONE
:SAY_NEEDCUT
set /a SAY_CUT=!INNER!
:SAY_SP
if !SAY_CUT! LEQ 12 goto SAY_HARD
if "!SAY_TXT:~%SAY_CUT%,1!"==" " goto SAY_SPLIT
set /a SAY_CUT-=1
goto SAY_SP
:SAY_HARD
set /a SAY_CUT=!INNER!
if !SAY_CUT! LSS 1 set "SAY_CUT=1"
:SAY_SPLIT
set "SAY_LINE=!SAY_TXT:~0,%SAY_CUT%!"
call :ROW
set "SAY_TXT=!SAY_TXT:~%SAY_CUT%!"
if "!SAY_TXT:~0,1!"==" " set "SAY_TXT=!SAY_TXT:~1!"
if "!SAY_TXT!"=="" goto SAY_DONE
goto SAY_LOOP
:SAY_DONE
endlocal
goto :eof

:ROW
setlocal EnableDelayedExpansion
if not defined SAY_COLOR set "SAY_COLOR=%FG%"
set "LL=0"
:ROWL
if "!SAY_LINE:~%LL%,1!"=="" goto ROWL_DONE
set /a LL+=1
if !LL! GTR 400 goto ROWL_DONE
goto ROWL
:ROWL_DONE
set /a NEED=INNER-LL
if !NEED! LSS 0 set "NEED=0"
set "PAD=!SPACES:~0,%NEED%!"
echo.%R%%VCOL%%VBAR%%R% !SAY_COLOR!!SAY_LINE!!PAD! %VCOL%%VBAR%%EL%
endlocal
goto :eof

:BOOT
cls
call :FIT
call :TOP
set "SAY_COLOR=%PINK%"
set "MSG=  WINUTILKLENN"
call :SAY
set "SAY_COLOR=%CYAN%"
set "MSG=  %THEME% theme    %VERSION%"
call :SAY
set "SAY_COLOR=%COM%"
set "MSG=  Preparing diagnostics and repair tools..."
call :SAY
call :BOT
if /i "%WINUTIL_TEST%"=="1" goto :eof
timeout /t 1 /nobreak >nul
goto :eof

:THEME
powershell.exe -NoProfile -Command "Add-Type -MemberDefinition '[System.Runtime.InteropServices.DllImport(''kernel32.dll'')] public static extern System.IntPtr GetStdHandle(int h); [System.Runtime.InteropServices.DllImport(''kernel32.dll'')] public static extern bool GetConsoleMode(System.IntPtr h, out uint m); [System.Runtime.InteropServices.DllImport(''kernel32.dll'')] public static extern bool SetConsoleMode(System.IntPtr h, uint m);' -Name VT -Namespace WkVT; $h=[WkVT.VT]::GetStdHandle(-11); $m=0; [void][WkVT.VT]::GetConsoleMode($h,[ref]$m); [void][WkVT.VT]::SetConsoleMode($h,($m -bor 4))" >nul 2>&1
powershell.exe -NoProfile -Command "Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;public class WkPal{[StructLayout(LayoutKind.Sequential)]public struct COORD{public short X;public short Y;}[StructLayout(LayoutKind.Sequential)]public struct SMALL_RECT{public short L;public short T;public short R;public short B;}[StructLayout(LayoutKind.Sequential)]public struct CSI{public uint cb;public COORD sz;public COORD cur;public ushort attr;public SMALL_RECT win;public COORD max;public ushort pop;public int full;[MarshalAs(UnmanagedType.ByValArray,SizeConst=16)]public uint[] col;}[DllImport(''kernel32.dll'',SetLastError=true)]public static extern System.IntPtr GetStdHandle(int h);[DllImport(''kernel32.dll'',SetLastError=true)]public static extern bool GetConsoleScreenBufferInfoEx(System.IntPtr h,ref CSI i);[DllImport(''kernel32.dll'',SetLastError=true)]public static extern bool SetConsoleScreenBufferInfoEx(System.IntPtr h,ref CSI i);}'; $h=[WkPal]::GetStdHandle(-11); $i=New-Object WkPal+CSI; $i.cb=96; $i.col=[uint32[]]::new(16); [void][WkPal]::GetConsoleScreenBufferInfoEx($h,[ref]$i); $i.cb=96; $i.win.R=$i.win.R+1; $i.win.B=$i.win.B+1; $p=@(0x00362A28,0x00F993BD,0x007BFA50,0x00FDE98B,0x005555FF,0x00C679FF,0x008CFAF1,0x00F2F8F8,0x005A4744,0x00FFACD6,0x0094FF69,0x00FFFFA4,0x006E6EFF,0x00DF92FF,0x00A5FFFF,0x00FFFFFF); for($n=0;$n -lt 16;$n++){ $i.col[$n]=[uint32]$p[$n] }; [void][WkPal]::SetConsoleScreenBufferInfoEx($h,[ref]$i)" >nul 2>&1
color 07
call :OSC
goto :eof
:OSC
powershell.exe -NoProfile -Command "[Console]::Out.Write(([char]27)+']10;#F8F8F2'+([char]27)+[char]92); [Console]::Out.Write(([char]27)+']11;#282A36'+([char]27)+[char]92); [Console]::Out.Write(([char]27)+']12;#FF79C6'+([char]27)+[char]92)"
goto :eof

:SETFONT
powershell.exe -NoProfile -Command "$ErrorActionPreference='SilentlyContinue'; try { if(-not ('WkFont' -as [type])) { Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;public class WkFont{[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)]public struct CF{public int cb;public uint n;public short x;public short y;public int fam;public int wt;[MarshalAs(UnmanagedType.ByValTStr,SizeConst=32)]public string face;}[DllImport(''kernel32.dll'')]public static extern System.IntPtr GetStdHandle(int h);[DllImport(''user32.dll'')]public static extern int GetSystemMetrics(int i);[DllImport(''kernel32.dll'',CharSet=CharSet.Unicode)]public static extern bool GetCurrentConsoleFontEx(System.IntPtr h,bool m,ref CF f);[DllImport(''kernel32.dll'',CharSet=CharSet.Unicode)]public static extern bool SetCurrentConsoleFontEx(System.IntPtr h,bool m,ref CF f);}' } } catch {} $h=[WkFont]::GetStdHandle(-11); $f=New-Object WkFont+CF; $f.cb=[Runtime.InteropServices.Marshal]::SizeOf($f); [void][WkFont]::GetCurrentConsoleFontEx($h,$false,[ref]$f); $sw=[WkFont]::GetSystemMetrics(16); $sh=[WkFont]::GetSystemMetrics(17); if($sw -lt 640){$sw=1280}; if($sh -lt 480){$sh=720}; $y=[int]$f.y; if($y -lt 8){$y=16}; $dir=$env:WUK_FONTDIR; if($dir -eq 'S'){$y=$y-2} elseif($dir -eq 'G'){$y=$y+2} else { $y=[Math]::Max(13,[Math]::Min(18,[int]($sh/52))) }; if($y -lt 12){$y=12}; if($y -gt 20){$y=20}; $x=[Math]::Max(6,[int]($y/2)); if([string]::IsNullOrEmpty($f.face)){$f.face='Consolas'}; $f.x=[int16]$x; $f.y=[int16]$y; $f.wt=400; [void][WkFont]::SetCurrentConsoleFontEx($h,$false,[ref]$f); Write-Output $y" >nul 2>&1
goto :eof
:WINSIZE
powershell.exe -NoProfile -Command "$ErrorActionPreference='SilentlyContinue'; $ui=(Get-Host).UI.RawUI; $max=$ui.MaxWindowSize; $ww=[Math]::Max(72,[Math]::Min(104,$max.Width)); $wh=[Math]::Max(28,[Math]::Min(50,$max.Height)); $cur=$ui.WindowSize; if($cur.Width -gt $ww){$cur.Width=$ww; $ui.WindowSize=$cur}; if($cur.Height -gt $wh){$cur.Height=$wh; $ui.WindowSize=$cur}; $b=$ui.BufferSize; if($b.Width -lt $ww){$b.Width=$ww}; $b.Height=2000; try{$ui.BufferSize=$b}catch{}; $w=$ui.WindowSize; $w.Width=$ww; $w.Height=$wh; try{$ui.WindowSize=$w}catch{}; Write-Output ($w.Width.ToString()+'|'+$w.Height.ToString())" >nul 2>&1
goto :eof
:RESIZE
set "WUK_FONTDIR=F"
call :SETFONT
call :WINSIZE
call :FIT
goto :eof
:RESIZE_MAX
powershell.exe -NoProfile -Command "$ErrorActionPreference='SilentlyContinue'; $ui=(Get-Host).UI.RawUI; $max=$ui.MaxWindowSize; $b=$ui.BufferSize; $cur=$ui.WindowSize; if($cur.Width -gt $max.Width){$cur.Width=$max.Width}; if($cur.Height -gt $max.Height){$cur.Height=$max.Height}; $ui.WindowSize=$cur; if($b.Width -lt $max.Width){$b.Width=$max.Width}; if($b.Height -lt 2000){$b.Height=2000}; try{$ui.BufferSize=$b}catch{}; $w=$ui.WindowSize; $w.Width=$max.Width; $w.Height=$max.Height; try{$ui.WindowSize=$w}catch{}; Write-Output 'max'" >nul 2>&1
goto :eof
:GLYPHS
for /f "tokens=1-13 delims=|" %%a in ('powershell -NoProfile -Command "$ErrorActionPreference='SilentlyContinue'; [Console]::OutputEncoding=New-Object Text.UTF8Encoding $false; $h=[char]0x2500; $v=[char]0x2502; $a=[char]0x25BA; $o=[char]0x2713; $x=[char]0x2717; $b=[char]0x25CF; $s=[char]0x2605; $tl=[char]0x256D; $tr=[char]0x256E; $bl=[char]0x2570; $br=[char]0x256F; $ml=[char]0x251C; $mr=[char]0x2524; Write-Output ($a.ToString()+'|'+$o.ToString()+'|'+$x.ToString()+'|'+$b.ToString()+'|'+$s.ToString()+'|'+$h.ToString()+'|'+$v.ToString()+'|'+$tl.ToString()+'|'+$tr.ToString()+'|'+$bl.ToString()+'|'+$br.ToString()+'|'+$ml.ToString()+'|'+$mr.ToString())"') do (
    set "SYM_ARROW=%%a"
    set "SYM_OK=%%b"
    set "SYM_NO=%%c"
    set "SYM_BULLET=%%d"
    set "SYM_STAR=%%e"
    set "SYM_H=%%f"
    set "SYM_V=%%g"
    set "BOX_TL=%%h"
    set "BOX_TR=%%i"
    set "BOX_BL=%%j"
    set "BOX_BR=%%k"
    set "BOX_ML=%%l"
    set "BOX_MR=%%m"
)
if not defined SYM_V set "SYM_V=:"
set "VBAR=%SYM_V%"
goto :eof

:WORK
echo %R%%CYAN%%SYM_ARROW%%R%  %FG%%~1...%EL%
goto :eof
:WORKDONE
echo %R%%GREEN%%SYM_OK%%R%  %GREEN%done.%EL%
goto :eof
:SPINNER
call :WORK "%~2"
goto :eof
:SPINSTOP
call :WORKDONE
goto :eof

rem  Keep digits only so menu input cannot inject commands.
:SANITIZE
setlocal EnableDelayedExpansion
set "OUT="
set "I=0"
:SAN_LOOP
set "CH=!CHOICE:~%I%,1!"
if "!CH!"=="" goto SAN_DONE
if "!CH!"=="0" set "OUT=!OUT!0"
if "!CH!"=="1" set "OUT=!OUT!1"
if "!CH!"=="2" set "OUT=!OUT!2"
if "!CH!"=="3" set "OUT=!OUT!3"
if "!CH!"=="4" set "OUT=!OUT!4"
if "!CH!"=="5" set "OUT=!OUT!5"
if "!CH!"=="6" set "OUT=!OUT!6"
if "!CH!"=="7" set "OUT=!OUT!7"
if "!CH!"=="8" set "OUT=!OUT!8"
if "!CH!"=="9" set "OUT=!OUT!9"
set /a I+=1
if !I! GEQ 8 goto SAN_DONE
goto SAN_LOOP
:SAN_DONE
endlocal & set "CHOICE=%OUT%"
goto :eof
:SHOWBAD
echo %R%%RED%  Invalid selection: %CHOICE%%EL%
goto :eof

rem  Stop a service and wait until it is STOPPED, up to 12 seconds.
:WAITSTOP
set "WS_NAME=%~1"
set /a WS_I=0
:WS_LOOP
sc query "%WS_NAME%" 2>nul | findstr /C:": 1  " >nul
if not errorlevel 1 goto :eof
sc stop "%WS_NAME%" >nul 2>&1
timeout /t 1 /nobreak <nul >nul
set /a WS_I+=1
if %WS_I% LSS 12 goto WS_LOOP
goto :eof

rem  Rename a cache folder to name.old. RN_OK=1 on success or if missing.
:RENAMEONE
set "RN_SRC=%~1"
set "RN_DST=%~2"
set "RN_OK=0"
if not exist "%RN_SRC%" set "RN_OK=1"
if "%RN_OK%"=="1" goto :eof
if exist "%RN_SRC%.old" rd /s /q "%RN_SRC%.old" >nul 2>&1
ren "%RN_SRC%" "%RN_DST%" >nul 2>&1
if exist "%RN_SRC%" goto :eof
if exist "%RN_SRC%.old" set "RN_OK=1"
goto :eof

:SVCSTATUS
set "SVCSVC=%~1"
set "SVCLABEL=%~2"
set "SVCSTATE="
sc query "%SVCSVC%" >nul 2>&1
if errorlevel 1 goto SVCNF
for /f "tokens=4" %%a in ('sc query "%SVCSVC%" 2^>nul ^| findstr /C:"STATE"') do set "SVCSTATE=%%a"
if /i "%SVCSTATE%"=="RUNNING" goto SVC_OK
if /i "%SVCSTATE%"=="STOPPED" goto SVC_STOPPED
sc query "%SVCSVC%" 2>nul | findstr /C:": 4  " >nul && goto SVC_OK
sc query "%SVCSVC%" 2>nul | findstr /C:": 1  " >nul && goto SVC_STOPPED
goto SVC_UNKNOWN
:SVCNF
echo %R%%BGYLW%%BLK% ? %R%  %YLW%%SVCLABEL%%R%  %DIM%service not found%EL%
goto :eof
:SVC_STOPPED
echo %R%%BGRED%%WHT% STOPPED %R%  %RED%%SYM_NO%%R%  %BWHT%%SVCLABEL%%EL%
goto :eof
:SVC_OK
echo %R%%BGGRN%%BLK% RUNNING %R%  %BGRN%%SYM_OK%%R%  %BWHT%%SVCLABEL%%EL%
goto :eof
:SVC_UNKNOWN
echo %R%%BGYLW%%BLK% ? %R%  %YLW%%SVCLABEL%%R%  %DIM%state unknown%EL%
goto :eof

:CHECKSVC
sc query "%~1" 2>nul | findstr /C:": 4  " >nul
if errorlevel 1 goto CS_FAIL
echo %R%%BGRN%%SYM_OK%%R%  %BWHT%%~2%R%  %GRN%is running%EL%
goto :eof
:CS_FAIL
echo %R%%RED%%SYM_NO%%R%  %BWHT%%~2%R%  %DIM%not running%EL%
goto :eof

:VERDICT
if /i "%~1"=="FIXED" goto VERDICT_OK
echo %R%%BGRED%%WHT% NOT FIXED %R%
set "MSG=%~2"
set "SAY_COLOR=%RED%"
call :SAY
set "SAY_COLOR=%FG%"
goto :eof
:VERDICT_OK
echo %R%%BGGRN%%BLK% FIXED %R%
set "MSG=%~2"
set "SAY_COLOR=%GREEN%"
call :SAY
set "SAY_COLOR=%FG%"
goto :eof

:RESTARTNOTE
if /i "%~1"=="YES" goto RESTART_YES
set "SAY_COLOR=%GREEN%"
set "MSG=No restart needed. The fix is active now."
call :SAY
set "SAY_COLOR=%FG%"
goto :eof
:RESTART_YES
set "SAY_COLOR=%ORG%"
set "MSG=A restart is required to apply the changes."
call :SAY
set "SAY_COLOR=%FG%"
goto :eof

:REBOOTCHECK
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$p=@('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'); $any=$false; foreach($x in $p){ if(Test-Path $x){ $any=$true } }; if($any){ Write-Host '   Pending restart detected.'; exit 1 } else { Write-Host '   No pending restart detected.'; exit 0 }"
goto :eof

:SECLOGROTATE
if not exist "%LOGFILE%" goto :eof
for %%s in ("%LOGFILE%") do if %%~zs GTR 524288 (
    if exist "%LOGFILE%.old" del /q "%LOGFILE%.old" >nul 2>&1
    move /y "%LOGFILE%" "%LOGFILE%.old" >nul 2>&1
)
goto :eof

rem  Ensure an npm tool is installed. %1 package, %2 binary, %3 label.
:NPMSETUP
where npm >nul 2>&1
if errorlevel 1 goto NPM_MISSING
where "%~2" >nul 2>&1
if errorlevel 1 goto NPM_INSTALL
echo %R%%BGRN%%SYM_OK%%R%  %WHT%%~3%R%  %GRN%already installed.%EL%
echo [%date% %time%] NPM setup: %~3 found and ready >> "%LOGFILE%"
exit /b 0
:NPM_INSTALL
echo %R%%ORG%!%R%  %WHT%%~3%R%  %DIM%is not installed yet%EL%
call :ASK "Install it globally with npm now?"
if errorlevel 2 goto NPM_CANCEL
echo %R%%CYAN%%SYM_ARROW%%R%  Installing %~1 ...%EL%
echo [%date% %time%] NPM setup: installing %~1 >> "%LOGFILE%"
npm install -g "%~1"
if errorlevel 1 goto NPM_INSTALL_FAIL
where "%~2" >nul 2>&1
if errorlevel 1 goto NPM_INSTALL_FAIL
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%%~3%R%  %WHT%installed.%EL%
echo [%date% %time%] NPM setup: %~3 installed >> "%LOGFILE%"
exit /b 0
:NPM_CANCEL
echo [%date% %time%] NPM setup: user cancelled %~3 >> "%LOGFILE%"
exit /b 1
:NPM_INSTALL_FAIL
echo %R%%RED%%SYM_NO%%R%  %WHT%Install failed. Check the internet connection.%EL%
echo [%date% %time%] NPM setup: failed to install %~3 >> "%LOGFILE%"
exit /b 1
:NPM_MISSING
echo %R%%RED%%SYM_NO%%R%  %WHT%npm / Node.js was not found.%EL%
call :ASK "Install Node.js LTS with winget now?"
if errorlevel 2 goto NPM_NODE_CANCEL
call :WORK "Installing Node.js LTS"
echo [%date% %time%] NPM setup: installing Node.js LTS >> "%LOGFILE%"
winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements
call :WORKDONE
call :REFRESHPATH
where npm >nul 2>&1
if errorlevel 1 goto NPM_NODE_FAIL
echo %R%%BGGRN%%BLK% OK %R%  %BGRN%Node.js installed. npm is ready.%EL%
echo [%date% %time%] NPM setup: Node.js installed >> "%LOGFILE%"
goto NPM_INSTALL
:NPM_NODE_CANCEL
echo [%date% %time%] NPM setup: user cancelled Node.js >> "%LOGFILE%"
exit /b 1
:NPM_NODE_FAIL
echo %R%%RED%%SYM_NO%%R%  %WHT%Node.js could not be installed automatically.%EL%
set "SAY_COLOR=%COM%"
set "MSG=Install it from https://nodejs.org and then run this option again."
call :SAY
echo [%date% %time%] NPM setup: failed to install Node.js >> "%LOGFILE%"
exit /b 1

:REFRESHPATH
set "NEWPATH="
for /f "delims=" %%P in ('powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')"') do set "NEWPATH=%%P"
if defined NEWPATH set "PATH=%NEWPATH%"
goto :eof

rem  Upgrade one winget package. Id first, then Name. Counts WG_OK/WG_FAIL.
:WGUPGRADE
echo.
echo %R%%CYAN%%SYM_ARROW%%R%  %BOLD%Upgrading %~1%EL%
winget upgrade --id "%~1" -e --accept-package-agreements --accept-source-agreements
if %errorlevel%==0 goto WGUP_OK
echo %R%%ORG%!%R%  %WHT%No exact Id match. Retrying as a Name: %~1%EL%
winget upgrade --name "%~1" --accept-package-agreements --accept-source-agreements
if %errorlevel%==0 goto WGUP_OK
echo %R%%RED%%SYM_NO%%R%  %WHT%Could not upgrade %~1%EL%
set /a WG_FAIL+=1
goto :eof
:WGUP_OK
echo %R%%BGRN%%SYM_OK%%R%  %WHT%Upgraded %~1%EL%
set /a WG_OK+=1
goto :eof
