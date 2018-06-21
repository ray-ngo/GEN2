::--------------------------------------
::  Version 2.3 Transit Fare Process
::--------------------------------------

CD %1



if exist voya*.*  del voya*.*
if exist %_iter_%_prefarV23.rpt  del %_iter_%_prefarV23.rpt
start /w Voyager.exe  ..\scripts\prefarV23.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_prefarV23.rpt /y



if exist voya*.*  del voya*.*
if exist %_iter_%_Metrorail_skims.rpt  del %_iter_%_Metrorail_skims.rpt
start /w Voyager.exe  ..\scripts\Metrorail_skims.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Metrorail_skims.rpt /y


if exist voya*.*  del voya*.*
if exist %_iter_%_MFARE1.rpt  del %_iter_%_MFARE1.rpt
start /w Voyager.exe  ..\scripts\MFARE1.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_MFARE1.rpt /y


if exist voya*.*  del voya*.*
if exist %_iter_%_MFARE2.rpt  del %_iter_%_MFARE2.rpt
Cluster.exe MWCOG %subnode% start exit 
start /w Voyager.exe  ..\scripts\MFARE2.s /start -Pvoya -S..\%1
if errorlevel 1 goto error      ; Moved from line 37 to correctly report errors on MFARE2 report file
Cluster.exe MWCOG %subnode% close exit
echo %ERRORLEVEL%              ; Added to report Errorlevel return code
if exist voya*.prn  copy voya*.prn %_iter_%_MFARE2.rpt /y


if exist voya*.*  del voya*.*
if exist %_iter_%_Assemble_Skims_MR.rpt  del %_iter_%_Assemble_Skims_MR.rpt
start /w Voyager.exe  ..\scripts\Assemble_Skims_MR.s  /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Assemble_Skims_MR.rpt /y


if exist voya*.*  del voya*.*
if exist %_iter_%_Assemble_Skims_BM.rpt  del %_iter_%_Assemble_Skims_BM.rpt
start /w Voyager.exe  ..\scripts\Assemble_Skims_BM.s  /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Assemble_Skims_BM.rpt /y


if exist voya*.*  del voya*.*
if exist %_iter_%_Assemble_Skims_AB.rpt  del %_iter_%_Assemble_Skims_AB.rpt
start /w Voyager.exe  ..\scripts\Assemble_Skims_AB.s  /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Assemble_Skims_AB.rpt /y


if exist voya*.*  del voya*.*
if exist %_iter_%_Assemble_Skims_CR.rpt  del %_iter_%_Assemble_Skims_CR.rpt
start /w Voyager.exe  ..\scripts\Assemble_Skims_CR.s  /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Assemble_Skims_CR.rpt /y

goto end


:error
REM  Processing Error......
PAUSE
:end

CD..

