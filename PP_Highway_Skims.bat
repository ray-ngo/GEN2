CD %1
set _iterOrder_=initial

REM  Highway Skims 

:: COPY ZONEHWY.NET TEMPORARILY TO PPHWY.NET 

if exist ZONEHWY.NET  COPY ZONEHWY.NET PP_HWY.NET /y

if exist voya*.*  del voya*.*
if exist %_iter_%_%_iterOrder_%_Highway_Skims_am.rpt  del %_iter_%_%_iterOrder_%_Highway_Skims_am.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_am.s /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_%_iterOrder_%_Highway_Skims_am.rpt /y

ping -n 11 127.0.0.1 > nul

if exist voya*.*  del voya*.*
if exist %_iter_%_%_iterOrder_%_Highway_Skims_md.rpt  del %_iter_%_%_iterOrder_%_Highway_Skims_md.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_md.s /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_%_iterOrder_%_Highway_Skims_md.rpt /y


:: Additional Steps per the Nested Logit 
:: modnet.bat / Highway_Skims_Mod.bat / JoinSkims.bat ===

REM  Utility - Convert dummy centroid connectors

if exist voya*.*  del voya*.*
if exist %_iter_%_%_iterOrder_%_ModNet.rpt  del %_iter_%_%_iterOrder_%_ModNet.rpt
start /w Voyager.exe  ..\scripts\modnet.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_%_iterOrder_%_ModNet.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_%_iterOrder_%_Highway_Skims_mod_am.rpt  del %_iter_%_%_iterOrder_%_Highway_Skims_mod_am.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_mod_am.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_%_iterOrder_%_Highway_Skims_Mod_am.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_%_iterOrder_%_Highway_Skims_mod_md.rpt  del %_iter_%_%_iterOrder_%_Highway_Skims_mod_md.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_mod_md.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_%_iterOrder_%_Highway_Skims_Mod_md.rpt /y


:: ----- Save initial highway skims to special names for later checking

if exist pp_am_SOV.SKM   copy pp_am_SOV.SKM     pp_am_SOV_Initial.SKM /y
if exist pp_md_SOV.SKM   copy pp_md_SOV.SKM     pp_md_SOV_Initial.SKM /y
if exist pp_am_HOV2.SKM  copy pp_am_HOV2.SKM    pp_am_HOV2_Initial.SKM /y
if exist pp_md_HOV2.SKM  copy pp_md_HOV2.SKM    pp_md_HOV2_Initial.SKM /y
if exist pp_am_HOV3.SKM  copy pp_am_HOV3.SKM    pp_am_HOV3_Initial.SKM /y
if exist pp_md_HOV3.SKM  copy pp_md_HOV3.SKM    pp_md_HOV3_Initial.SKM /y
  
if exist pp_am_SOV_mod.SKM  copy pp_am_SOV_mod.SKM    pp_am_SOV_mod_Initial.SKM /y
if exist pp_md_SOV_mod.SKM  copy pp_md_SOV_mod.SKM    pp_md_SOV_mod_Initial.SKM /y
if exist pp_am_HOV2_mod.SKM copy pp_am_HOV2_mod.SKM   pp_am_HOV2_mod_Initial.SKM /y
if exist pp_md_HOV2_mod.SKM copy pp_md_HOV2_mod.SKM   pp_md_HOV2_mod_Initial.SKM /y
if exist pp_am_HOV3_mod.SKM copy pp_am_HOV3_mod.SKM   pp_am_HOV3_mod_Initial.SKM /y
if exist pp_md_HOV3_mod.SKM copy pp_md_HOV3_mod.SKM   pp_md_HOV3_mod_Initial.SKM /y

::  ----- the PP_??.SKM files will be overwritten after the skimming
::  ----- of the PP Highway assignment network 

REM  Utility - Join Highway Skims

if exist voya*.*  del voya*.*
if exist %_iter_%_%_iterOrder_%_JoinSkims.rpt  del %_iter_%_%_iterOrder_%_JoinSkims.rpt
start /w Voyager.exe  ..\scripts\joinskims.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_%_iterOrder_%_JoinSkims.rpt /y

:: DELETE TEMPORARY ppHWY.NET, THIS WILL BE CREATED AFTER the PP HIGHWAY ASSIGNMENT 

rem if exist PP_HWY.NET del PP_HWY.NET 


if exist voya*.*  del voya*.*
if exist %_iter_%_%_iterOrder_%_Remove_PP_Speed.rpt  del %_iter_%_%_iterOrder_%_Remove_PP_Speed.rpt
start /w Voyager.exe  ..\scripts\Remove_PP_Speed.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_%_iterOrder_%_Remove_PP_Speed.rpt /y


goto end
:error
REM  Processing Error....
PAUSE
:end
CD..
set _iterOrder_=