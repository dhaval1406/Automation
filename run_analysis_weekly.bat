@echo off

rem set drive=%~dp0
rem set drivep=%drive%
rem if #%drive:~-1%# == #\# set drivep=%drive:~0,-1%

set PATH=C:\strawberry_perl\perl\site\bin;C:\strawberry_perl\perl\bin;C:\strawberry_perl\c\bin;%PATH%
rem env variables
set TERM=dumb
rem avoid collisions with other perl stuff on your system
set PERL_JSON_BACKEND=
set PERL_YAML_BACKEND=
set PERL5LIB=
set PERL5OPT=
set PERL_MM_OPT=
set PERL_MB_OPT=

if not #%1# == ## C:\strawberry_perl\perl\bin\perl.exe %* & goto END

rem perl -w P:\PERL\get_weblog_files.pl -t d
timethis perl -w C:\Automation\get_weblog_files.pl -t w

:END
