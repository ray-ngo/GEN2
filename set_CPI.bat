cd %1

REM  CPI Establishment

if exist voya*.*      del voya*.*
if exist set_CPI.rpt  del set_CPI.rpt
start /w Voyager.exe  ..\scripts\set_CPI.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
        if exist voya*.prn  copy voya*.prn set_CPI.rpt /y


if exist voya*.*      del voya*.*
if exist set_factors.rpt  del set_factors.rpt
start /w Voyager.exe  ..\scripts\set_factors.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
        if exist voya*.prn  copy voya*.prn set_factors.rpt /y
goto end


:error
REM  Processing Error.....
PAUSE
:end
cd..
