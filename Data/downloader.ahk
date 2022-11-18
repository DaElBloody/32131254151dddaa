#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

;###################Files######################

drawpng := "aHR0cDovL2JpdC5seS8zVTM0NjlQ"
oilpng := "aHR0cHM6Ly9iaXQubHkvM3RET1U4Ng=="
Invpng := "aHR0cHM6Ly9iaXQubHkvM1Y0Qk93aw=="
fuelpng := "aHR0cHM6Ly9iaXQubHkvM3RDc2JKTA=="
barschpng := "aHR0cHM6Ly9iaXQubHkvM0dyRDhvVg=="
copperpng := "aHR0cHM6Ly9iaXQubHkvM2dpMTd3aQ=="
clickpng := "aHR0cHM6Ly9iaXQubHkvM2hVV0VBMw=="
Inventory := "aHR0cDovL2JpdC5seS8zT2ZIakds"



if(!FileExist("draw.png"))
    DownloadFile(File(drawpng), "draw.png")
if(!FileExist("oil.png"))
    DownloadFile(File(oilpng), "oil.png")
if(!FileExist("Inv.png"))
    DownloadFile(File(Invpng), "Inv.png")
if(!FileExist("fuel.png"))
    DownloadFile(File(fuelpng), "fuel.png")
if(!FileExist("barsch.png"))
    DownloadFile(File(barschpng), "barsch.png")
if(!FileExist("copper.png"))
    DownloadFile(File(copperpng), "copper.png")
if(!FileExist("click.png"))
    DownloadFile(File(clickpng), "click.png")
if(!FileExist("Inventory.ahk"))
    DownloadFile(File(Inventory), "Inventory.ahk")
ExitApp

DownloadFile(UrlToFile, SaveFileAs, Overwrite := True, UseProgressBar := True, ProgressBarTitle:="Downloading...") {
    ; DownloadFile() by brutosozialprodukt
    ; http://ahkscript.org/boards/viewtopic.php?f=6&t=1674

    ; Revision: joedf
    ; Changes:  - Changed progress bar style & colors
    ;           - Changed Display Information
    ;           - Commented-out Size calculation
    ;           - Added ShortURL()
    ;           - Added short delay 100 ms to show the progress bar if download was too fast
    ;           - Added ProgressBarTitle
    ;           - Try-Catch "backup download code"
    ; ----------------------------------------------------------------------------------

    ;Check if the file already exists and if we must not overwrite it
    If (!Overwrite && FileExist(SaveFileAs))
        Return
    ;Check if the user wants a progressbar
    If (UseProgressBar) {
        _surl:=ShortURL(UrlToFile)

        ;Initialize the WinHttpRequest Object
        WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        ;Download the headers
        WebRequest.Open("HEAD", UrlToFile)
        WebRequest.Send()
        ;Store the header which holds the file size in a variable:
        try
        {
            FinalSize := WebRequest.GetResponseHeader("Content-Length")
        }
        catch
        {
            ;throw Exception("could not get Content-Length for URL: " UrlToFile)
            Progress, CW202020 CTFFFFFF CB3399FF w330 h52 B1 FS8 WM700 WS700 FM8 ZH12 ZY3 C11, , %ProgressBarTitle%, %_surl%, Consolas
            UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
            Sleep 100
            Progress, Off
            return
        }
        ;Create the progressbar and the timer
        Progress, CW202020 CTFFFFFF CB3399FF w330 h52 B1 FS8 WM700 WS700 FM8 ZH12 ZY3 C11, , %ProgressBarTitle%, %_surl%, Consolas
        SetTimer, __UpdateProgressBar, 100
    }
    ;Download the file
    UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
    ;Remove the timer and the progressbar because the download has finished
    If (UseProgressBar) {
        Sleep 100
        Progress, Off
        SetTimer, __UpdateProgressBar, Off
    }
    Return

    ;The label that updates the progressbar
    __UpdateProgressBar:
        ;Get the current filesize and tick
        CurrentSize := FileOpen(SaveFileAs, "r").Length ;FileGetSize wouldn't return reliable results
        CurrentSizeTick := A_TickCount
        ;Calculate the downloadspeed
        ;Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " Kb/s"
        ;Save the current filesize and tick for the next time
        ;LastSizeTick := CurrentSizeTick
        ;LastSize := FileOpen(SaveFileAs, "r").Length
        ;Calculate percent done
        PercentDone := Round(CurrentSize/FinalSize*100)
        ;Update the ProgressBar
        _csize:=Round(CurrentSize/1024,1)
        _fsize:=Round(FinalSize/1024)
        Progress, %PercentDone%, Downloading: %_csize% KB / %_fsize% KB [ %PercentDone%`% ], %ProgressBarTitle%
    Return
}
ShortURL(p,l=50) {
    VarSetCapacity(_p, (A_IsUnicode?2:1)*StrLen(p) )
    DllCall("shlwapi\PathCompactPathEx"
        ,"str", _p
        ,"str", p
        ,"uint", abs(l)
    ,"uint", 0)
    return _p
}
File(string)
{
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    VarSetCapacity(buf, size, 0)
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    return StrGet(&buf, size, "UTF-8")
}