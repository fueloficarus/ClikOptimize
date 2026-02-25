:: ---------------------------------------------
:: FragSpawn - Profile Definitions and Helpers
:: Created by Clikarus and Copilot
:: ---------------------------------------------

@echo off
setlocal ENABLEDELAYEDEXPANSION
goto dispatch

:dispatch
set "PROFILE=%~1"

if /I "%PROFILE%"=="conservative" goto Profile_conservative
if /I "%PROFILE%"=="moderate"     goto Profile_moderate
if /I "%PROFILE%"=="aggressive"   goto Profile_aggressive

call "%~dp0FragSpawn_Logging.cmd" :Log "Unknown profile '%PROFILE%'"
goto :eof

:Profile_conservative
:: call :KillProcess msedge.exe
:: call :KillProcess msedgewebview2.exe
call :KillProcess OneDrive.exe
call :KillProcess OneDrive.Sync.Service.exe
call :KillProcess FileSyncHelper.exe
call :KillProcess OfficeClickToRun.exe
goto :eof

:Profile_moderate
call :Profile_conservative
call :KillProcess Widgets.exe
call :KillProcess WidgetService.exe
call :StopService WSearch
call :StopService ClickToRunSvc
call :StopService "OneDrive Updater Service"
call :StopService MapsBroker
call :StopService SensorDataService
call :StopService SensrSvc
call :StopService XblAuthManager
call :StopService XblGameSave
call :StopService XboxGipSvc
call :StopService XboxNetApiSvc
call :StopService Spooler
call :StopService PrintNotify
call :StopService PrintScanBrokerService
call :StopService vmms
call :StopService vmcompute
call :StopService WSLService
goto :eof

:Profile_aggressive
call :Profile_moderate
call :StopService DiagTrack
call :StopService WdiServiceHost
call :StopService WdiSystemHost
call :StopService DoSvc
call :StopService UsoSvc
call :StopService wuauserv
call :StopService webthreatdefsvc
call :StopService webthreatdefusersvc
call :StopService lfsvc
call :StopService whesvc
call :StopService SysMain
goto :eof

:KillProcess
set "PROC=%~1"
tasklist /FI "IMAGENAME eq %PROC%" | find /I "%PROC%" >nul
if not errorlevel 1 (
  echo Killing %PROC%
  taskkill /F /IM "%PROC%" >nul 2>&1
  call "%~dp0FragSpawn_Logging.cmd" :Log "Fragged process %PROC%"
) else (
  call "%~dp0FragSpawn_Logging.cmd" :Log "Process %PROC% not fraggable"
)
goto :eof

:StopService
set "SVC=%*"
sc query "%SVC%" | find "RUNNING" >nul
if not errorlevel 1 (
  echo Stopping service %SVC%
  net stop "%SVC%" /y >nul 2>&1
  call "%~dp0FragSpawn_Logging.cmd" :Log "Fragged service %SVC%"
) else (
  call "%~dp0FragSpawn_Logging.cmd" :Log "Service %SVC% not fraggable"
)
goto :eof
