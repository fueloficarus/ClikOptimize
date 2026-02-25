:: ---------------------------------------------
:: FragSpawn - Snapshot Module
:: Created by Clikarus and Copilot
:: ---------------------------------------------

@echo off
setlocal ENABLEDELAYEDEXPANSION
goto dispatch

:dispatch
if /I "%~1"=="SnapshotServices"  goto SnapshotServices
if /I "%~1"=="SnapshotProcesses" goto SnapshotProcesses

call "%~dp0FragSpawn_Logging.cmd" :Log "Snapshot module called with invalid action"
goto :eof

:SnapshotServices
> "%~dp0running_services.tmp" (
  for /f "tokens=*" %%A in ('sc query state^=running ^| find /I "SERVICE_NAME"') do (
    for /f "tokens=2 delims=:" %%B in ("%%A") do (
      echo %%B
    )
  )
)
call "%~dp0FragSpawn_Logging.cmd" :Log "Service snapshot saved"
goto :eof


:SnapshotProcesses
tasklist /FI "STATUS eq running" > "%~dp0running_processes.tmp"
call "%~dp0FragSpawn_Logging.cmd" :Log "Process snapshot saved"
goto :eof
