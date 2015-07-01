#Region ;**** Ã‚Â²ÃƒÅ½ÃƒÅ ÃƒÂ½Ã‚Â´Ã‚Â´Ã‚Â½Ã‚Â¨Ãƒâ€œÃƒÅ¡ ACNWrapper_GUI ****
#PRE_UseX64=n
#PRE_Res_requestedExecutionLevel=None
#EndRegion ;**** Ã‚Â²ÃƒÅ½ÃƒÅ ÃƒÂ½Ã‚Â´Ã‚Â´Ã‚Â½Ã‚Â¨Ãƒâ€œÃƒÅ¡ ACNWrapper_GUI ****
#RequireAdmin
#include<Timers.au3>
Global $keyword,$displayname
Global $code,$a

Opt("WinTitleMatchMode", 3)

If FileExists("C:\Users\upl1-tester\Device_Type.txt") Then
    Local $file = FileOpen("C:\Users\upl1-tester\Device_Type.txt", 0)
	If $file = -1 Then
		MsgBox(4096, "Error", "Cannot open this file.")
		Exit
	EndIf
	Local $type_date = FileReadLine($file)
	FileClose($file)

	Select 
		case $type_date = "BTS"
			install_SVN()
			install_python()
			install_java()
			install_robot()
			install_wxpython()
			install_robot_ride()
		case $type_date = "DCT"
			install_SVN()
			install_python()
		case $type_date = "A" Or $type_date = "B" Or $type_date = "C"
			install_SVN()
			install_python()
			install_robot()
		case $type_date = "Artiza" Or $type_date = "SRAC"
			install_SVN()
			install_python()
	EndSelect
	RunWait("callback_config.exe", "", @SW_MAXIMIZE, 0x10000)
EndIf

Func install_java()
    ShellExecute ( ".\jre-6u37-windows-i586.exe")
    Do
        Sleep(1000)
    Until(WinExists("Java Setup - Welcome"))
    if WinExists("Java Setup - Welcome") then
        ControlClick("Java Setup - Welcome","","[CLASS:Button; INSTANCE:3]","left")
        Do
            Sleep(1000)
		Until(WinExists("Java Setup - Complete") or WinExists("Java Setup")  or WinExists("Java 安装"))
        if WinExists("Java Setup - Complete") then
			While ControlCommand("Java Setup - Complete","","[CLASS:Button; INSTANCE:2]","IsEnabled")
				ControlClick("Java Setup - Complete","","[CLASS:Button; INSTANCE:2]","left")
				Sleep(500)
			WEnd
            ShellExecute  (".\update_java_env.bat",@SW_HIDE)
        elseif WinExists("Java Setup") then
			While WinExists("Java Setup")
				ControlClick("Java Setup","","[CLASS:Button; INSTANCE:1]","left")
				Sleep(500)
			WEnd
        elseif WinExists("Java 安装") then
			While WinExists("Java 安装")
				ControlClick("Java 安装","","[CLASS:Button; INSTANCE:1]","left")
				Sleep(500)
			WEnd
        endif
    endif
EndFunc

Func install_robot()
    Local $pid=ShellExecute ( ".\robotframework-2.8.4.win32.exe")
    Do
        Sleep(500)
    Until WinExists("Setup robotframework-2.8.4")
    Do
        Sleep(500)
    Until WinExists("Setup")
    ControlClick("Setup","",12324,"left")
    Sleep(200)
    ControlClick("Setup","",12324,"left")
    Sleep(200)
    ControlClick("Setup","",12324,"left")
    Do
        Sleep(1000)
    Until ControlCommand("Setup","",1004,"IsVisible")
    Sleep(5000)
    Do
        Sleep(1000)
    Until ControlCommand("Setup","","Finish","IsEnabled")
    Sleep(500)
    while WinExists("Setup")
        Sleep(1000)
        ControlClick("Setup","","Finish","left")
    wend
    Sleep(1000)
    ProcessClose($pid)
EndFunc

