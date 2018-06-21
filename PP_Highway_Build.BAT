cd %1

REM  Highway Network Building

if exist voya*.*             del voya*.*
if exist AreaType_File.rpt   del AreaType_File.rpt
start /w Voyager.exe  ..\scripts\AreaType_File.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn  AreaType_File.rpt /y
 


if exist voya*.*            del voya*.*
if exist highway_build_toll.rpt  del V2.3_highway_build.rpt
start /w Voyager.exe      ..\scripts\V2.3_highway_build.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn copy voya*.prn    V2.3_highway_build.rpt /y
if exist temp.net           del temp.net 

goto end


:error
REM  Processing Error.....
PAUSE
:end
cd..
