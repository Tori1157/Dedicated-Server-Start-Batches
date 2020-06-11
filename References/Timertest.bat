@echo off
:start

set RestartTimer=15

setlocal enableDelayedExpansion

for /l %%N in (%RestartTimer% -1 1) do (
  ::set /a "min=%%N/60, sec=%%N%%60, n-=1"
  set /a "sec=%%N%%%RestartTimer%, n-=1"

  :: If value is 0 (start) set it to the config value
  if !sec! == 0 set sec=%RestartTimer%
  :: If seconds are below 10 add a 0 infront for beauty
  if !sec! lss 10 set sec=0!sec!

  cls
  choice /c:CR1 /n /m "Server will automatically restart in !sec! seconds. Type R to Restart now, or type C to Cancel the restart. " /t:1 /d:1

  if not errorlevel 3 goto :HandleInput
)
cls

echo Server will automatically restart in 00 seconds. Type R to Restart now, or type C to Cancel the restart.

:HandleInput
if errorlevel 2 (
   echo Server is restarting....
   ping localhost -n 2 >nul
   GOTO :start
   ) else (
   echo Server restart Canceled ... Closing console
   ping localhost -n 2 >nul
   exit /B 0
)