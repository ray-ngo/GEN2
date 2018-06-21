CD %1

REM  Highway Skims

if exist voya*.*  del voya*.*
if exist %_iter_%_Highway_Skims_am.rpt  del %_iter_%_Highway_Skims_am.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_am.s /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Highway_Skims_am.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_Highway_Skims_md.rpt  del %_iter_%_Highway_Skims_md.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_md.s /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Highway_Skims_md.rpt /y

:: Treatment of HOT lane facilities in Virginia
:: HOV3+ Skim Replacement (HSR)
:: 2011-03-28 Mon 10:29:57
:: We need to delete the HOV3+ highway skims that come out of highway_skims.s
:: then, we replace them with their counterpart from the base iteration, which
:: reflect HOV3+ operations, not HOT-lane operations. 

:: AM skims
if exist %_iter_%_am_hov3_mc.skm del %_iter_%_am_hov3_mc.skm
copy %_HOV3PATH_%\%_iter_%_am_hov3_mc.skm %_iter_%_am_hov3_mc.skm /y

:: Midday skims
if exist %_iter_%_md_hov3_mc.skm del %_iter_%_md_hov3_mc.skm
copy %_HOV3PATH_%\%_iter_%_md_hov3_mc.skm %_iter_%_md_hov3_mc.skm /y
:: End of HOV3+ skim replacment


:: Additional Steps per the Nested Logit 
:: modnet.bat / Highway_Skims_Mod.bat / JoinSkims.bat ===

REM  Utility - Convert dummy centroid connectors

if exist voya*.*  del voya*.*
if exist %_iter_%_ModNet.rpt  del %_iter_%_ModNet.rpt
start /w Voyager.exe  ..\scripts\modnet.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_ModNet.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_Highway_Skims_mod_am.rpt  del %_iter_%_Highway_Skims_mod_am.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_mod_am.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Highway_Skims_Mod_am.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_Highway_Skims_mod_md.rpt  del %_iter_%_Highway_Skims_mod_md.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_mod_md.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Highway_Skims_Mod_md.rpt /y


REM  Utility - Join Highway Skims

if exist voya*.*  del voya*.*
if exist %_iter_%_JoinSkims.rpt  del %_iter_%_JoinSkims.rpt 
start /w Voyager.exe  ..\scripts\joinskims.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_JoinSkims.rpt /y


goto end
:error
REM  Processing Error....
PAUSE
:end
CD..
