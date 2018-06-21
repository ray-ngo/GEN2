::----------------------------------------
::  Version 2.3 Trip Generation Process --
::----------------------------------------

CD %1


if exist voya*.*  del voya*.*
if exist %_iter_%_Demo_Models.rpt  del %_iter_%_Demo_Models.rpt
start /w Voyager.exe  ..\scripts\Demo_Models.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Demo_Models.rpt /y


if exist voya*.*  del voya*.*
if exist %_iter_%_Trip_Generation.rpt  del %_iter_%_Trip_Generation.rpt
start /w Voyager.exe  ..\scripts\Trip_Generation.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Trip_Generation.rpt /y


if exist voya*.*  del voya*.*
if exist %_iter_%_Trip_Generation_Summary.rpt  del %_iter_%_Trip_Generation_Summary.rpt
start /w Voyager.exe  ..\scripts\Trip_Generation_Summary.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Trip_Generation_Summary.rpt /y


if exist voya*.*  del voya*.*
if exist %_iter_%_Truck_Com_Trip_Generation.rpt  del %_iter_%_Truck_Com_Trip_Generation.rpt
start /w Voyager.exe  ..\scripts\Truck_Com_Trip_Generation.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Truck_Com_Trip_Generation.rpt /y


goto end


:error
REM  Processing Error......
PAUSE
:end

CD..

