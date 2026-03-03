; --- SaveWindowPositions.ahk ---
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

F9::
    FileDelete, WindowPositions.txt

    WinGet, idList, List
    Loop, %idList%
    {
        this_id := idList%A_Index%
        WinGetTitle, title, ahk_id %this_id%
        if (title = "")
            continue

        WinGet, style, Style, ahk_id %this_id%
        if (style & 0x20000000) ; WS_MINIMIZE
            continue

        WinGetPos, X, Y, W, H, ahk_id %this_id%

        FileAppend, %title%`t%X%`t%Y%`t%W%`t%H%`n, WindowPositions.txt
    }
    MsgBox, Saved window positions.
return
