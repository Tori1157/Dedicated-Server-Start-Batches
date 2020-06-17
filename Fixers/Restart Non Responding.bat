@echo off
:Begin
setlocal enableDelayedExpansion

TaskKill /fi "status eq not responding" /f /t 2>nul

timeout /t 10
exit /b 0