#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
#include Data\ShinsImageScanClass.ahk
gta_window := "ahk_exe ragemp_v.exe"

If(!FileExist("barsch.png") ||!FileExist("oil.png") ||!FileExist("copper.png") ||!FileExist("fuel.png") ||!FileExist("Inv.png"))
{
    Gui +LastFound +OwnDialogs +AlwaysOnTop
    MsgBox, 16, Warning, Pictures missing!, 2
    ExitApp
}

BlockInput, MouseMove
WinGetPos,,,WinWidth,WinHeight, %gta_window%
WinGet, wstyle, Style, %gta_window%

if(wstyle == 0x14CA0000){
    boarder := 0
    widthb := -50
    heightb:= 25
    boxh := 10
    boxw := 15
    addExtra := 22
}
Else{
    boarder := 1
    widthb := -52
    heightb:= 15
    boxh := 12
    boxw := 15
    addExtra := 0
}

scan := new ShinsImageScanClass(gta_window, boarder)
scan.autoUpdate := 0

xMidScrn := (WinWidth //2)
yMidScrn := (WinHeight //2)

Gosub, checksupport

Gosub, scanoil
sleep 100
if(fuelpump)
{
    PressESC()
    oil = true
    sleep 200
}

ControlFocus,, % gta_window
ControlSend,, {i down}, %gta_window%
sleep 150
ControlSend,, {i up}, %gta_window%
sleep 50
WinActivate, %gta_window%
sleep 1000
MouseMove, 1343, 305 + addExtra
sleep 2000
Gosub, scaninv
sleep 100
if (!invopen)
{
    Gui +LastFound +OwnDialogs +AlwaysOnTop
    MsgBox, 16, Warning, No inventory found!, 2
    PressESC()
    ExitApp
}
If (copper1 && !copper2)
{
    Gui +LastFound +OwnDialogs +AlwaysOnTop
    MsgBox, 16, Warning, First put some "copper/Kupfer" in the trunk., 3
    PressESC()
    ExitApp
}
If (copper1 && copper2)
{
    WinActivate, %gta_window%
    C_mousedrag(copperx1,coppery1,copperx2,coppery2, 25)
}
If (barsch1 && !barsch2)
{
    MsgBox, 16, Warning, First put some "perch/Barsch" in the trunk., 3
    PressESC()
    ExitApp
}
If (barsch1 && barsch2)
{
    WinActivate, %gta_window%
    C_mousedrag(barschx1,barschy1,barschx2,barschy2, 25)
}
If (oil1 && !Oil2)
{
    Gui +LastFound +OwnDialogs +AlwaysOnTop
    MsgBox, 16, Warning, First put some "oil" in the trunk., 3
    PressESC()
    ExitApp
}
If(oil1 && Oil2)
{
    WinActivate, %gta_window%
    C_mousedrag(oilx1,oily1,oilx2,oily2, 25)
}

sleep 1000
PressESC()

if(oil)
{
    pressE()
    sleep 200
}

sleep 500
ExitApp

scanoil:
    scan.Update()
    fuelpump := scan.Image("fuel.png", 30)
Return

scaninv:
    scan.Update()
    invopen := scan.ImageRegion("inv.png", xMidScrn, 0,xMidScrn, WinHeight, 30)
    fuelpump := scan.Image("fuel.png", 50)
    copper1 := scan.ImageRegion("copper.png", 0, 0,xMidScrn, WinHeight, 50, copperx1, coppery1 , 1)
    copper2 := scan.ImageRegion("copper.png", xMidScrn, 0,xMidScrn, WinHeight, 50, copperx2, coppery2 , 1)
    barsch1 := scan.ImageRegion("barsch.png", 0, 0,xMidScrn, WinHeight, 50, barschx1, barschy1 , 1)
    barsch2 := scan.ImageRegion("barsch.png", xMidScrn, 0,xMidScrn, WinHeight, 50, barschx2, barschy2 , 1)
    oil1 := scan.ImageRegion("oil.png", 0, 0,xMidScrn, WinHeight, 50, oilx1, oily1 , 1)
    Oil2 := scan.ImageRegion("oil.png", xMidScrn, 0,xMidScrn, WinHeight, 50, oilx2, oily2 , 1)
Return

checksupport:
    WinGetPos, , , W, H,% gta_window
    If (W = 1920 and H = 1080 || W = 1920 and H = 1081)
        Return
    Else{
        Gui +LastFound +OwnDialogs +AlwaysOnTop
        MsgBox, 4112, Error, %W% and %H%. Solution not supported., 5
        ExitApp
    }
return

PressESC(){
    ControlFocus,, % gta_window
    ControlSend,, {Esc down}, %gta_window%
    sleep 150
    ControlSend,, {Esc up}, %gta_window%
    Return
}

pressE(){
    ControlFocus,, % gta_window
    ControlSend,, {e down}, %gta_window%
    sleep 150
    ControlSend,, {e up}, %gta_window%
    Return
}

C_mousedrag(x1, y1, x2, y2, speed := 1) {
    ix := (x2 - x1) / speed
    iy := (y2 - y1) / speed
    mousemove x1, y1
    sleep 500

    Click, Down
    Sleep, 100

    loop % speed {
        mousemove (x1 + (ix * a_index)), (y1 + (iy * a_index))
        sleep 1
    }

    Click, Up
    Sleep, 100
}