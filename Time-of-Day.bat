CD %1
REM --  Time of Day Process ---

REM -----------------------------------------
REM  Modeled Auto Driver Time-of-Day Trips
REM -----------------------------------------

if exist voya*.*  del voya*.*
if exist %_iter_%_Time-of-Day.rpt   del %_iter_%_Time-of-Day.rpt
start /w Voyager.exe  ..\scripts\Time-of-Day.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
copy voya*.prn          %_iter_%_Time-of-Day.rpt /y
        copy            %_iter_%_Time-of-Day.rpt temp.dat /y
        ..\software\extrtab     temp.dat
        copy    extrtab.out     %_iter_%_Time-of-Day.tab /y
        del     temp.dat




REM -----------------------------------------
REM  Truck and Exogenous Time-of-Day Trips
REM -----------------------------------------

if exist voya*.*  del voya*.*
if exist %_iter_%_Misc_Time-of-Day.rpt  del %_iter_%_Misc_Time-of-Day.rpt
start /w Voyager.exe  ..\scripts\Misc_Time-of-Day.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
copy voya*.prn            %_iter_%_Misc_Time-of-Day.rpt /y
copy                      %_iter_%_Misc_Time-of-Day.rpt temp.dat /y
..\software\extrtab       temp.dat
copy extrtab.out          %_iter_%_Misc_Time-of-Day.tab /y
del  extrtab.out
del  temp.dat

REM -----------------------------------------
REM  Prepare trips for highway assignment 
REM -----------------------------------------

if exist voya*.*  del voya*.*
if exist %_iter_%_Prepare_Trip_Tables_for_Assignment.rpt   del %_iter_%_Prepare_Trip_Tables_for_Assignment.rpt
start /w Voyager.exe  ..\scripts\Prepare_Trip_Tables_for_Assignment.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
copy voya*.prn            %_iter_%_Prepare_Trip_Tables_for_Assignment.rpt /y
copy                      %_iter_%_Prepare_Trip_Tables_for_Assignment.rpt temp.dat /y
..\software\extrtab       temp.dat
copy extrtab.out          %_iter_%_Prepare_Trip_Tables_for_Assignment.tab /y
del  extrtab.out
del  temp.dat

goto end

:error
REM  Processing Error....
PAUSE
:end
CD..

