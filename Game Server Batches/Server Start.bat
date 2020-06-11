@echo off
:Begin
setlocal enableDelayedExpansion
cls
call :setESC

:: ---[[[ ---------------------------- ]]]---
:: ---[[[ CONFIG OPTIONS FOR BATCHFILE ]]]---
:: ---[[[ ---------------------------- ]]]---

:: |----------------------------------------------------------|
:: |Gameserver specific settings [[THESE NEEDS TO BE CHANGED]]|
:: |----------------------------------------------------------|

:: The server.exe that will be launched
set GameName=RustDedicated.exe
:: Server log .txt filename and directory target (within .exe location)
set "LogName=Rust Server Log"
set "LogDirectory=Server Logs"
set "KeepOldLogs=60"

:: |----------------------------------------------------------|
:: |Gameserver specific settings         ENDS HERE            |
:: |----------------------------------------------------------|


:: Should console automatically restart server in the event of a crash/shutdown?
set "AutomaticCrashRestart=true"

:: Timers in seconds
set CrashTimer=15
set MessageTimer=2

:: Customizable messages
:: Do not change strings/messages that are not here, unless you know what you're doing.
SET "ServerInitializationMessage=Initializing '%GameName%' Server..."
SET "ServerClosingMessage=Closing the '%GameName%' console..."
SET "ServerRestartingMessage=Restarting the server using '%~nx0' file for '%GameName%'"

:: ---[[[ ----------------------- ]]]---
:: ---[[[ CONFIGURATION ENDS HERE ]]]---
:: ---[[[ ----------------------- ]]]---


:: ---[[[ Logging ]]]---
set LOGTIMESTAMP=

:: {{ Credit to 7DaysToDie Author for this little code snippet, i lazied out and didn't make my own..}}
:: --------------------------------------------
:: BUILDING TIMESTAMP FOR LOGFILE

:: Check WMIC is available
WMIC.EXE Alias /? >NUL 2>&1 || GOTO s_start

:: Use WMIC to retrieve date and time
FOR /F "skip=1 tokens=1-6" %%G IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') DO (
	IF "%%~L"=="" goto s_done
	Set _yyyy=%%L
	Set _mm=00%%J
	Set _dd=00%%G
	Set _hour=00%%H
	Set _minute=00%%I
	Set _second=00%%K
)
:s_done

:: Pad digits with leading zeros
Set _mm=%_mm:~-2%
Set _dd=%_dd:~-2%
Set _hour=%_hour:~-2%
Set _minute=%_minute:~-2%
Set _second=%_second:~-2%
:: {{ Credit to 7DaysToDie Author ends here, thanks for making my life easier. <3}}

set "LOGTIMESTAMP= %_hour%;%_minute% %_dd%.%_mm%.%_yyyy%"

:: ---[[[ ------------------------------------------------- ]]]---
:: ---[[[ YOU CAN ADD AND CHANGE SERVER VARIABLES FROM HERE ]]]---
:: ---[[[ ------------------------------------------------- ]]]---
:ServerVariables
echo %ESC%[93m%ServerInitializationMessage%%ESC%[0m
set LOGFILE=%~dp0\%LogDirectory%\%LOGNAME%%LOGTIMESTAMP%.txt

:: Make sure that there are no spaces after the '^' character, else
:: it will stop at that character. Meaning the rest will not be ran.

%GameName% -batchmode ^
+server.port			          28015 ^
+rcon.ip				             0.0.0.0	^
+rcon.port                     28016 ^
+server.hostname               "Development Server | Whitelisted" ^
+server.description            "Don't bother joining *shrugs*" ^
+server.identity               "cerberus" ^
+server.maxplayers             16 ^
+server.worldsize              4000 ^
+server.seed                   55667 ^
+server.saveinterval           600 ^
+rcon.password                 "ihavenothing" ^
-LogFile "%LOGFILE%" ^

:: ---[[[ -------------------------------------------------------------------------- ]]]---
:: ---[[[ TO HERE, THIS IS THE END OF THE SERVER VARIABLES. DO NOT EDIT ANY FURTHER. ]]]---
:: ---[[[ -------------------------------------------------------------------------- ]]]---






:: |||  ------------------------------------------------  |||
:: |||  ------------------------------------------------  |||
:: |||                I SEE YOU PEEKING....               |||
:: |||  ------------------------------------------------  |||
:: |||  ------------------------------------------------  |||

:: Main event, checking which one we're running with.
IF "%AutomaticCrashRestart%" == "true" (
    for /l %%N in (%CrashTimer% -1 1) do (
       set /a "sec=%%N%%%CrashTimer%, n-=1"
       if !sec! == 0 set sec=%CrashTimer%
       if !sec! lss 10 set sec=0!sec!

       cls
       choice /c:QR1 /n /m "The server will automatically restart in !sec! seconds. Press R to restart now, or press Q to quit." /t:1 /d:1

       if not errorlevel 3 GOTO :HandleInput
    )
    cls

    echo The server will automatically restart in 00 seconds. Press R to restart now, or press Q to quit.

    :HandleInput
    if errorlevel 2 (
       echo.
       echo %ESC%[92m%ServerRestartingMessage%%ESC%[0m
       ping localhost -n %MessageTimer% >nul
       GOTO :Begin
    ) else (
       GOTO :CloseDown
    )
) else (
   GOTO :CloseDown
)

:setESC
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
  exit /B 0
)

:: Closing cmd window message
:CloseDown
echo %ESC%[1m%ESC%[93m%ServerClosingMessage%%ESC%[0m
ping localhost -n %MessageTimer% >nul
exit