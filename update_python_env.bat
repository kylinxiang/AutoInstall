@echo off
cd /d %~dp0
set aa=%path%
echo %path% | find /i "C:\Python27;"&&(echo "C:\Python27 already exists"&goto :A)
set aa=%aa%;C:\Python27
:A
echo %path% | find /i "C:\Python27\Scripts"&&(echo "C:\Python27\Scripts already exists"&goto :B)
set aa=%aa%;C:\Python27\Scripts
:B
ver | find /i "6.1"
if %ERRORLEVEL% EQU 0 (
echo "Win7"
del setx.exe
setx path "%aa%" /m
) else (
echo "XP"
setx path "%aa%" -m
)