Func install_wxpython()
    Local $pid=ShellExecute ( ".\wxPython3.0-win32-3.0.2.0-py27.exe")
    Do
        Sleep(1000)
    Until WinExists("Setup - wxPython3.0-py27")
    Local $hWnd = WinWait("Setup - wxPython3.0-py27")
    ControlClick($hWnd, "", "[CLASS:TNewButton; INSTANCE:1]","left")
    Sleep(1000)
    ControlCommand("Setup - wxPython3.0-py27", "", "[CLASS:TNewRadioButton; INSTANCE:1]", "Check", "")
    Sleep(500)
    ControlClick($hWnd, "", "[CLASS:TNewButton; INSTANCE:2]","left")
    Sleep(500)
    ControlClick($hWnd, "", "[CLASS:TNewButton; INSTANCE:3]","left")
    Sleep(2000)
    ;path does exist
    if (WinExists("Setup")) Then
    ;reinstall by the way of uninstall
        ControlClick("Setup", "",6 )
        sleep(2000)
    Endif
    if (WinExists("Uninstall")) Then
        ControlClick("Uninstall", "","OK")
        sleep(2000)
    Endif
    ControlClick($hWnd, "", "[CLASS:TNewButton; INSTANCE:3]","left")
    Sleep(200)
    Do
        Sleep(1000)
    Until ControlCommand($hWnd, "", "&Finish","IsEnabled")
    ControlClick($hWnd, "", "&Next >")
    sleep(200)
    ControlClick($hWnd,"","[CLASS:TNewCheckListBox]","left",1,40,10)
    sleep(500)
    ControlClick($hWnd,"","&Finish")
    Sleep(10000)
    ProcessClose($pid)
EndFunc

Func install_robot_ride()
    Local $pid=ShellExecute ( ".\robotframework-ride-1.3.win32.exe")
    Do
        Sleep(1000)
    Until WinExists("Setup")
    Sleep(500)
    ControlClick("Setup","",12324,"left")
    Sleep(200)
    ControlClick("Setup","",12324,"left")
    Sleep(200)
    ControlClick("Setup","",12324,"left")
    Do
        Sleep(500)
    Until(ControlCommand("Setup","","Finish","IsVisible") Or ControlCommand("Setup","",6,"IsEnabled"))
    Sleep(500)
    If ControlCommand("Setup","",6,"IsEnabled") Then
        Sleep(500)
        ControlClick("Setup","",6,"left")
    EndIf
    Sleep(500)
    Do
        Sleep(1000)
    Until ControlCommand("Setup","","Finish","IsEnabled")
    Sleep(500)
    ControlClick("Setup","","Finish","left")
    Sleep(2000)
    ProcessClose($pid)
EndFunc

Func install_SVN()
    install_SVN_32bit()
    install_SVN_64bit()
EndFunc

Func install_SVN_32bit()
    Local $pid = ShellExecute ( ".\TortoiseSVN-1.7.11.23600-win32-svn-1.7.8.msi")
    Do
        If WinExists("Installer Information") Then
            WinClose("Installer Information")
            ProcessClose ($pid)
            Return
        EndIf
        Sleep(1000)
    Until WinExists("TortoiseSVN 1.7.11.23600 (32 bit) Setup") And ControlCommand("TortoiseSVN 1.7.11.23600 (32 bit) Setup","",680,"IsEnabled")
    ControlClick("TortoiseSVN 1.7.11.23600 (32 bit) Setup","",680,"left")
    Sleep(1000)
    If ControlCommand("TortoiseSVN 1.7.11.23600 (32 bit) Setup","",784,"IsEnabled") Then
        WinClose("TortoiseSVN 1.7.11.23600 (32 bit) Setup")
        ProcessClose ($pid)
        Return
    EndIf
    Do
        Sleep(500)
    Until WinExists("TortoiseSVN 1.7.11.23600 (32 bit) License Agreement")
    Sleep(500)
    ControlClick("TortoiseSVN 1.7.11.23600 (32 bit) License Agreement","",696,"left")
    Sleep(500)
    ControlClick("TortoiseSVN 1.7.11.23600 (32 bit) License Agreement","",680,"left")
    Sleep(500)
    ControlClick("TortoiseSVN 1.7.11.23600 (32 bit) Setup","",706,"left",1,94,44)
    Send("{UP}")
    Sleep(500)
    Send("{UP}")
    Sleep(500)
    Send("{UP}")
    Sleep(500)
    Send("{UP}")
    Sleep(500)
    Send("{ENTER}")
    Sleep(500)
    ControlClick("TortoiseSVN 1.7.11.23600 (32 bit) Setup","",680,"left")
    Sleep(500)
    ControlClick("TortoiseSVN 1.7.11.23600 (32 bit) Setup","",824,"left")
    Do
        Sleep(500)
        If ControlCommand("TortoiseSVN 1.7.11.23600 (32 bit) Setup","",740,"IsEnabled") Then
            ControlClick("TortoiseSVN 1.7.11.23600 (32 bit) Setup","",740,"left")
        EndIf
    Until ControlCommand("TortoiseSVN 1.7.11.23600 (32 bit) Setup","",743,"IsEnabled")
    Sleep(500)
    ControlClick("TortoiseSVN 1.7.11.23600 (32 bit) Setup","",743,"left")
    if not ProcessExists ( "explorer.exe" ) then
        Run("explorer.exe")
    endif
