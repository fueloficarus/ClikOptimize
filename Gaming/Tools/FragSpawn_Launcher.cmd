
:: ---------------------------------------------
:: FragSpawn — Launcher & Profile Selector
:: Created by Clikarus and Copilot
:: ---------------------------------------------

@echo off

setlocal ENABLEDELAYEDEXPANSION
:banner
echo.
echo.
echo ".#######.########....###....######..........#....######.########....###...##......#.##....##";
echo ".##......##.....#...##.##..##....##........##...##....#.##.....#...##.##..##..##..#.###...##";
echo ".##......##.....#..##...##.##.............##....##......##.....#..##...##.##..##..#.####..##";
echo ".######..########.##.....#.##...###......##......######.########.##.....#.##..##..#.##.##.##";
echo ".##......##...##..########.##....##.....##............#.##.......########.##..##..#.##..####";
echo ".##......##....##.##.....#.##....##....##.......##....#.##.......##.....#.##..##..#.##...###";
echo ".##......##.....#.##.....#..######....##.........######.##.......##.....#..###..###.##....##";
echo.
echo.
echo "===========================================================================================";
echo "===========================  ======  =========================  ===========================";
echo "===========================  ======  =========================  ===========================";
echo "===========================  ======  ======  =================  ===========================";
echo "=====================   ===  ==  ==  =  ==    ===   ====   ===  ===   =====================";
echo "====================  =  ==  ======    ====  ===     ==     ==  ==  =  ====================";
echo "====================  =====  ==  ==   =====  ===  =  ==  =  ==  ===  ======================";
echo "====================  =====  ==  ==    ====  ===  =  ==  =  ==  ====  =====================";
echo "====================  =  ==  ==  ==  =  ===  ===  =  ==  =  ==  ==  =  ====================";
echo "=====================   ===  ==  ==  =  ===   ===   ====   ===  ===   =====================";
echo "===========================================================================================";
echo.
echo.
echo =--------------------------------------------=
echo FragSpawn Launcher and Profile Selector
echo =------------------------------------------=
echo.
echo.
echo Choose your loadout, warrior:
echo.
echo   [1] Conservative  - Light cleanup, safe for scrubs and Windows Update aficionados
echo   [2] Moderate      - Balanced fragging, recommended
echo   [3] Aggressive    - Maximum carnage, no process will survive, no service is safe
echo   [4] Respawn       - Restore services from save point
echo   [5] Exit          - Retreat like a coward
echo.
set /p choice="Select your destiny: "

if "%choice%"=="1" goto :conservative
if "%choice%"=="2" goto :moderate
if "%choice%"=="3" goto :aggressive
if "%choice%"=="4" goto :respawn
if "%choice%"=="5" goto :end

echo Invalid selection, you absolute gremlin.
echo.
goto banner


:conservative
call "%~dp0FragSpawn.cmd" conservative
echo.
echo Conservative profile deployed. Minimal fragging achieved.
echo.
timeout /t 3
goto banner


:moderate
call "%~dp0FragSpawn.cmd" moderate
echo.
echo Moderate profile deployed. Balanced destruction complete.
echo.
timeout /t 3
goto banner


:aggressive
call "%~dp0FragSpawn.cmd" aggressive
echo.
echo Aggressive profile deployed. Maximum carnage unleashed.
echo.
timeout /t 3
goto banner


:respawn
call "%~dp0FragSpawn_Restore.cmd"
echo.
echo Services respawned. You're back in the fight.
echo.
timeout /t 3
goto :banner


:end
echo.
echo Retreating from battle. FragSpawn out.
echo.
endlocal
exit /b