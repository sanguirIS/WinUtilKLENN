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
rem  WINUTILKLENN   (v2.4.2)
rem  Diagnostics and guided repair tools for Windows 10 / 11.
rem  Run as Administrator for full functionality.
rem ================================================================
rem  CHANGELOG
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
echo  %BCYN%      Diagnostics and Repair  %SYM_BULLET%  Windows 10 / 11  [ v2.4.2 ]%R%
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
echo    %BCYN%%BOLD%11%R%  %SYM_ARROW%  %WHT%BITS (Background Transfer)%R%
echo.
echo  %BOLD%%CYN%  OTHER / TOOLS%R%
echo    %BCYN%%BOLD%12%R%  %SYM_ARROW%  %WHT%Program Compatibility%R%
echo    %BCYN%%BOLD%13%R%  %SYM_ARROW%  %WHT%Run ALL Diagnostics%R%
echo    %BCYN%%BOLD%14%R%  %SYM_ARROW%  %WHT%System Summary%R%
echo    %BCYN%%BOLD%15%R%  %SYM_ARROW%  %WHT%Chris Titus Tech WinUtil%R%
echo     %BCYN%%BOLD%0%R%  %SYM_ARROW%  %WHT%Exit%R%
echo.
echo  %RULE_BIG%
echo  %DIM%  Log: %LOGFILE%%R%
echo  %DIM%  WinUtilKLENN  Copyright (C) 2026 sanguirIS%R%
echo  %DIM%  This program comes with ABSOLUTELY NO WARRANTY.%R%
echo  %DIM%  Free software: redistribute under the GNU GPL v3 - see LICENSE%R%
echo.
set "CHOICE="
set /p "CHOICE=%BOLD%%BWHT%  Select an option %R%%CYN%[0-15]%R%%BOLD%%BWHT%: %R%"
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
if "%CHOICE%"=="12" goto COMPAT
if "%CHOICE%"=="13" goto ALL
if "%CHOICE%"=="14" goto SUMMARY
if "%CHOICE%"=="15" goto WINUTIL
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
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Audio repair completed.%R%
goto AUDIO_LOG
:AUDIO_FAIL
echo  %BGRED%%WHT%[ !! ]%R%  %RED%Audio services failed to start. Try restarting the PC.%R%
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
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Network repair completed.%R%
echo  %BYLW%!%R%  %WHT%A restart is recommended to apply the changes.%R%
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
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%DNS cache flushed.%R%
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
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Bluetooth repair completed.%R%
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
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Printer repair completed.%R%
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
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Device scan completed.%R%
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
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Display driver(s) restarted.%R%
echo [%date% %time%] Graphics driver reset >> "%LOGFILE%"
goto GFX_END
:GFX_FAIL
echo  %RED%%SYM_NO%%R%  %WHT%No display adapter could be restarted.%R%
echo  %DIM%  Try updating the driver or restarting the PC instead.%R%
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
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%Windows Update cache reset completed.%R%
echo [%date% %time%] Windows Update cache reset >> "%LOGFILE%"
echo.
:UPDATE_SFC
echo  %BYLW%?%R%  %WHT%Run DISM component repair and SFC scannow?%R%  %CYN%[ Y / N ]%R%
echo  %DIM%  (This can take 10-30 minutes; DISM needs internet access)%R%
choice /C YN /N
if errorlevel 2 goto MENU
echo  %CYN%%SYM_ARROW%%R%  %BOLD%Running DISM /RestoreHealth...%R%
DISM.exe /Online /Cleanup-Image /RestoreHealth
echo.
echo  %CYN%%SYM_ARROW%%R%  %BOLD%Running SFC /scannow...%R%
sfc.exe /scannow
echo.
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%System file repair completed.%R%
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
echo  %BGGRN%%BLK%[ OK ]%R%  %BGRN%BITS repair completed.%R%
echo.
pause
goto MENU

rem ================================================================
rem  12. PROGRAM COMPATIBILITY
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
rem  13. COMPLETE DIAGNOSTICS
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
rem  14. SYSTEM SUMMARY
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
echo  %DIM%Log: %LOGFILE%%R%
echo.
pause
goto MENU

rem ================================================================
rem  15. CHRIS TITUS TECH WINUTIL
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
powershell.exe -NoProfile -Command "try { $ui=(Get-Host).UI.RawUI; $max=$ui.MaxWindowSize; $wW=[Math]::Min(68,$max.Width); $wH=[Math]::Min(50,$max.Height); $b=$ui.BufferSize; if($b.Width -lt $wW){ $b.Width=$wW; $b.Height=9000; $ui.BufferSize=$b }; $w=$ui.WindowSize; $w.Width=$wW; $w.Height=$wH; $ui.WindowSize=$w; $b=$ui.BufferSize; $b.Width=$wW; $b.Height=9000; $ui.BufferSize=$b; $ws=$ui.WindowSize; Add-Content -LiteralPath '%LOGFILE%' -Value ('[{0}] Window size applied: {1}x{2}' -f (Get-Date -Format 'MM/dd/yyyy HH:mm:ss'), $ws.Width, $ws.Height) } catch {}" >nul 2>&1
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

