Call x86Win32ScriptingElevate()

Dim OperationRegistry

set OperationRegistry=WScript.CreateObject("WScript.Shell")
OperationRegistry.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorAdmin",5,"REG_DWORD"
OperationRegistry.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA",1,"REG_DWORD"
OperationRegistry.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\PromptOnSecureDesktop",1,"REG_DWORD"

OperationRegistry.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorAdmin",0,"REG_DWORD"
OperationRegistry.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA",0,"REG_DWORD"
OperationRegistry.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\PromptOnSecureDesktop",0,"REG_DWORD"

WScript.Quit

Sub x86Win32ScriptingElevate()

  Dim VBSExe, Tst, TxtArg, i
  If wscript.arguments.named.exists("elevated") = True then Exit Sub
  
  Dim Args : Set Args  = Wscript.Arguments
  For  i = 0 to Args.Count - 1   
    TxtArg = TxtArg & " " & Args( i )
  Next
    TxtArg = Trim( TxtArg )

  VBSExe = UCase( WScript.FullName )

  Tst = Replace( VBSExe, "\SYSTEM32\", "\SYSWOW64\" )
  If CreateObject("Scripting.FileSystemObject").FileExists( Tst ) Then VBSExe = Tst


  Tst = createobject("Shell.Application").ShellExecute( """" & VBSExe & """", """" & wscript.scriptfullname & """ " & TxtArg & " /elevated", "", "runas", 1 )

  WScript.Quit( Tst )

End Sub 