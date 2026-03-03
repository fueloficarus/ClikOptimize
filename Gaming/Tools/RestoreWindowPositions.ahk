; --- RestoreWindowPositions.ahk ---
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

F10::
    Loop, Read, WindowPositions.txt
    {
        line := A_LoopReadLine
        StringSplit, f, line, %A_Tab%

        title := f1
        X := f2
        Y := f3
        W := f4
        H := f5

        WinActivate, %title%
        WinWaitActive, %title%, , 1
        WinMove, %title%, , X, Y, W, H
    }
    MsgBox, Restored window positions.
return
