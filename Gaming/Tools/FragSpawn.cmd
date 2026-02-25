:: ---------------------------------------------
:: FragSpawn - Profile-driven performance mode
:: Created by Clikarus and Copilot
:: ---------------------------------------------

@echo off
setlocal ENABLEDELAYEDEXPANSION

set "PROFILE=%~1"

if "%PROFILE%"=="" (
    echo No profile selected, chump.
    echo Usage: FragSpawn.cmd [conservative^|moderate^|aggressive]
    goto :eof
)

call "%~dp0FragSpawn_Logging.cmd" :Log "FragSpawn invoked with profile %PROFILE%"

call "%~dp0FragSpawn_Snapshot.cmd" SnapshotServices
call "%~dp0FragSpawn_Snapshot.cmd" SnapshotProcesses

call "%~dp0FragSpawn_Profiles.cmd" "%PROFILE%"

call "%~dp0FragSpawn_Logging.cmd" :Log "Profile %PROFILE% execution complete"

endlocal
goto :eof
