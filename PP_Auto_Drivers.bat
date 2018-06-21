CD %1

REM  Pump Prime Auto Driver Trips

if exist voya*.*                   del voya*.*
if exist %_iter_%_Auto_Drivers.rpt del %_iter_%_Auto_Drivers.rpt

start /w Voyager.exe  ..\scripts\PP_Auto_Drivers.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Auto_Drivers.rpt /y 

..\software\extrtab    %_iter_%_Auto_Drivers.rpt 
copy extrtab.out       %_iter_%_Auto_Drivers.tab /y
del  extrtab.out


goto end
:error
REM  Processing Error....
PAUSE
:end
CD..

