@echo off

rem set drive=%~dp0
rem set drivep=%drive%
rem if #%drive:~-1%# == #\# set drivep=%drive:~0,-1%

rem set PATH=%drivep%\R-3.0.1\bin\x64;%PATH%
set PATH=C:\Program Files\R\R-3.0.1\bin\x64;%PATH%

rem env variables
set TERM=dumb

rem if not #%1# == ## "%drivep%\R-3.0.1\bin\x64\R.exe" %* & goto END
if not #%1# == ## "C:\Program Files\R\R-3.0.1\bin\x64\R.exe" %* & goto END

echo ----------------------------------------------
echo  Welcome to R 

echo ----------------------------------------------
if ERRORLEVEL==1 echo.&echo FATAL ERROR: 'R' does not work; check if your strawberry pack is complete!
echo.

R --vanilla < P:\R\Analysis2.R

:END

pause  