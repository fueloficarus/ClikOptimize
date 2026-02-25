:: ---------------------------------------------
:: FragSpawn - Service Respawn Module
:: Created by Clikarus and Copilot
:: ---------------------------------------------

@echo off
setlocal ENABLEDELAYEDEXPANSION

call "%~dp0FragSpawn_Logging.cmd" :Log "Respawn initiated"

if not exist "%~dp0running_services.tmp" (
  echo No service snapshot found. Nothing to respawn.
  call "%~dp0FragSpawn_Logging.cmd" :Log "No running_services.tmp found during restore"
  goto :eof
)

for /f "tokens=1 delims=" %%S in (%~dp0running_services.tmp) do (
  echo DEBUG: Attempting to restore [%%S]
  call :StartService "%%S"
)

call "%~dp0FragSpawn_Logging.cmd" :Log "Respawn complete"
goto :eof


:StartService
set "SVC=%~1"
echo Attempting to restore service: %SVC%
sc query "%SVC%" | find "RUNNING" >nul
if errorlevel 1 (
  echo Starting service: %SVC%
  net start "%SVC%" >nul 2>&1
  call "%~dp0FragSpawn_Logging.cmd" :Log "Respawned service %SVC%"
) else (
  echo Service already running: %SVC%
  call "%~dp0FragSpawn_Logging.cmd" :Log "Service %SVC% already running"
)
goto :eof

