@echo off

cd /d %~dp0
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto 64bit
if "%PROCESSOR_ARCHITECTURE%"=="x86" goto 32bit

:32bit
echo 32bit
set java_root=C:\Program Files\Java\jre6
goto set_path

:64bit
echo 64bit
set java_root=C:\Program Files (x86)\Java\jre6
goto set_path

:set_path
ver | find /i "6.1"
if %ERRORLEVEL% EQU 0 (
setx JAVA_HOME "%java_root%" /m
echo %path% | find /i "%java_root%\bin"&&(echo "Dirctory already exists"&goto :eof)
setx path "%Path%;%java_root%\bin" /m
exit
) 
setx JAVA_HOME "%java_root%" -m
echo %path% | find /i "%java_root%\bin"&&(echo "Dirctory already exists"&goto :eof)
setx path "%Path%;%java_root%\bin" -m
exit