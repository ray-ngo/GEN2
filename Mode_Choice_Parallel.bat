@rem  Nested Logit Mode Choice Model Application
@echo off
CD %1

@rem Copy iteration-specific inputs to generic names

if exist %_iter_%_hbw_NL.ptt  copy  %_iter_%_hbw_NL.ptt   HBW_INCOME.PTT /y
if exist %_iter_%_hbs_NL.ptt  copy  %_iter_%_hbs_NL.ptt   HBS_INCOME.PTT /y
if exist %_iter_%_hbo_NL.ptt  copy  %_iter_%_hbo_NL.ptt   HBO_INCOME.PTT /y
if exist %_iter_%_nhw_NL.ptt  copy  %_iter_%_nhw_NL.ptt   NHW_INCOME.PTT /y
if exist %_iter_%_nho_NL.ptt  copy  %_iter_%_nho_NL.ptt   NHO_INCOME.PTT /y
    
if exist %_prev_%_hwy_AM.SKM  copy %_prev_%_hwy_AM.SKM        HWYAM.SKM /y
if exist %_prev_%_hwy_OP.SKM  copy %_prev_%_hwy_OP.SKM        HWYOP.SKM /y
    
if exist %_iter_%_TRNAM_CR.SKM copy %_iter_%_TRNAM_CR.SKM TRNAM_CR.SKM /y
if exist %_iter_%_TRNAM_AB.SKM copy %_iter_%_TRNAM_AB.SKM TRNAM_AB.SKM /y 
if exist %_iter_%_TRNAM_MR.SKM copy %_iter_%_TRNAM_MR.SKM TRNAM_MR.SKM /y 
if exist %_iter_%_TRNAM_BM.SKM copy %_iter_%_TRNAM_BM.SKM TRNAM_BM.SKM /y 
     
if exist %_iter_%_TRNOP_CR.SKM copy %_iter_%_TRNOP_CR.SKM TRNOP_CR.SKM /y
if exist %_iter_%_TRNOP_AB.SKM copy %_iter_%_TRNOP_AB.SKM TRNOP_AB.SKM /y 
if exist %_iter_%_TRNOP_MR.SKM copy %_iter_%_TRNOP_MR.SKM TRNOP_MR.SKM /y 
if exist %_iter_%_TRNOP_BM.SKM copy %_iter_%_TRNOP_BM.SKM TRNOP_BM.SKM /y 


if %useMDP%==t goto Parallel_Processing
if %useMDP%==T goto Parallel_Processing

REM   If only one CPU, run the five purposes sequentially
@echo Starting Mode Choice
@date /t & time/t

START /high /wait CALL ../MC_purp.bat %1 NHO
START /high /wait CALL ../MC_purp.bat %1 HBS
START /high /wait CALL ../MC_purp.bat %1 NHW
START /high /wait CALL ../MC_purp.bat %1 HBO
START /high /wait CALL ../MC_purp.bat %1 HBW

goto Mode_Choice_is_Done

:Parallel_Processing
@echo Starting Mode Choice - Parallel Processing
@date /t & time/t

START /high CALL ../MC_purp.bat %1 NHO
@ping -n 11 127.0.0.1
START /high CALL ../MC_purp.bat %1 HBS
@ping -n 11 127.0.0.1
START /high CALL ../MC_purp.bat %1 NHW
@ping -n 11 127.0.0.1
START /high CALL ../MC_purp.bat %1 HBO
@ping -n 11 127.0.0.1
START /high /wait CALL ../MC_purp.bat %1 HBW



goto checkIfDone

:waitForMC
@ping -n 11 127.0.0.1

:checkIfDone

@REM Check file existence to ensure that there are no errors
if exist HBO.err echo Error in HBO MC && goto error
if exist HBS.err echo Error in HBS MC && goto error
if exist HBW.err echo Error in HBW MC && goto error
if exist NHO.err echo Error in NHO MC && goto error
if exist NHW.err echo Error in NHW MC && goto error

@REM Check to ensure that each of the batch processes have finished successfully, if not wait.
if not exist HBO.done goto waitForMC
if not exist HBS.done goto waitForMC
if not exist HBW.done goto waitForMC
if not exist NHO.done goto waitForMC
if not exist NHW.done goto waitForMC

:Mode_Choice_is_Done
@rem -  This step is to collect all the output from the MC to the log file.
@type HBW.txt
@type HBS.txt
@type HBO.txt
@type NHW.txt
@type NHO.txt


@echo Finished Mode Choice
@date /t & time/t

@rem  COPY GENERIC MODE CHOICE OUTPUT FILES 
@rem  TO INTERATION-SPECIFIC NAMES

if exist HBW_NL_MC.MTT copy  HBW_NL_MC.MTT  %_iter_%_HBW_NL_MC.MTT /y
if exist HBS_NL_MC.MTT copy  HBS_NL_MC.MTT  %_iter_%_HBS_NL_MC.MTT /y
if exist HBO_NL_MC.MTT copy  HBO_NL_MC.MTT  %_iter_%_HBO_NL_MC.MTT /y
if exist NHW_NL_MC.MTT copy  NHW_NL_MC.MTT  %_iter_%_NHw_NL_MC.MTT /y        
if exist NHO_NL_MC.MTT copy  NHO_NL_MC.MTT  %_iter_%_NHO_NL_MC.MTT /y        
       
@ping -n 11 127.0.0.1

if exist voya*.*  del voya*.*
if exist %_iter_%_MC_NL_SUMMARY.rpt del                 %_iter_%_MC_NL_SUMMARY.rpt

start /w Voyager.exe  ..\scripts\mc_NL_summary.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn copy voya*.prn      %_iter_%_mc_NL_summary.rpt /y
if exist voya*.prn copy voya*.prn      temp.rpt /y
..\software\extrtab temp.rpt
if exist extrtab.out copy extrtab.out    %_iter_%_mc_NL_summary.tab /y
if exist extrtab.out del  extrtab.out
if exist temp.rpt del  temp.rpt
if exist *.tb1 copy *.tb1          %_iter_%_mc_NL_summary.txt /y
if exist *.tb1 del  *.tb1 

goto end

:error
@echo Error in Mode Choice
@rem  Processing Error....
PAUSE
:end
CD..