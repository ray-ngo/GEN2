::  Transit Skimming for All Submodes
::  updated 4/27/07  copy sta_tpp.bse from inputs to output subdir.
::  updated 6/15/11  runs walkacc process for pp iteration only
::  updated 5/11/16  Update autoacc and local-bus in-vehicle speed degradation 
CD %1



:: Delete previous iteration highway skim files for Transit Skimming (if files exist)
 
if exist am_sov_mod.skm   del am_sov_mod.skm
if exist md_sov_mod.skm   del md_sov_mod.skm

:: Set up current iteration highway skim files for transit Skimming

if exist %_prev_%_am_sov_mod.skm  copy %_prev_%_am_sov_mod.skm  am_sov_mod.skm /y
if exist %_prev_%_md_sov_mod.skm  copy %_prev_%_md_sov_mod.skm  md_sov_mod.skm /y

if exist voya*.*  del voya*.*
if exist parker.rpt  del parker.rpt 
start /w Voyager.exe  ..\scripts\parker.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn parker.rpt /y

if %_iter_%==pp goto runwalk
goto skipwalk

:runwalk 

::copy transit lines and support files from the inputs subdir. 
copy inputs\*.TB /y
copy inputs\mfare1.a1 /y

::develop walk access links.
if exist voya*.*  del voya*.*
if exist walkacc.rpt  del walkacc.rpt 
start /w Voyager.exe  ..\scripts\walkacc.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn walkacc.rpt /y

::adjust local bus run times by applying bus speed degradation factors.
if exist voya*.*  del voya*.*
if exist Adjust_Runtime.rpt  del Adjust_Runtime.rpt 
start /w Voyager.exe  ..\scripts\Adjust_Runtime.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn Adjust_Runtime.rpt /y


:skipwalk
if exist voya*.*  del voya*.*
if exist autoacc5.rpt  del autoacc5.rpt 
start /w Voyager.exe  ..\scripts\autoacc5.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn autoacc5.rpt /y

rem ---------- Do some cleaning up ----------
:: del /F ..\%1\hov2m%_prev_%am.skm
:: del /F ..\%1\hov2m%_prev_%op.skm
:: del /F ..\%1\hov3m%_prev_%am.skm
:: del /F ..\%1\hov3m%_prev_%op.skm
:: del /F ..\%1\tppl*.*

CD..

:: =======================================
:: = Transit Skimming Section            =
:: =======================================

::  Transit Network Building (Final) Commuter Rail

if %useMDP%==t goto Parallel_Processing
if %useMDP%==T goto Parallel_Processing
@echo Start Transit Skims
REM   If only one CPU, run the four skims sequentially

START /wait Transit_Skim_LineHaul_Parallel.bat %1 CR 

REM  Transit Network Building (Final) Metrorail
START /wait Transit_Skim_LineHaul_Parallel.bat %1 MR 

REM  Transit Network Building (Final) All Bus
START /wait Transit_Skim_LineHaul_Parallel.bat %1 AB 

REM  Transit Network Building (Final) Bus+MetroRail
START /wait Transit_Skim_LineHaul_Parallel.bat %1 BM  

goto Transit_Skims_Are_Done

:Parallel_Processing
@echo Start Transit Skim - Parallel

START Transit_Skim_LineHaul_Parallel.bat %1 CR 

REM  Transit Network Building (Final) Metrorail
START Transit_Skim_LineHaul_Parallel.bat %1 MR 

REM  Transit Network Building (Final) All Bus
START Transit_Skim_LineHaul_Parallel.bat %1 AB 

REM  Transit Network Building (Final) Bus+MetroRail
START /wait Transit_Skim_LineHaul_Parallel.bat %1 BM  

:Transit_Skims_Are_Done

CD %1

goto checkIfDone

:waitForMC
@ping -n 11 127.0.0.1

:checkIfDone

@REM Check file existence to ensure that there are no errors
if exist Transit_Skims_CR.err echo Error in Transit_Skims_CR && goto error
if exist Transit_Skims_MR.err echo Error in Transit_Skims_MR && goto error
if exist Transit_Skims_AB.err echo Error in Transit_Skims_AB && goto error
if exist Transit_Skims_BM.err echo Error in Transit_Skims_BM && goto error

@REM Check to ensure that each of the batch processes have finished successfully, if not wait.
if not exist Transit_Skims_CR.done goto waitForMC
if not exist Transit_Skims_MR.done goto waitForMC
if not exist Transit_Skims_AB.done goto waitForMC
if not exist Transit_Skims_BM.done goto waitForMC

REM @type CR.txt
REM @type MR.txt
REM @type AB.txt
REM @type BM.txt

REM CD %1
REM  Transit Network Accessibility File developement (For Demographic Models)

if exist voya*.*  del voya*.*
if exist %_iter_%_TRANSIT_Accessibility.RPT  del %_iter_%_TRANSIT_Accessibility.RPT
start /w Voyager.exe  ..\scripts\transit_Accessibility.s /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_TRANSIT_Accessibility.RPT /y
goto end
:error
REM  Processing Error......
PAUSE
:end

CD..

