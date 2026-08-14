@echo off
rem ================================================================
rem  WinUtilKLENN - Diagnostics and guided repair tools for Windows 10/11.
rem  Copyright (C) 2026 sanguirIS (https://github.com/sanguirIS)
rem
rem  This program is free software: you can redistribute it and/or modify
rem  it under the terms of the GNU General Public License as published by
rem  the Free Software Foundation, either version 3 of the License, or
rem  (at your option) any later version.
rem
rem  This program is distributed in the hope that it will be useful,
rem  but WITHOUT ANY WARRANTY; without even the implied warranty of
rem  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem  GNU General Public License for more details.
rem
rem  You should have received a copy of the GNU General Public License
rem  along with this program.  If not, see <https://www.gnu.org/licenses/>.
rem ================================================================
chcp 65001 >nul
setlocal EnableExtensions
title WinUtilKLENN
color 0F

rem ================================================================
rem  WINUTILKLENN   (v2.7.1)
rem  Diagnostics and guided repair tools for Windows 10 / 11.
rem  Run as Administrator for full functionality.
rem ================================================================
rem  CHANGELOG
rem  v2.7.1 - Bug fixes and improvements:
rem         - Fixed version comparison logic in update check to properly
rem           handle all version number formats (x.y.z)
rem         - Improved error handling in Node.js and npm tool installation
rem         - Updated GitHub API user-agent for better compatibility
rem  v2.7.0 - New tools:
rem         - Added "winget Upgrade" (16): lists and upgrades all winget
rem           packages, with a verdict and a pending-reboot check.
rem         - Added "yoinks" (17): download videos from YouTube, X,
rem           Instagram, TikTok and 1,800+ other sites (npm tool).
rem         - Added "ghgrab" (18): browse and download files, folders or
rem           release assets from GitHub repos without cloning (npm tool).
rem         - Added "Freebuff - AI Agent" (19): the free AI coding agent
rem           CLI from freebuff.com (npm tool).
rem         - Options 17-19 auto-install their npm tool on first use if
rem           it is missing (Node.js via winget if npm is not present),
rem           then launch it directly.
rem         - Menu renumbered sequentially to 1-24 + Exit.
rem  v2.6.0 - Version and maintenance features:
rem         - Added "Check for Updates" (option 19): compares the
rem           installed version with the latest GitHub release and
rem           offers to open the release page.
rem         - Added a MAINTENANCE section: Disk Cleanup (12), Restore
rem           Point (13), Battery Report (14), Restart / Shutdown (15).
rem         - The version now lives in one VERSION variable used by
rem           the menu badge and the update check.
rem         - Small wording fixes in on-screen messages.
rem  v2.5.0 - Polish pass:
rem         - Option 11 label shortened to "BITS" so it matches its
rem           screen header and the section title.
rem         - Log-path line spacing unified across screens.
rem         - No menu changes or new options in this release.
rem  v2.4.3 - Buffer height matches the window:
rem         - Screen buffer height is now 50 rows (the same as the
rem           window height) instead of 9000, so scrollback mirrors
rem           the visible window exactly.
rem  v2.4.2 - Resize tuning:
rem         - Window height cap raised from 40 to 50 rows so the
rem           window auto-fits more of a tall screen. Width cap stays
rem           at 68 columns and the 9000-row buffer is unchanged.
rem  v2.4.1 - Licensing and polish fixes:
rem         - Added the GPL-3.0 header and the warranty notice (menu
rem           and exit screens), as required by the license.
rem         - Startup resize now runs after the log directory exists,
rem           so the applied window size is logged on first launch too.
rem         - Screen headers shortened (RULE_SMALL 40 to 36 chars) so
rem           long titles fit the 68-column window without wrapping.
rem         - Option 15: WinUtil download labels shortened to prevent
rem           the long URLs from wrapping at 68 columns.
rem  v2.4 - The console window now auto-sizes: it grows to the largest
rem         size that fits the current screen and console font (capped
rem         at 68x50) so the 66-char border always fits on a single
rem         line. The size is re-applied after every screen so the
rem         window snaps back if dragged mid-session, and the applied
rem         size is logged on each screen.
rem  v2.3 - Added "Chris Titus Tech WinUtil" (option 15): step-by-step
rem         setup - create Documents\PowerShell, download winutil.ps1
rem         (pinned 26.08.04 or latest), execution policy check, winget
rem         install --id ChrisTitusTech.winutil, and launch via irm
rem         christitus.com/win | iex.
rem  v2.2 - Added "DNS Flush" (option 5) under CONNECTIVITY.
rem       - Added "Graphics Driver Reset" (option 9) under DEVICES using
rem         pnputil /restart-device on each active display adapter.
rem       - Menu renumbered sequentially to 1-14 + Exit.
rem  v2.1.1 - Fixed critical elevation bug: when already running as
rem         Administrator the script fell through into the "Elevation
rem         cancelled" block instead of showing the menu, so the menu
rem         was never reachable. Added "goto MENU" after the elevation
rem         check and moved the "Started" log line so it actually runs.
rem  v2.1 - Removed the Essential Tweaks menu and all tweak routines.
rem       - Menu options renumbered sequentially (1-12 + Exit).
rem       - MEDIA section moved to the top of the menu.
rem       - Code sections physically reordered to match the menu.
rem       - Friendly exit message if the UAC elevation prompt is cancelled.

set "LOGDIR=%ProgramData%\WinUtilKLENN"
set "LOGFILE=%LOGDIR%\WinUtilKLENN.log"
set "VERSION=v2.7.1"

if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1

rem ------- Auto-size console window (fits the 66-char border) --------
rem  Runs before the UAC prompt and after every screen (cls) so the
rem  window snaps back to its fitted size if the user drags it.
rem  The applied size is logged on every call.
call :RESIZE

rem ------- ANSI colour engine ---------------------------------------
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "R=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "DIM=%ESC%[2m"
set "BLK=%ESC%[30m"
set "RED=%ESC%[31m"
set "GRN=%ESC%[32m"
set "YLW=%ESC%[33m"
set "CYN=%ESC%[36m"
set "WHT=%ESC%[37m"
set "BRED=%ESC%[91m"
set "BGRN=%ESC%[92m"
set "BYLW=%ESC%[93m"
set "BCYN=%ESC%[96m"
set "BWHT=%ESC%[97m"
set "BGRED=%ESC%[41m"
set "BGGRN=%ESC%[42m"
set "BGYLW=%ESC%[43m"
set "BGBLU=%ESC%[44m"

rem ------- Icons and rules (generated at runtime) --------------------
rem  NOTE: the file itself is pure ASCII. cmd misparses multi-byte
rem  characters that are stored inside the file, so all glyphs are
rem  created here by PowerShell and kept in variables.
for /f "tokens=1-6 delims=|" %%a in ('powershell -NoProfile -Command "$h=[char]0x2500;$a=[char]0x25BA;$o=[char]0x2713;$x=[char]0x2717;$b=[char]0x25CF; Write-Output ($a+'|'+$o+'|'+$x+'|'+$b+'|'+($h.ToString()*66)+'|'+($h.ToString()*36))"') do (
    set "SYM_ARROW=%%a"
    set "SYM_OK=%%b"
    set "SYM_NO=%%c"
    set "SYM_BULLET=%%d"
    set "RULE_BIG=%%e"
    set "RULE_SMALL=%%f"
)

rem ------- Optional test mode (skip elevation) -----------------------
rem  Set WINUTIL_TEST=1 to run the menu without the UAC prompt.
rem  Useful for smoke tests; no system changes are made.
if /i "%WINUTIL_TEST%"=="1" goto MENU
rem ------- Self-elevate so repair actions can run --------------------
net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo.
    echo  %BYLW%!%R%  %BWHT%Administrator permission is required.%R%
    echo  %CYN%-%R%  %WHT%Please accept the UAC prompt, the tool restarts elevated...%R%
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
    if errorlevel 1 goto UAC_CANCELLED
    exit /b
)
echo [%date% %time%] Started >> "%LOGFILE%"
goto MENU

:UAC_CANCELLED
echo.
echo  %BYLW%!%R%  %WHT%Elevation cancelled - no changes were made.%R%
echo  %CYN%-%R%  %WHT%Some repair options need Administrator rights.%R%
echo  %CYN%-%R%  %WHT%Right-click this script and select %BOLD%"Run as administrator"%R%  %WHT%to use them.%R%
echo.
pause
exit /b

:MENU
cls
call :RESIZE
echo.
echo  %RULE_BIG%
echo  %BOLD%%BWHT%   WINUTILKLENN%R%
echo  %BCYN%      Diagnostics and Repair  %SYM_BULLET%  Windows 10 / 11  [ %VERSION% ]%R%
echo  %RULE_BIG%
echo.
echo  %BOLD%%CYN%  MEDIA%R%
echo     %BCYN%%BOLD%1%R%  %SYM_ARROW%  %WHT%Audio%R%
echo     %BCYN%%BOLD%2%R%  %SYM_ARROW%  %WHT%Video Playback%R%
echo     %BCYN%%BOLD%3%R%  %SYM_ARROW%  %WHT%Windows Media Player%R%
echo.
echo  %BOLD%%CYN%  CONNECTIVITY%R%
echo     %BCYN%%BOLD%4%R%  %SYM_ARROW%  %WHT%Network and Internet%R%
echo     %BCYN%%BOLD%5%R%  %SYM_ARROW%  %WHT%DNS Flush%R%
echo     %BCYN%%BOLD%6%R%  %SYM_ARROW%  %WHT%Bluetooth%R%
echo.
echo  %BOLD%%CYN%  DEVICES%R%
echo     %BCYN%%BOLD%7%R%  %SYM_ARROW%  %WHT%Printer%R%
echo     %BCYN%%BOLD%8%R%  %SYM_ARROW%  %WHT%Camera%R%
echo     %BCYN%%BOLD%9%R%  %SYM_ARROW%  %WHT%Graphics Driver Reset%R%
echo.
echo  %BOLD%%CYN%  WINDOWS UPDATE%R%
echo    %BCYN%%BOLD%10%R%  %SYM_ARROW%  %WHT%Windows Update%R%
echo    %BCYN%%BOLD%11%R%  %SYM_ARROW%  %WHT%BITS%R%
echo.
echo  %BOLD%%CYN%  MAINTENANCE%R%
echo    %BCYN%%BOLD%12%R%  %SYM_ARROW%  %WHT%Disk Cleanup%R%
echo    %BCYN%%BOLD%13%R%  %SYM_ARROW%  %WHT%Restore Point%R%
echo    %BCYN%%BOLD%14%R%  %SYM_ARROW%  %WHT%Battery Report%R%
echo    %BCYN%%BOLD%15%R%  %SYM_ARROW%  %WHT%Restart / Shutdown%R%
echo    %BCYN%%BOLD%16%R%  %SYM_ARROW%  %WHT%winget Upgrade%R%
echo.
echo  %BOLD%%CYN%  OTHER / TOOLS%R%
echo    %BCYN%%BOLD%17%R%  %SYM_ARROW%  %WHT%Yoinks - Video Downloader%R%
echo    %BCYN%%BOLD%18%R%  %SYM_ARROW%  %WHT%ghgrab - GitHub Downloader%R%
echo    %BCYN%%BOLD%19%R%  %SYM_ARROW%  %WHT%Freebuff - AI Agent%R%
echo    %BCYN%%BOLD%20%R%  %SYM_ARROW%  %WHT%Program Compatibility%R%
echo    %BCYN%%BOLD%21%R%  %SYM_ARROW%  %WHT%Run ALL Diagnostics%R%
echo    %BCYN%%BOLD%22%R%  %SYM_ARROW%  %WHT%System Summary%R%
echo    %BCYN%%BOLD%23%R%  %SYM_ARROW%  %WHT%Check for Updates%R%
echo    %BCYN%%BOLD%24%R%  %SYM_ARROW%  %WHT%Chris Titus Tech WinUtil%R%
echo     %BCYN%%BOLD%0%R%  %SYM_ARROW%  %WHT%Exit%R%
echo.
echo  %RULE_BIG%
echo  %DIM%  Log: %LOGFILE%%R%
echo  %DIM%  WinUtilKLENN  Copyright (C) 2026 sanguirIS%R%
echo  %DIM%  This program comes with ABSOLUTELY NO WARRANTY.%R%
echo  %DIM%  Free software: redistribute under the GNU GPL v3 - see LICENSE%R%
echo.
set "CHOICE="
set /p "CHOICE=%BOLD%%BWHT%  Select an option %R%%CYN%[0-24]%R%%BOLD%%BWHT%: %R%"
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
if "%CHOICE%"=="0" goto END
echo.
echo  %BRED%!%R%  %WHT%Invalid selection: %CHOICE%%R%
echo.
pause
goto MENU

rem ================================================================
rem  1. AUDIO
rem ================================================================
:AUDIO
cls
call :RESIZE
call :HEADER "AUDIO TROUBLESHOOTER"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Service status:%R%
call :SVCSTATUS AudioEndpointBuilder "Audio Endpoint Builder"
call :SVCSTATUS Audiosrv "Windows Audio"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Sound devices detected by Windows:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Sound -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName,Manufacturer | Format-Table -AutoSize"
echo.
echo  %BYLW%?%R%  %WHT%Restart the Windows Audio services?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  Restarting Windows Audio...
net stop Audiosrv /y >nul 2>&1
net stop AudioEndpointBuilder /y >nul 2>&1
net start AudioEndpointBuilder >nul 2>&1
net start Audiosrv >nul 2>&1
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
echo.
pause
goto MENU

rem ================================================================
rem  2. VIDEO PLAYBACK
rem ================================================================
:VIDEO
cls
call :RESIZE
call :HEADER "VIDEO PLAYBACK"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Display adapters:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Display -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName,Manufacturer | Format-Table -AutoSize"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%GPU driver details:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,DriverDate,VideoModeDescription | Format-Table -AutoSize"
echo.
echo  %BYLW%Tip:%R%  %WHT%Video stuttering or black playback? Update the GPU driver,%R%
echo  %WHT%disable hardware acceleration in the player, or change refresh rate.%R%
echo.
pause
goto MENU

rem ================================================================
rem  3. WINDOWS MEDIA PLAYER
rem ================================================================
:WMP
cls
call :RESIZE
call :HEADER "WINDOWS MEDIA PLAYER"
echo.
set "WMPSYS=%ProgramFiles%\Windows Media Player\wmplayer.exe"
if exist "%WMPSYS%" goto WMP_OK
echo  %RED%%SYM_NO%%R%  %WHT%Windows Media Player%R%  %DIM%not found on this system%R%
goto WMP_MEDIA
:WMP_OK
echo  %BGRN%%SYM_OK%%R%  %WHT%Windows Media Player found:%R%
echo  %CYN%     %WMPSYS%%R%
:WMP_MEDIA
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Media file associations:%R%
assoc .mp3
assoc .mp4
assoc .wmv
assoc .avi
assoc .wav
echo.
echo  %BYLW%Tip:%R%  %WHT%Files opening in the wrong player? Change the default apps%R%
echo  %WHT%in Windows Settings ^> Apps ^> Default apps.%R%
echo.
pause
goto MENU

rem ================================================================
rem  4. NETWORK AND INTERNET
rem ================================================================
:NETWORK
cls
call :RESIZE
call :HEADER "NETWORK AND INTERNET"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Network adapters:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object Name,Status,LinkSpeed,MacAddress | Format-Table -AutoSize"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%IP configuration:%R%
ipconfig /all
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Internet reachability:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "foreach($x in '1.1.1.1','8.8.8.8'){Write-Host ($x + ' reachable: ' + (Test-Connection -ComputerName $x -Count 2 -Quiet))}"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%DNS resolution:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Resolve-DnsName www.microsoft.com -ErrorAction SilentlyContinue | Select-Object Name,Type,IPAddress | Format-Table -AutoSize"
echo.
echo  %BYLW%?%R%  %WHT%Reset Winsock, TCP/IP stack and DNS cache?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  Flushing DNS cache...
ipconfig /flushdns >nul
echo  %CYN%%SYM_ARROW%%R%  Resetting Winsock...
netsh winsock reset
echo.
echo  %CYN%%SYM_ARROW%%R%  Resetting TCP/IP stack...
netsh int ip reset
echo.
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Network check after the reset:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ok=0; foreach($x in '1.1.1.1','8.8.8.8'){ if(Test-Connection -ComputerName $x -Count 2 -Quiet){ $ok++ } }; Write-Host ('   Reachable: ' + $ok + ' of 2 test addresses.'); if($ok -eq 0){ exit 1 }"
if errorlevel 1 goto NET_FAIL
call :VERDICT FIXED "Network is reachable."
goto NET_END
:NET_FAIL
call :VERDICT NOT "Network is still unreachable."
:NET_END
call :RESTARTNOTE YES
echo [%date% %time%] Network reset >> "%LOGFILE%"
echo.
pause
goto MENU

rem ================================================================
rem  5. DNS FLUSH
rem ================================================================
:DNSFLUSH
cls
call :RESIZE
call :HEADER "DNS FLUSH"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%DNS servers in use:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.ServerAddresses } | Select-Object InterfaceAlias,ServerAddresses | Format-Table -AutoSize"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Resolver cache entries:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Write-Host ('   ' + (Get-DnsClientCache -ErrorAction SilentlyContinue | Measure-Object).Count + ' cached entries')"
echo.
echo  %BYLW%?%R%  %WHT%Flush the DNS resolver cache?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  Flushing DNS cache...
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
echo.
pause
goto MENU

