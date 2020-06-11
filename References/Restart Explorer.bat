@echo off
:Begin
setlocal enableDelayedExpansion

Set "Process=explorer.exe"
Set "FileProcess=C:\Windows\explorer.exe"

rem Check process listing for explorer
TaskList /fi "imagename eq %Process%" 2>nul | find /i /n "%Process%">nul

rem Found the process
if %ERRORLEVEL% == 0 (
    rem Refind process and kill it
    TaskKill /fi "imagename eq %Process%" /f 2>nul
    
    echo Closed %Process%, about to restart %Process%.
    
    rem Wait, don't want to spook the system, then start explorer again
    ping localhost -n 5 >nul
    start "" "%FileProcess%"
    
    GOTO Check
) else (
    echo Starting %Process% back up...
    
    rem Wait, don't want to spook the system, thest start explorer again
    ping localhost -n 5 >nul
    start "" "%FileProcess%"
    
    GOTO Close
)

rem Should check to make sure re have explorer booted up again
:Check
rem Give explorer some time to bootup
ping localhost -n 15 >nul
TaskList /fi "imagename eq %Process%" 2>nul | find /i /n "%Process%">nul

if not %ERRORLEVEL% == 0 (
    ping localhost -n 5 >nul
    GOTO Begin
) else (GOTO Close)

:Close
echo Closing down...
ping localhost -n 2 >nul
exit /B