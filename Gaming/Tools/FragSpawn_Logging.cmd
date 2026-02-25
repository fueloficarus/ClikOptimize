:: ---------------------------------------------
:: FragSpawn - Logging Module
:: Created by Clikarus and Copilot
:: ---------------------------------------------

@echo off
goto dispatch

:dispatch
:: Usage: call FragSpawn_Logging.cmd :Log your message here
if /I "%~1"==":Log" shift & goto Log
goto :eof

:Log
setlocal ENABLEDELAYEDEXPANSION
set "MSG=%*"
echo [%DATE% %TIME%] %MSG%>>"%~dp0FragSpawn.log"
endlocal
goto :eof
