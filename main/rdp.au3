#Region ;**** 参数创建于 ACNWrapper_GUI ****
#PRE_UseX64=n
#PRE_Res_requestedExecutionLevel=None
#EndRegion ;**** 参数创建于 ACNWrapper_GUI ****
#include <GUIConstantsEx.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>

$host = $CmdLine[1]
$device = $CmdLine[2]
$type = $CmdLine[3]

;Remote Desktop ActiveX Control Interfaces -> http://msdn.microsoft.com/en-us/library/aa383022(v=VS.85).aspx
$hGUI = GUICreate("RDP Embedded Sessions", 952, 675, -1, -1, $WS_OVERLAPPEDWINDOW + $WS_CLIPSIBLINGS + $WS_CLIPCHILDREN)
$oRDP = ObjCreate("MsTscAx.MsTscAx.2") ;http://msdn.microsoft.com/en-us/library/aa381344(v=VS.85).aspx
$oRDP_Ctrl = GUICtrlCreateObj($oRDP, 64, 44, 800, 600)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetStyle($oRDP_Ctrl , $WS_VISIBLE)
AutoItSetOption("MouseCoordMode", 2)
$oRDP.DesktopWidth = 800
$oRDP.DesktopHeight = 600
$oRDP.Fullscreen = False
$oRDP.ColorDepth = 16
$oRDP.AdvancedSettings3.SmartSizing = True
$oRDP.Server = $host
$oRDP.UserName = "upl1-tester" ;<<<<<<< enter here the user name
$oRDP.Domain = ""
$oRDP.AdvancedSettings2.ClearTextPassword = "btstest"
$oRDP.ConnectingText = "Connecting to " & $host
$oRDP.DisconnectedText = "Disconnected from " & $host
$oRDP.StartConnected = True
$oRDP.Connect()

GUISetState(@SW_SHOW, $hGUI)
open_cmd()

Sleep(3000)
Send("del C:\Users\upl1-tester\*.exe{ENTER}")
sleep(1000)
Send("del C:\Users\upl1-tester\*.msi{ENTER}")
sleep(1000)
Send("ftp 10.69.195.222{ENTER}")
Sleep(2000)
Send("microrec{ENTER}")
Sleep(1000)
Send("microrec{ENTER}")
Sleep(1000)
Send("cd /TA/AutoInstall/SW{ENTER}")
Sleep(1000)
Send("get Close_UAC.vbs{ENTER}")
Sleep(1000)
Send("get download.exe{ENTER}")
Sleep(3000)
Send("bye{ENTER}")

Sleep(1000)
Send("cscript //nologo Close_UAC.vbs{ENTER}")
Sleep(2000)
Send("+{TAB}")
Sleep(1000)
Send("{ENTER}")
Sleep(1000)
$fileStatus = FileExists("C:\Users\upl1-tester\Autoinstall_Status")
If $fileStatus==0 Then
    DirCreate("C:\Users\upl1-tester\Autoinstall_Status")
EndIf
FileDelete("C:\Users\upl1-tester\callback_succeed.txt")

If $device == "TM500" or $device == "RNC" Then
    Send("echo "&$type&"> Device_Type.txt{ENTER}")
ElseIf $device == "BTS" or $device == "DCT" Then
    Send("echo "&$device&"> Device_Type.txt{ENTER}")
EndIf
Send("download.exe{ENTER}")
Sleep(1000)
$num = 0
Do
    $fileExist = FileExists("C:\Users\upl1-tester\callback_succeed.txt")
    Sleep(1000)
    $num = $num + 1
    If $num == 1200 Then
        $fileExist = 1
    EndIf
Until $fileExist = 1
Sleep(1000)
FileDelete("C:\Users\upl1-tester\callback_succeed.txt")
Sleep(1000)
$oRDP.Disconnect()
Sleep(1000)
WinClose("RDP Embedded Sessions")
Sleep(1000)
Exit 1

Func open_cmd()
    Sleep(5000)
    Send("!{home}")
    Sleep(1000)
    ;todo:
    ;other app start with r may be invoke
    Send("r")
    Sleep(1000)
    Send("telnet 10.69.216.207{ENTER}")
    Sleep(2000)
    Send('upl1-tester{Enter}')
    Sleep(500)
    Send('btstest{Enter}')
    Sleep(500)
    Send('{Enter}')
    Sleep(500)
    Send('d:{Enter}')
    Sleep(500)
    Send('echo "xp" > 1.txt{Enter}')
    Sleep(1000)
    Send('exit{Enter}')
    Sleep(500)
    Send('exit{Enter}')

    If FileExists('d:\1.txt') Then
        $os_ver = "xp"
        FileDelete('d:\1.txt')
    Else
        $os_ver = 'win7'
    EndIf

    If $os_ver == 'win7' Then
        Send("!{home}")
        Sleep(1000)
        Send("cmd{Enter}")
        Sleep(1000)
    Else
        Send("!{home}")
        Sleep(1000)
        Send("r{Enter}")
        Sleep(1000)
        Send("cmd{Enter}")
        Sleep(2000)
        Send("md C:\Users\upl1-tester{ENTER}")
        Sleep(1000)
        Send("cd C:\Users\upl1-tester{ENTER}")
        Sleep(1000)
    EndIf
EndFunc