EndFunc

Func install_SVN_64bit()
    Local $pid = ShellExecute ( ".\TortoiseSVN-1.8.8.25755-x64-svn-1.8.10.msi")
    Sleep(500)
    Do
        Sleep(500)
        If ControlCommand("Windows Installer","",3001,"IsEnabled") Then
            WinClose("Windows Installer")
            ProcessClose($pid)
            Return
        EndIf
    Until(WinExists("TortoiseSVN 1.8.8.25755 (64 bit) Setup") And ControlCommand("TortoiseSVN 1.8.8.25755 (64 bit) Setup","",683,"IsEnabled") )
    ControlClick("TortoiseSVN 1.8.8.25755 (64 bit) Setup","",683,"left")
    Sleep(1000)
    If ControlCommand("TortoiseSVN 1.8.8.25755 (64 bit) Setup","",787,"IsEnabled") Then
        WinClose("TortoiseSVN 1.8.8.25755 (64 bit) Setup")
        ProcessClose($pid)
        Return
    EndIf
    Do
        Sleep(500)
    Until WinExists("TortoiseSVN 1.8.8.25755 (64 bit) License Agreement")
    Sleep(500)
    ControlClick("TortoiseSVN 1.8.8.25755 (64 bit) License Agreement","",699,"left")
    Sleep(500)
    ControlClick("TortoiseSVN 1.8.8.25755 (64 bit) License Agreement","",683,"left")
    Sleep(500)
    ControlClick("TortoiseSVN 1.8.8.25755 (64 bit) Setup","",709,"left",1,94,44)
    Send("{UP}")
    Sleep(500)
    Send("{UP}")
    Sleep(500)
    Send("{UP}")
    Sleep(500)
    Send("{UP}")
    Sleep(500)
    Send("{ENTER}")
    Sleep(500)
    ControlClick("TortoiseSVN 1.8.8.25755 (64 bit) Setup","",683,"left")
    Sleep(500)
    ControlClick("TortoiseSVN 1.8.8.25755 (64 bit) Setup","",683,"left")
    Sleep(500)
    ControlClick("TortoiseSVN 1.8.8.25755 (64 bit) Setup","",827,"left")
    Do
        Sleep(500)
    Until ControlCommand("TortoiseSVN 1.8.8.25755 (64 bit) Setup","",746,"IsEnabled")
    Sleep(500)
    ControlClick("TortoiseSVN 1.8.8.25755 (64 bit) Setup","",746,"left")
    if not ProcessExists ("explorer.exe") then
        Run("explorer.exe")
    endif
EndFunc

Func install_python()
    Local $pid = ShellExecute ( ".\python-2.7.10.msi")
    Do
        Sleep(2000)
    Until WinExists("Python 2.7.10 Setup")
    Sleep(2000)
    If ControlCommand("Python 2.7.10 Setup","",1167,"IsEnabled") Then
        WinClose("Python 2.7.10 Setup")
        ProcessClose($pid)
        Return
    EndIf
    ControlClick("Python 2.7.10 Setup","",1081,"left")
    Sleep(500)
    ControlClick("Python 2.7.10 Setup","",1081,"left")
    Sleep(1000)
    If ControlCommand("Python 2.7.10 Setup","",1059,"IsEnabled") Then
        ControlClick("Python 2.7.10 Setup","",1059,"left")
        Sleep(500)
        ControlClick("Python 2.7.10 Setup","",1081,"left")
    EndIf
    Do
		Sleep(500)
	Until ControlCommand("Python 2.7.10 Setup","",1108,"IsEnabled")
    ControlClick("Python 2.7.10 Setup","",1108,"left",1,136,29)
    Sleep(1000)
    Send("{DOWN}")
    Sleep(200)
    Send("{DOWN}")
    Sleep(200)
    Send("{DOWN}")
    Sleep(200)
    Send("{DOWN}")
    Sleep(200)
    Send("{DOWN}")
    Sleep(200)
    Send("{DOWN}")
    Sleep(200)
    Send("{DOWN}")
    Sleep(200)
    ControlClick("Python 2.7.10 Setup","",1108,"left",1,98,104)
    Sleep(200)
    Send("{DOWN}")
    Sleep(200)
    Send("{ENTER}")
    Sleep(1000)
    ControlClick("Python 2.7.10 Setup","",1081,"left")
    Do
        Sleep(1000)
    Until ControlCommand("Python 2.7.10 Setup","",1020,"IsEnabled")
    ControlClick("Python 2.7.10 Setup","",1020,"left")
    ShellExecute (".\update_python_env.bat",@SW_HIDE)
EndFunc
