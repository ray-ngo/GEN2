::----------------------------------------
::  Version 2.3 Trip Distribution Process
::----------------------------------------

CD %1

if exist voya*.*  del voya*.*
if exist %_iter_%_Prepare_Ext_Auto_Ends.rpt  del %_iter_%_Prepare_Ext_Auto_Ends.rpt
start /w Voyager.exe  ..\scripts\Prepare_Ext_Auto_Ends.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Prepare_Ext_Auto_Ends.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_Prepare_Ext_ComTruck_Ends.rpt  del %_iter_%_Prepare_Ext_ComTruck_Ends.rpt
start /w Voyager.exe  ..\scripts\Prepare_Ext_ComTruck_Ends.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Prepare_Ext_ComTruck_Ends.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_Trip_Distribution_External.rpt  del %_iter_%_Trip_Distribution_External.rpt
start /w Voyager.exe  ..\scripts\Trip_Distribution_External.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Trip_Distribution_External.rpt /y
..\software\extrtab  %_iter_%_Trip_Distribution_External.rpt
copy   extrtab.out   %_iter_%_Trip_Distribution_External.tab /y
del    extrtab.out

if exist voya*.*  del voya*.*
if exist %_iter_%_Prepare_Internal_Ends.rpt  del %_iter_%_Prepare_Internal_Ends.rpt
start /w Voyager.exe  ..\scripts\Prepare_Internal_Ends.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Prepare_Internal_Ends.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_Trip_Distribution_Internal.rpt  del %_iter_%_Trip_Distribution_Internal.rpt
start /w Voyager.exe  ..\scripts\Trip_Distribution_Internal.s /start -Pvoya -S..\%1
if errorlevel 2 goto error  REM changed from 1 to 2 due to Cube 6.4 warning of unbalanced Ps & As
if exist voya*.prn  copy voya*.prn %_iter_%_Trip_Distribution_Internal.rpt /y
..\software\extrtab  %_iter_%_Trip_Distribution_Internal.rpt
copy   extrtab.out   %_iter_%_Trip_Distribution_Internal.tab /y
del    extrtab.out


goto end

:error
REM  Processing Error......
PAUSE
:end

CD..