rem ================================================================
rem  6. BLUETOOTH
rem ================================================================
:BLUETOOTH
cls
call :RESIZE
call :HEADER "BLUETOOTH"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Bluetooth devices:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName,Manufacturer | Format-Table -AutoSize"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Bluetooth service status:%R%
call :SVCSTATUS bthserv "Bluetooth Support Service"
echo.
echo  %BYLW%?%R%  %WHT%Restart the Bluetooth Support Service?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  Restarting Bluetooth service...
net stop bthserv /y >nul 2>&1
net start bthserv >nul 2>&1
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
echo.
pause
goto MENU

rem ================================================================
rem  7. PRINTER
rem ================================================================
:PRINTER
cls
call :RESIZE
call :HEADER "PRINTER"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Print Spooler status:%R%
call :SVCSTATUS Spooler "Print Spooler"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Installed printers:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-Printer -ErrorAction SilentlyContinue | Select-Object Name,DriverName,PortName,PrinterStatus,WorkOffline | Format-Table -AutoSize"
echo.
echo  %BYLW%?%R%  %WHT%Restart the Print Spooler and clear stuck jobs?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  Restarting Print Spooler...
net stop Spooler /y >nul 2>&1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-Printer -ErrorAction SilentlyContinue | ForEach-Object { Get-PrintJob -PrinterName $_.Name -ErrorAction SilentlyContinue | Remove-PrintJob -ErrorAction SilentlyContinue }"
net start Spooler >nul 2>&1
call :CHECKSVC Spooler "Print Spooler"
sc query Spooler 2>nul | findstr /C:": 4  " >nul
if errorlevel 1 goto PRN_FAIL
call :VERDICT FIXED "The Print Spooler is running again."
call :RESTARTNOTE NO
goto PRN_END
:PRN_FAIL
call :VERDICT NOT "The Print Spooler failed to start."
call :RESTARTNOTE YES
:PRN_END
echo [%date% %time%] Printer spooler reset >> "%LOGFILE%"
echo.
pause
goto MENU

rem ================================================================
rem  8. CAMERA
rem ================================================================
:CAMERA
cls
call :RESIZE
call :HEADER "CAMERA"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Camera devices:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Camera -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName,Manufacturer | Format-Table -AutoSize"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Camera privacy setting (webcam consent):%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam' -ErrorAction SilentlyContinue | Select-Object Value | Format-List"
echo.
echo  %BYLW%?%R%  %WHT%Rescan Plug and Play devices?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  Scanning for hardware changes...
pnputil.exe /scan-devices
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$n=@(Get-PnpDevice -Class Camera -ErrorAction SilentlyContinue).Count; Write-Host ('   Camera devices found: ' + $n); if($n -gt 0){ exit 0 } else { exit 1 }"
if errorlevel 1 goto CAM_FAIL
call :VERDICT FIXED "Camera devices are detected."
call :RESTARTNOTE NO
goto CAM_END
:CAM_FAIL
call :VERDICT NOT "No camera devices found."
echo  %DIM%  Check the webcam privacy setting or the driver.%R%
call :RESTARTNOTE NO
:CAM_END
echo [%date% %time%] Camera PnP rescan >> "%LOGFILE%"
echo.
pause
goto MENU

rem ================================================================
rem  9. GRAPHICS DRIVER RESET
rem ================================================================
:GFXRESET
cls
call :RESIZE
call :HEADER "GRAPHICS DRIVER RESET"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Display adapters:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Display -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName | Format-Table -AutoSize"
echo.
echo  %BYLW%!%R%  %WHT%The screen may flicker or turn black for a few seconds.%R%
echo  %BYLW%?%R%  %WHT%Restart the display driver(s) now?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto MENU
set "GFX_DONE=0"
for /f "delims=" %%d in ('powershell.exe -NoProfile -Command "Get-PnpDevice -Class Display -Status OK -ErrorAction SilentlyContinue | ForEach-Object { $_.InstanceId }"') do (
    echo  %CYN%%SYM_ARROW%%R%  Restarting: "%%d"
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
echo  %DIM%  Try updating the driver or restarting the PC instead.%R%
call :RESTARTNOTE YES
:GFX_END
echo.
pause
goto MENU

rem ================================================================
rem  10. WINDOWS UPDATE
rem ================================================================
:UPDATE
cls
call :RESIZE
call :HEADER "WINDOWS UPDATE"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Service status:%R%
call :SVCSTATUS wuauserv "Windows Update"
call :SVCSTATUS bits "Background Intelligent Transfer (BITS)"
call :SVCSTATUS cryptsvc "Cryptographic Services"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Pending restart flags:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$p=@('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'); foreach($x in $p){Write-Host ($x + ' = ' + (Test-Path $x))}"
echo.
echo  %BYLW%?%R%  %WHT%Reset the Windows Update cache?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto UPDATE_SFC
echo  %CYN%%SYM_ARROW%%R%  Stopping update services...
net stop wuauserv /y >nul 2>&1
net stop bits /y >nul 2>&1
net stop cryptsvc /y >nul 2>&1
echo  %CYN%%SYM_ARROW%%R%  Moving old update cache aside...
if exist "%SystemRoot%\SoftwareDistribution.old" rd /s /q "%SystemRoot%\SoftwareDistribution.old" >nul 2>&1
if exist "%SystemRoot%\SoftwareDistribution" ren "%SystemRoot%\SoftwareDistribution" "SoftwareDistribution.old" >nul 2>&1
if exist "%SystemRoot%\System32\catroot2.old" rd /s /q "%SystemRoot%\System32\catroot2.old" >nul 2>&1
if exist "%SystemRoot%\System32\catroot2" ren "%SystemRoot%\System32\catroot2" "catroot2.old" >nul 2>&1
echo  %CYN%%SYM_ARROW%%R%  Restarting update services...
net start cryptsvc >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
call :CHECKSVC wuauserv "Windows Update"
sc query wuauserv 2>nul | findstr /C:": 4  " >nul
if errorlevel 1 goto UPDC_FAIL
call :VERDICT FIXED "Windows Update services are running again."
call :RESTARTNOTE NO
goto UPDC_END
:UPDC_FAIL
call :VERDICT NOT "Windows Update services failed to start."
call :RESTARTNOTE YES
:UPDC_END
echo [%date% %time%] Windows Update cache reset >> "%LOGFILE%"
echo.
:UPDATE_SFC
echo  %BYLW%?%R%  %WHT%Run DISM component repair and sfc /scannow?%R%  %CYN%[ Y / N ]%R%
echo  %DIM%  (This can take 10-30 minutes; DISM needs internet access)%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  %BOLD%Running DISM /RestoreHealth...%R%
DISM.exe /Online /Cleanup-Image /RestoreHealth
echo.
echo  %CYN%%SYM_ARROW%%R%  %BOLD%Running SFC /scannow...%R%
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
echo.
pause
goto MENU

rem ================================================================
rem  11. BITS
rem ================================================================
:BITS
cls
call :RESIZE
call :HEADER "BITS"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%BITS service status:%R%
call :SVCSTATUS bits "Background Intelligent Transfer (BITS)"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Active BITS jobs:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue | Select-Object DisplayName,JobState,BytesTransferred,BytesTotal | Format-Table -AutoSize"
echo.
echo  %BYLW%?%R%  %WHT%Restart BITS and Windows Update services?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  Restarting services...
net stop bits /y >nul 2>&1
net stop wuauserv /y >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
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
echo.
pause
goto MENU

rem ================================================================
rem  12. DISK CLEANUP
rem ================================================================
:DISKCLEAN
cls
call :RESIZE
call :HEADER "DISK CLEANUP"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Free space before cleanup:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { Write-Host ('   Disk '+$_.DeviceID+'  '+[math]::Round($_.FreeSpace/1GB,1)+' GB free') }"
echo.
echo  %BYLW%?%R%  %WHT%Delete temporary files and empty the Recycle Bin?%R%  %CYN%[ Y / N ]%R%
echo  %DIM%  Only temp files are removed - personal files are untouched.%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  Cleaning temporary files...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$paths=@('%TEMP%','%SystemRoot%\Temp'); foreach($p in $paths){ Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }; Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Free space after cleanup:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { Write-Host ('   Disk '+$_.DeviceID+'  '+[math]::Round($_.FreeSpace/1GB,1)+' GB free') }"
call :VERDICT FIXED "Cleanup completed."
call :RESTARTNOTE NO
echo [%date% %time%] Disk cleanup >> "%LOGFILE%"
echo.
pause
goto MENU

rem ================================================================
rem  13. SYSTEM RESTORE POINT
rem ================================================================
:RESTOPOINT
cls
call :RESIZE
call :HEADER "SYSTEM RESTORE POINT"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Existing restore points:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-ComputerRestorePoint -ErrorAction SilentlyContinue | Select-Object SequenceNumber,Description,CreationTime | Format-Table -AutoSize"
echo.
echo  %BYLW%?%R%  %WHT%Create a restore point now?%R%  %CYN%[ Y / N ]%R%
echo  %DIM%  (System Protection is enabled first if needed)%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  Enabling System Protection on the system drive...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Enable-ComputerRestore -Drive '%SystemDrive%\' -ErrorAction SilentlyContinue"
echo  %CYN%%SYM_ARROW%%R%  Creating restore point...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { Checkpoint-Computer -Description 'WinUtilKLENN restore point' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop; exit 0 } catch { exit 1 }"
if errorlevel 1 goto RESTORE_FAIL
call :VERDICT FIXED "Restore point created."
call :RESTARTNOTE NO
echo [%date% %time%] Restore point created >> "%LOGFILE%"
goto RESTORE_END
:RESTORE_FAIL
call :VERDICT NOT "Could not create a restore point."
echo  %DIM%  Open System Properties ^> System Protection, make sure protection is%R%
echo  %DIM%  enabled for the system drive, then try again.%R%
:RESTORE_END
echo.
pause
goto MENU

rem ================================================================
rem  14. BATTERY REPORT
rem ================================================================
:BATTERY
cls
call :RESIZE
call :HEADER "BATTERY REPORT"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Battery status:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$b=Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue; if(-not $b){Write-Host '   No battery detected - this looks like a desktop PC.'}else{$s=switch($b.BatteryStatus){1{'Discharging'}2{'On AC power'}3{'Fully charged'}4{'Low'}5{'Critical'}6{'Charging'}default{'Code '+$_}}; Write-Host ('   Charge: '+$b.EstimatedChargeRemaining+'%   Status: '+$s)}"
echo.
echo  %BYLW%?%R%  %WHT%Generate the full battery report (powercfg)?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  Generating battery report...
powercfg /batteryreport /output "%LOGDIR%\battery-report.html" >nul 2>&1
if errorlevel 1 goto BATTERY_FAIL
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Battery report saved:%R%
echo  %CYN%      %LOGDIR%\battery-report.html%R%
echo  %BYLW%?%R%  %WHT%Open it in the default browser?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto BATTERY_END
start "" "%LOGDIR%\battery-report.html"
goto BATTERY_END
:BATTERY_FAIL
echo  %RED%%SYM_NO%%R%  %WHT%Could not generate the battery report.%R%
echo  %DIM%  This usually means the PC has no battery (a desktop).%R%
:BATTERY_END
echo [%date% %time%] Battery report >> "%LOGFILE%"
echo.
pause
goto MENU

rem ================================================================
rem  15. RESTART / SHUTDOWN
rem ================================================================
:POWER
cls
call :RESIZE
call :HEADER "RESTART / SHUTDOWN"
echo  %WHT%What do you want to do?%R%
echo    %BCYN%%BOLD%1%R%  %SYM_ARROW%  %WHT%Restart the PC%R%
echo    %BCYN%%BOLD%2%R%  %SYM_ARROW%  %WHT%Shut down the PC%R%
echo    %BCYN%%BOLD%0%R%  %SYM_ARROW%  %WHT%Cancel - back to the menu%R%
echo.
choice /C 120 /N
if errorlevel 3 goto MENU
if errorlevel 2 goto POWER_OFF
echo  %BYLW%?%R%  %WHT%Restart the PC in 30 seconds?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto MENU
shutdown /r /t 30
echo [%date% %time%] Restart scheduled >> "%LOGFILE%"
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Restart scheduled in 30 seconds.%R%
echo  %BYLW%!%R%  %WHT%To cancel, open another Command Prompt and run:  shutdown /a%R%
echo.
pause
goto MENU
:POWER_OFF
echo  %BYLW%?%R%  %WHT%Shut down the PC in 30 seconds?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto MENU
shutdown /s /t 30
echo [%date% %time%] Shutdown scheduled >> "%LOGFILE%"
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Shutdown scheduled in 30 seconds.%R%
echo  %BYLW%!%R%  %WHT%To cancel, open another Command Prompt and run:  shutdown /a%R%
echo.
pause
goto MENU

rem ================================================================
rem  16. WINGET UPGRADE
rem ================================================================
:WINGETUP
cls
call :RESIZE
call :HEADER "WINGET UPGRADE"
winget --version >nul 2>&1
if errorlevel 1 goto WINGET_MISSING
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Available updates:%R%
winget upgrade
echo.
echo  %BYLW%?%R%  %WHT%Upgrade all packages now?%R%  %CYN%[ Y / N ]%R%
echo  %DIM%  (winget upgrade --all - some apps may need to close)%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  Upgrading all packages, this can take a while...
winget upgrade --all --accept-package-agreements --accept-source-agreements
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Remaining updates:%R%
winget upgrade
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
:WINGET_MISSING
echo  %RED%%SYM_NO%%R%  %WHT%winget is not installed.%R%
echo  %DIM%  Install 'App Installer' from the Microsoft Store, then re-run.%R%
:WINGET_END
echo [%date% %time%] winget upgrade run >> "%LOGFILE%"
echo.
pause
goto MENU

rem ================================================================
rem  17. YOINKS - VIDEO DOWNLOADER (npm)
rem ================================================================
:YOINK
cls
call :RESIZE
call :HEADER "YOINKS - VIDEO DOWNLOADER"
echo  %WHT%Download videos from YouTube, X, Instagram, Threads, TikTok%R%
echo  %WHT%and 1,800+ other sites - right from your terminal.%R%
echo  %DIM%  Videos are saved to your Downloads folder.%R%
echo.
call :NPMSETUP yoinks yoinks "yoinks video downloader"
if errorlevel 1 goto YOINK_END
echo.
echo  %BOLD%%CYN%  Choose how to launch yoinks:%R%
echo     %BCYN%%BOLD%1%R%  %SYM_ARROW%  %WHT%CMD - opens a blank command prompt and types 'yoinks '%R%
echo     %BCYN%%BOLD%2%R%  %SYM_ARROW%  %WHT%Windows Terminal - opens a new WT window%R%
echo     %BCYN%%BOLD%0%R%  %SYM_ARROW%  %WHT%Cancel - back to main menu%R%
echo.
set "YOINK_CHOICE="
set /p "YOINK_CHOICE=%BOLD%%BWHT%  Select an option %R%%CYN%[0-2]%R%%BOLD%%BWHT%: %R%"
if "%YOINK_CHOICE%"=="" goto YOINK_END
if "%YOINK_CHOICE%"=="0" goto YOINK_END
if "%YOINK_CHOICE%"=="1" (
    echo.
    echo  %CYN%%SYM_ARROW%%R%  Opening a blank CMD window for yoinks...
    echo  %DIM%  The window opens clean and 'yoinks ' is typed automatically.%R%
    echo  %DIM%  Paste the video link, then press Enter manually.%R%
    echo  %DIM%  The script will return here only after the CMD window closes.%R%
    echo.
    powershell -NoProfile -Command "$wshell = New-Object -ComObject WScript.Shell; $p = Start-Process cmd.exe -PassThru; Start-Sleep -Milliseconds 800; $wshell.AppActivate($p.Id); Start-Sleep -Milliseconds 150; $wshell.SendKeys('yoinks ');"
    timeout /t 2 /nobreak >nul
) else if "%YOINK_CHOICE%"=="2" (
    echo.
    echo  %CYN%%SYM_ARROW%%R%  Opening Windows Terminal and running yoinks...
    echo  %DIM%  Yoinks will launch in a new WT window.%R%
    echo  %DIM%  The script will return here only after the WT window closes.%R%
    start "" /wait wt.exe new-tab --suppressApplicationTitle yoinks
) else (
    echo.
    echo  %BRED%!%R%  %WHT%Invalid selection.%R%
    pause
    goto YOINK_END
)
echo.
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%yoinks closed - videos are in your Downloads folder.%R%
echo [%date% %time%] yoinks video downloader run >> "%LOGFILE%"
:YOINK_END
echo.
pause
goto MENU

rem ================================================================
rem  18. GHGRAB - GITHUB DOWNLOADER (npm)
rem ================================================================
:GHGRAB
cls
call :RESIZE
call :HEADER "GHGRAB - GITHUB DOWNLOADER"
echo  %WHT%Browse and download files or folders from any GitHub repo,%R%
echo  %WHT%or grab release assets - without cloning the whole repo.%R%
echo.
call :NPMSETUP @ghgrab/ghgrab ghgrab "ghgrab"
if errorlevel 1 goto GHGRAB_END
echo.
echo  %CYN%%SYM_ARROW%%R%  Launching ghgrab...
echo  %DIM%  Paste a repo link (e.g. https://github.com/rust-lang/rust)%R%
echo  %DIM%  or run  ghgrab rel owner/repo  for release assets.%R%
echo.
call :RESIZE_MAX
call ghgrab
echo.
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%ghgrab closed.%R%
echo [%date% %time%] ghgrab run >> "%LOGFILE%"
:GHGRAB_END
echo.
pause
goto MENU

rem ================================================================
rem  19. FREEBUFF - AI HELP (npm)
rem ================================================================
:FREEBUFF
cls
call :RESIZE
call :HEADER "FREEBUFF - AI HELP"
echo  %WHT%Freebuff is a free AI coding agent that runs in your terminal.%R%
echo  %WHT%Ask it about an error, or get any repair step explained.%R%
echo.
call :NPMSETUP freebuff freebuff "freebuff"
if errorlevel 1 goto FREEBUFF_END
echo.
echo  %CYN%%SYM_ARROW%%R%  Launching freebuff...
echo  %DIM%  It opens in the folder the script was started from.%R%
echo.
call :RESIZE_MAX
call freebuff
echo.
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%freebuff closed.%R%
echo [%date% %time%] freebuff run >> "%LOGFILE%"
:FREEBUFF_END
echo.
pause
goto MENU

rem ================================================================
rem  20. PROGRAM COMPATIBILITY
rem ================================================================
:COMPAT
cls
call :RESIZE
call :HEADER "PROGRAM COMPATIBILITY"
echo  %WHT%Enter the full path to an .exe file to inspect it.%R%
echo  %DIM%Example: C:\Program Files\Example\app.exe%R%
echo.
set "EXE="
set /p "EXE=%BOLD%%CYN%  Path: %R%"
if "%EXE%"=="" goto MENU
if not exist "%EXE%" goto COMPAT_ERR
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$f=Get-Item -LiteralPath $env:EXE; $v=$f.VersionInfo; [pscustomobject]@{Path=$f.FullName;FileVersion=$v.FileVersion;Product=$v.ProductName;Company=$v.CompanyName;SizeMB=[math]::Round($f.Length/1MB,2)} | Format-List"
echo.
echo  %BYLW%Tip:%R%  %WHT%Check for a current version of the application and%R%
echo  %WHT%only use compatibility settings when necessary.%R%
echo.
pause
goto MENU
:COMPAT_ERR
echo.
echo  %RED%%SYM_NO%%R%  %WHT%File not found:%R%  %BCYN%%EXE%%R%
echo.
pause
goto MENU

rem ================================================================
rem  21. COMPLETE DIAGNOSTICS
rem ================================================================
:ALL
cls
call :RESIZE
call :HEADER "COMPLETE DIAGNOSTICS"
echo  %BWHT%Scanning the system, this can take a few moments...%R%
echo.
echo  %BOLD%%CYN%[1] AUDIO%R%
call :SVCSTATUS Audiosrv "Windows Audio"
call :SVCSTATUS AudioEndpointBuilder "Audio Endpoint Builder"
echo.
echo  %BOLD%%CYN%[2] NETWORK%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object Name,Status,LinkSpeed | Format-Table -AutoSize"
echo.
echo  %BOLD%%CYN%[3] PRINTER%R%
call :SVCSTATUS Spooler "Print Spooler"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-Printer -ErrorAction SilentlyContinue | Select-Object Name,PrinterStatus | Format-Table -AutoSize"
echo.
echo  %BOLD%%CYN%[4] WINDOWS UPDATE%R%
call :SVCSTATUS wuauserv "Windows Update"
call :SVCSTATUS bits "BITS"
call :SVCSTATUS cryptsvc "Cryptographic Services"
echo.
echo  %BOLD%%CYN%[5] BLUETOOTH%R%
call :SVCSTATUS bthserv "Bluetooth Support Service"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName | Format-Table -AutoSize"
echo.
echo  %BOLD%%CYN%[6] CAMERA%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class Camera -ErrorAction SilentlyContinue | Select-Object Status,FriendlyName | Format-Table -AutoSize"
echo.
echo  %BOLD%%CYN%[7] DISPLAY / VIDEO%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion | Format-Table -AutoSize"
echo.
echo  %BOLD%%CYN%[8] WINDOWS MEDIA PLAYER%R%
if exist "%ProgramFiles%\Windows Media Player\wmplayer.exe" goto ALL_WMP_OK
echo   %RED%%SYM_NO%%R%  %WHT%Windows Media Player%R%  %DIM%not installed%R%
goto ALL_DONE
:ALL_WMP_OK
echo   %BGRN%%SYM_OK%%R%  %WHT%Windows Media Player%R%  %GRN%installed%R%
:ALL_DONE
echo.
echo  %BGGRN%%BLK%[ DONE ]%R%  %BGRN%Complete diagnostics finished.%R%
echo [%date% %time%] Complete diagnostics >> "%LOGFILE%"
echo.
pause
goto MENU

rem ================================================================
rem  22. SYSTEM SUMMARY
rem ================================================================
:SUMMARY
cls
call :RESIZE
call :HEADER "SYSTEM SUMMARY"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Computer:  %R%%BCYN%%COMPUTERNAME%%R%
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%User:      %R%%BCYN%%USERNAME%%R%
echo.
ver
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture | Format-List"
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Memory and disk:%R%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$os=Get-CimInstance Win32_OperatingSystem; $tm=[math]::Round($os.TotalVisibleMemorySize/1MB,1); $fm=[math]::Round($os.FreePhysicalMemory/1MB,1); Write-Host ('   RAM free: '+$fm+' GB / '+$tm+' GB total'); Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { Write-Host ('   Disk '+$_.DeviceID+'  '+[math]::Round($_.FreeSpace/1GB,1)+' GB free / '+[math]::Round($_.Size/1GB,1)+' GB total') }"
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%PowerShell version:%R%
powershell.exe -NoProfile -Command "$PSVersionTable.PSVersion.ToString()"
echo.
echo  %DIM%  Log: %LOGFILE%%R%
echo.
pause
goto MENU

rem ================================================================
rem  23. CHECK FOR UPDATES
rem ================================================================
:UPDATECHECK
cls
call :RESIZE
call :HEADER "CHECK FOR UPDATES"
echo  %DIM%  Checking the GitHub repository for the latest release...%R%
set "UPD_STATUS="
for /f "delims=" %%v in ('powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; try { $r=Invoke-RestMethod -Uri 'https://api.github.com/repos/sanguirIS/WinUtilKLENN/releases/latest' -Headers @{ 'User-Agent'='WinUtilKLENN/2.7.1' } -TimeoutSec 15; $localVersion='%VERSION%'.TrimStart('v'); $remoteVersion=$r.tag_name.TrimStart('v'); $lv=[version]$localVersion; $rv=[version]$remoteVersion; if ($rv -gt $lv) { 'NEW:'+$r.tag_name } elseif ($rv -lt $lv) { 'LOCAL' } else { 'SAME' } } catch { 'ERR' }"') do set "UPD_STATUS=%%v"
echo.
if "%UPD_STATUS%"=="SAME" goto UPD_SAME
if "%UPD_STATUS%"=="LOCAL" goto UPD_LOCAL
if "%UPD_STATUS:~0,4%"=="NEW:" goto UPD_NEW
goto UPD_ERR
:UPD_SAME
echo  %BGRN%%SYM_OK%%R%  %WHT%You are running the latest version%R%  %BCYN%%VERSION%%R%
echo [%date% %time%] Update check: up to date (%VERSION%) >> "%LOGFILE%"
goto UPD_END
:UPD_LOCAL
echo  %BGRN%%SYM_OK%%R%  %WHT%You are running %VERSION%, which is newer than%R%
echo  %WHT%the latest GitHub release. Nothing to update.%R%
echo [%date% %time%] Update check: local version ahead of latest release >> "%LOGFILE%"
goto UPD_END
:UPD_NEW
set "UPD_NEW=%UPD_STATUS:~4%"
echo  %BYLW%!%R%  %WHT%A newer version is available:%R%  %BCYN%%UPD_NEW%%R%
echo  %DIM%  You are running %VERSION%.%R%
echo  %BYLW%?%R%  %WHT%Open the release page in your browser?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto UPD_END
start "" "https://github.com/sanguirIS/WinUtilKLENN/releases/latest"
echo [%date% %time%] Update check: new version %UPD_NEW% >> "%LOGFILE%"
goto UPD_END
:UPD_ERR
echo  %RED%%SYM_NO%%R%  %WHT%Could not check for updates.%R%
echo  %DIM%  Check your internet connection, or visit:%R%
echo  %CYN%      https://github.com/sanguirIS/WinUtilKLENN/releases%R%
echo [%date% %time%] Update check failed >> "%LOGFILE%"
:UPD_END
echo.
pause
goto MENU

rem ================================================================
rem  24. CHRIS TITUS TECH WINUTIL
rem ================================================================
:WINUTIL
cls
call :RESIZE
call :HEADER "CHRIS TITUS TECH WINUTIL"
echo  %WHT%Step-by-step setup of the WinUtil toolbox.%R%
echo  %DIM%  Chris Titus Tech - github.com/ChrisTitusTech/winutil%R%
echo.
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Step 1 - Documents\PowerShell folder%R%
echo  %BYLW%?%R%  %WHT%Create it if it does not exist?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto WINUTIL_STEP2
powershell.exe -NoProfile -Command "$d=Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell'; if (Test-Path $d) { Write-Host ('   Already exists: ' + $d) } else { New-Item -ItemType Directory -Path $d | Out-Null; Write-Host ('   Created: ' + $d) }"
if errorlevel 1 goto WINUTIL_STEP1FAIL
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%PowerShell folder ready.%R%
echo.
goto WINUTIL_STEP2
:WINUTIL_STEP1FAIL
echo  %RED%%SYM_NO%%R%  %WHT%Could not create the folder. Check permissions.%R%
echo.
:WINUTIL_STEP2
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Step 2 - Download winutil.ps1%R%
echo   %DIM%[1] Pinned:%R%  %CYN%winutil.ps1 (release 26.08.04)%R%
echo   %DIM%[2] Latest:%R%  %CYN%winutil.ps1 (latest release)%R%
echo  %BYLW%?%R%  %WHT%Download it into Documents\PowerShell?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto WINUTIL_STEP3
echo.
echo   %WHT%Which version?%R%
echo     %BCYN%%BOLD%1%R%  %SYM_ARROW%  %WHT%Pinned release 26.08.04%R%
echo     %BCYN%%BOLD%2%R%  %SYM_ARROW%  %WHT%Latest release%R%
choice /C 12 /N
if errorlevel 2 goto WINUTIL_DL_LATEST
set "WINUTIL_URL=https://github.com/ChrisTitusTech/winutil/releases/download/26.08.04/winutil.ps1"
echo  %CYN%%SYM_ARROW%%R%  Downloading winutil.ps1 (26.08.04)...
goto WINUTIL_DL
:WINUTIL_DL_LATEST
set "WINUTIL_URL=https://github.com/ChrisTitusTech/winutil/releases/latest/download/winutil.ps1"
echo  %CYN%%SYM_ARROW%%R%  Downloading winutil.ps1 (latest)...
:WINUTIL_DL
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$d=Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell'; New-Item -ItemType Directory -Force -Path $d | Out-Null; Invoke-WebRequest -Uri '%WINUTIL_URL%' -OutFile (Join-Path $d 'winutil.ps1') -UseBasicParsing; $f=Get-Item (Join-Path $d 'winutil.ps1'); Write-Host ('   Saved: ' + $f.FullName + '  (' + [math]::Round($f.Length/1KB,1) + ' KB)') "
if errorlevel 1 goto WINUTIL_DLFAIL
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%winutil.ps1 downloaded.%R%
echo [%date% %time%] WinUtil script downloaded >> "%LOGFILE%"
goto WINUTIL_STEP3
:WINUTIL_DLFAIL
echo  %RED%%SYM_NO%%R%  %WHT%Download failed. Check your internet connection or the URL.%R%
echo.
:WINUTIL_STEP3
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Step 3 - PowerShell execution policy%R%
powershell.exe -NoProfile -Command "try { $p=(Get-ExecutionPolicy -Scope Process).ToString() } catch { $p='unknown' }; Write-Host ('   Current policy (Process scope): ' + $p); if ($p -eq 'Restricted') { Write-Host '   Policy is Restricted - a Bypass is recommended.' } elseif ($p -ne 'unknown') { Write-Host '   No change needed.' }"
echo  %BYLW%?%R%  %WHT%Set-ExecutionPolicy Bypass -Scope Process?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto WINUTIL_STEP4
powershell.exe -NoProfile -Command "Set-ExecutionPolicy -Scope Process Bypass -Force"
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Execution policy set to Bypass (current process).%R%
echo.
:WINUTIL_STEP4
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Step 4 - winget install --id ChrisTitusTech.winutil%R%
winget --version >nul 2>&1
if errorlevel 1 goto WINUTIL_NOWINGET
echo  %BYLW%?%R%  %WHT%Run:  winget install --id ChrisTitusTech.winutil%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto WINUTIL_STEP5
echo  %CYN%%SYM_ARROW%%R%  Installing WinUtil via winget...
winget install --id ChrisTitusTech.winutil --accept-package-agreements --accept-source-agreements
winget show --id ChrisTitusTech.winutil 2>&1 | findstr /I /C:"No package found" >nul
if not errorlevel 1 goto WINUTIL_WINFAIL
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%WinUtil installed via winget.%R%
echo [%date% %time%] winget install ChrisTitusTech.winutil >> "%LOGFILE%"
goto WINUTIL_STEP5
:WINUTIL_WINFAIL
echo  %RED%%SYM_NO%%R%  %WHT%winget could not find the package 'ChrisTitusTech.winutil'.%R%
echo   %DIM%  It is not in the official winget sources. Use Step 2 (download)%R%
echo   %DIM%  and Step 5 (irm christitus.com/win ^| iex) instead.%R%
echo.
goto WINUTIL_STEP5
:WINUTIL_NOWINGET
echo   %RED%%SYM_NO%%R%  %WHT%winget is not installed.%R%
echo  %BYLW%?%R%  %WHT%Open the Microsoft Store page for 'App Installer'?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 goto WINUTIL_STEP5
start "" "ms-windows-store://pdp/?productid=9NBLGGH4NNS1"
echo  %CYN%%SYM_ARROW%%R%  Store page opened - install 'App Installer' there, then re-run this tool.%R%
echo [%date% %time%] Opened App Installer store page >> "%LOGFILE%"
echo.
:WINUTIL_STEP5
echo  %BWHT%%SYM_BULLET%%R%  %BOLD%Step 5 - Launch WinUtil%R%
echo   %DIM%Command:%R%  %CYN%irm https://christitus.com/win ^| iex%R%
echo  %BYLW%?%R%  %WHT%Launch WinUtil now in an elevated PowerShell?%R%  %CYN%[ Y / N ]%R%
echo   %DIM%  Close the WinUtil window to return to this menu.%R%
choice /C YN /N
if errorlevel 2 goto WINUTIL_END
echo  %CYN%%SYM_ARROW%%R%  Launching WinUtil...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://christitus.com/win | iex"
echo [%date% %time%] WinUtil launched >> "%LOGFILE%"
:WINUTIL_END
echo.
echo  %BGGRN%%BLK%[ DONE ]%R%  %BGRN%WinUtil setup finished.%R%
echo.
pause
goto MENU

rem ================================================================
rem  EXIT
rem ================================================================
:END
echo.
echo  %RULE_BIG%
echo  %BGRN%%SYM_OK%%R%  %BWHT%WinUtilKLENN closed. Thank you!%R%
echo  %DIM%   Log saved to: %LOGFILE%%R%
echo  %DIM%   Tip: use option 23 to check for a newer version.%R%
echo  %DIM%  WinUtilKLENN  Copyright (C) 2026 sanguirIS%R%
echo  %DIM%  This program comes with ABSOLUTELY NO WARRANTY.%R%
echo  %DIM%  Free software: redistribute under the GNU GPL v3 - see LICENSE%R%
echo  %RULE_BIG%
echo [%date% %time%] Closed >> "%LOGFILE%"
endlocal
exit /b 0

rem ================================================================
rem  HELPER ROUTINES
rem ================================================================

rem  Auto-sizes the console window to the largest that fits the current
rem  screen and console font (capped at 68x50). The buffer width is
rem  matched to the window so the border never wraps and no horizontal
rem  scrollbar appears. Falls back silently if the host cannot be
rem  resized (e.g. some Windows Terminal configurations). The applied
rem  size is logged to %LOGFILE% on every call (i.e. on each screen).
:RESIZE
powershell.exe -NoProfile -Command "try { $ui=(Get-Host).UI.RawUI; $max=$ui.MaxWindowSize; $wW=[Math]::Min(68,$max.Width); $wH=[Math]::Min(50,$max.Height); $b=$ui.BufferSize; if($b.Width -lt $wW){ $b.Width=$wW; $b.Height=50; $ui.BufferSize=$b }; $w=$ui.WindowSize; $w.Width=$wW; $w.Height=$wH; $ui.WindowSize=$w; $b=$ui.BufferSize; $b.Width=$wW; $b.Height=50; $ui.BufferSize=$b; $ws=$ui.WindowSize; Add-Content -LiteralPath '%LOGFILE%' -Value ('[{0}] Window size applied: {1}x{2}' -f (Get-Date -Format 'MM/dd/yyyy HH:mm:ss'), $ws.Width, $ws.Height) } catch {}" >nul 2>&1
goto :eof

:HEADER
echo.
echo  %BOLD%%BGBLU%%WHT%  %~1  %R%  %RULE_SMALL%
echo.
goto :eof

rem  Locale-safe service state badge. %1 = service, %2 = display label.
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
echo   %BGYLW%%BLK%[ ? ]%R%  %YLW%%SVCLABEL%  %DIM%(service not found)%R%
goto :eof
:SVC_STOPPED
echo   %BGRED%%WHT%[ STOPPED ]%R%  %RED%%SYM_NO%%R%  %BWHT%%SVCLABEL%%R%
goto :eof
:SVC_OK
echo   %BGGRN%%BLK%[ RUNNING ]%R%  %BGRN%%SYM_OK%%R%  %BWHT%%SVCLABEL%%R%
goto :eof
:SVC_UNKNOWN
echo   %BGYLW%%BLK%[ ? ]%R%  %YLW%%SVCLABEL%  %DIM%(state unknown)%R%
goto :eof

rem  Checks if a service is running. %1 = service, %2 = display label.
:CHECKSVC
sc query "%~1" 2>nul | findstr /C:": 4  " >nul
if errorlevel 1 goto CS_FAIL
echo   %BGRN%%SYM_OK%%R%  %BWHT%%~2%R%  %GRN%is running%R%
goto :eof
:CS_FAIL
echo   %RED%%SYM_NO%%R%  %BWHT%%~2%R%  %DIM%not running%R%
goto :eof

rem  Final verdict after a repair. %1 = FIXED or NOT, %2 = message.
:VERDICT
if /i "%~1"=="FIXED" goto VERDICT_OK
echo  %BGRED%%WHT%[ NOT FIXED ]%R%  %RED%%~2%R%
goto :eof
:VERDICT_OK
echo  %BGGRN%%BLK%[ FIXED ]%R%  %BGRN%%~2%R%
goto :eof

rem  Restart requirement after a repair. %1 = YES or NO.
:RESTARTNOTE
if /i "%~1"=="YES" goto RESTART_YES
echo  %BGRN%%SYM_OK%%R%  %WHT%No restart needed - the fix is active now.%R%
goto :eof
:RESTART_YES
echo  %BYLW%!%R%  %WHT%A restart is required to apply the changes.%R%
goto :eof

rem  Checks for pending-reboot flags; sets errorlevel 1 if a reboot is pending.
:REBOOTCHECK
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$p=@('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'); $any=$false; foreach($x in $p){ if(Test-Path $x){ $any=$true } }; if($any){ Write-Host '   Pending restart detected.'; exit 1 } else { Write-Host '   No pending restart detected.'; exit 0 }"
goto :eof

rem  Makes sure an npm tool is installed. %1 = npm package, %2 = binary,
rem  %3 = display label. Installs Node.js via winget if npm is missing,
rem  installs the package globally if the binary is missing. Returns
rem  errorlevel 0 when the tool is ready to launch.
:NPMSETUP
where npm >nul 2>&1
if errorlevel 1 goto NPM_MISSING
where "%~2" >nul 2>&1
if errorlevel 1 goto NPM_INSTALL
echo  %BGRN%%SYM_OK%%R%  %WHT%%~3%R%  %GRN%already installed - launching%R%
echo [%date% %time%] NPM setup: %~3 found and ready >> "%LOGFILE%"
exit /b 0
:NPM_INSTALL
echo  %BYLW%!%R%  %WHT%%~3%R%  %DIM%is not installed yet%R%
echo  %BYLW%?%R%  %WHT%Install it globally via npm now?%R%  %CYN%[ Y / N ]%R%
echo  %DIM%  Command:  npm install -g %~1 %R%
choice /C YN /N
if errorlevel 2 (
    echo [%date% %time%] NPM setup: User cancelled installation of %~3 >> "%LOGFILE%"
    exit /b 1
)
echo  %CYN%%SYM_ARROW%%R%  Installing %~1 (can take a minute)...
echo [%date% %time%] NPM setup: Starting installation of %~1 >> "%LOGFILE%"
npm install -g "%~1"
if errorlevel 1 goto NPM_INSTALL_FAIL
where "%~2" >nul 2>&1
if errorlevel 1 goto NPM_INSTALL_FAIL
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%%~3%R%  %WHT%installed.%R%
echo [%date% %time%] NPM setup: %~3 installed successfully >> "%LOGFILE%"
exit /b 0
:NPM_INSTALL_FAIL
echo  %RED%%SYM_NO%%R%  %WHT%Install failed - check the internet connection.%R%
echo [%date% %time%] NPM setup: Failed to install %~3 >> "%LOGFILE%"
exit /b 1
:NPM_MISSING
echo  %RED%%SYM_NO%%R%  %WHT%npm / Node.js was not found on this system.%R%
echo  %BYLW%?%R%  %WHT%Install Node.js LTS via winget now?%R%  %CYN%[ Y / N ]%R%
choice /C YN /N
if errorlevel 2 (
    echo [%date% %time%] NPM setup: User cancelled Node.js installation >> "%LOGFILE%"
    exit /b 1
)
echo  %CYN%%SYM_ARROW%%R%  Installing Node.js LTS (winget)...
echo [%date% %time%] NPM setup: Starting Node.js LTS installation via winget >> "%LOGFILE%"
winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements
if errorlevel 1 goto NPM_NODE_FAIL
call :REFRESHPATH
where npm >nul 2>&1
if errorlevel 1 goto NPM_NODE_FAIL
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Node.js installed - npm is ready.%R%
echo [%date% %time%] NPM setup: Node.js installed successfully, npm available >> "%LOGFILE%"
exit /b 0
:NPM_NODE_FAIL
echo  %RED%%SYM_NO%%R%  %WHT%Node.js could not be installed automatically.%R%
echo  %DIM%  Install it from https://nodejs.org, then re-run this option.%R%
echo [%date% %time%] NPM setup: Failed to install Node.js >> "%LOGFILE%"
exit /b 1

rem  Re-reads PATH from the registry into this session (used after an
rem  automatic Node.js install so npm is found without a restart).
:REFRESHPATH
set "SYS_PATH="
set "USR_PATH="
for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYS_PATH=%%B"
for /f "skip=2 tokens=2,*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USR_PATH=%%B"
if defined SYS_PATH set "PATH=%SYS_PATH%"
if defined USR_PATH set "PATH=%PATH%;%USR_PATH%"
goto :eof

rem  Expands the console to the largest available size before launching
rem  the full-screen TUI tools (yoinks / ghgrab / freebuff). The normal
rem  :RESIZE routine snaps the window back after the screen redraws.
:RESIZE_MAX
powershell.exe -NoProfile -Command "try { $ui=(Get-Host).UI.RawUI; $max=$ui.MaxWindowSize; $b=$ui.BufferSize; $b.Width=$max.Width; $b.Height=$max.Height; $ui.BufferSize=$b; $w=$ui.WindowSize; $w.Width=$max.Width; $w.Height=$max.Height; $ui.WindowSize=$w } catch {}" >nul 2>&1
goto :eof