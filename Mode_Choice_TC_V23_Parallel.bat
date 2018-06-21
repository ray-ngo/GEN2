::---------------------------------------------------
::  Nested Logit Mode Choice Model Application
::  ** WITH TRANSIT CONSTRAINT **
::---------------------------------------------------

CD %1
:: _tcpath_ is the variable containing the path for the files needed in the
:: transit constraint process.  This variable is set in runModelSteps batch file. 


:: constraining transit trip files 
set _TChbw_=%_tcpath_%\i4_HBW_NL_MC.MTT
set _TChbs_=%_tcpath_%\i4_HBS_NL_MC.MTT
set _TChbo_=%_tcpath_%\i4_HBO_NL_MC.MTT
set _TCnhw_=%_tcpath_%\i4_NHW_NL_MC.MTT
set _TCnho_=%_tcpath_%\i4_NHO_NL_MC.MTT

:: check for existence of constraining trip files
if not exist    %_tcpath_%\i4_HBW_NL_MC.MTT goto error
if not exist    %_tcpath_%\i4_HBS_NL_MC.MTT goto error
if not exist    %_tcpath_%\i4_HBO_NL_MC.MTT goto error
if not exist    %_tcpath_%\i4_NHW_NL_MC.MTT goto error
if not exist    %_tcpath_%\i4_NHO_NL_MC.MTT goto error

:: Now, go forward with standard mode choice modeling process
:: Copy iteration-specific inputs to generic names

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


::
::  COPY GENERIC MODE CHOICE OUTPUT FILES
::  TO INTERATION-SPECIFIC NAMES

if exist HBW_NL_MC.MTT copy  HBW_NL_MC.MTT  %_iter_%_HBW_NL_MC.MTT /y
if exist HBS_NL_MC.MTT copy  HBS_NL_MC.MTT  %_iter_%_HBS_NL_MC.MTT /y
if exist HBO_NL_MC.MTT copy  HBO_NL_MC.MTT  %_iter_%_HBO_NL_MC.MTT /y
if exist NHW_NL_MC.MTT copy  NHW_NL_MC.MTT  %_iter_%_NHW_NL_MC.MTT /y
if exist NHO_NL_MC.MTT copy  NHO_NL_MC.MTT  %_iter_%_NHO_NL_MC.MTT /y

if exist HBW_NL_MC.MTT del   HBW_NL_MC.MTT
if exist HBS_NL_MC.MTT del   HBS_NL_MC.MTT
if exist HBO_NL_MC.MTT del   HBO_NL_MC.MTT
if exist NHW_NL_MC.MTT del   NHW_NL_MC.MTT
if exist NHO_NL_MC.MTT del   NHO_NL_MC.MTT

if exist voya*.*  del voya*.*
if exist %_iter_%_MC_NL_SUMMARY.rpt del                 %_iter_%_MC_NL_SUMMARY.rpt
start /w Voyager.exe  ..\scripts\mc_NL_summary.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn copy voya*.prn      %_iter_%_mc_NL_summary.rpt /y
 
..\software\extrtab    %_iter_%_mc_NL_summary.rpt
if exist extrtab.out copy extrtab.out  %_iter_%_mc_NL_summary.tab /y
if exist extrtab.out del  extrtab.out
if exist temp.rpt del  temp.rpt
if exist *.tb1 copy *.tb1              %_iter_%_mc_NL_summary.txt /y
if exist *.tb1 del  *.tb1


::-------------------------------------------------
:: - End of standard mode choice modeling process -
:: - Begin transit constraint process below       -
::-------------------------------------------------

if exist voya*.*                     del voya*.*
if exist %_iter_%mc_constraint_V23.rpt   del %_iter_%mc_constraint_V23.rpt

start /w Voyager.exe  ..\scripts\mc_constraint_v23.s /start -Pvoya -S..\%1
if errorlevel 1 goto error

if exist voya*.prn copy voya*.prn       %_iter_%_mc_constraint_v23.rpt /y
..\software\extrtab                     %_iter_%_mc_constraint_V23.rpt
if exist extrtab.out copy extrtab.out   %_iter_%_mc_constraint_v23.tab /y
if exist extrtab.out del  extrtab.out

::
:: Now save the unconstrained mode choice output files (*.ucn)
:: for the purpose of checking, and then, replace the unconstrained
:: files with their constrained counterparts
::

if exist  %_iter_%_HBW_NL_MC.MTT    copy %_iter_%_HBW_NL_MC.MTT  %_iter_%_HBW_NL_MC.ucn /y
if exist  %_iter_%_HBS_NL_MC.MTT    copy %_iter_%_HBS_NL_MC.MTT  %_iter_%_HBS_NL_MC.ucn /y
if exist  %_iter_%_HBO_NL_MC.MTT    copy %_iter_%_HBO_NL_MC.MTT  %_iter_%_HBO_NL_MC.ucn /y
if exist  %_iter_%_NHW_NL_MC.MTT    copy %_iter_%_NHW_NL_MC.MTT  %_iter_%_NHW_NL_MC.ucn /y
if exist  %_iter_%_NHO_NL_MC.MTT    copy %_iter_%_NHO_NL_MC.MTT  %_iter_%_NHO_NL_MC.ucn /y

del       %_iter_%_HBW_NL_MC.MTT
del       %_iter_%_HBS_NL_MC.MTT
del       %_iter_%_HBO_NL_MC.MTT
del       %_iter_%_NHW_NL_MC.MTT
del       %_iter_%_NHO_NL_MC.MTT

if exist  %_iter_%_HBW_NL_MC.con    copy %_iter_%_HBW_NL_MC.con  %_iter_%_HBW_NL_MC.MTT /y
if exist  %_iter_%_HBS_NL_MC.con    copy %_iter_%_HBS_NL_MC.con  %_iter_%_HBS_NL_MC.MTT /y
if exist  %_iter_%_HBO_NL_MC.con    copy %_iter_%_HBO_NL_MC.con  %_iter_%_HBO_NL_MC.MTT /y
if exist  %_iter_%_NHW_NL_MC.con    copy %_iter_%_NHW_NL_MC.con  %_iter_%_NHW_NL_MC.MTT /y
if exist  %_iter_%_NHO_NL_MC.con    copy %_iter_%_NHO_NL_MC.con  %_iter_%_NHO_NL_MC.MTT /y

::
:: Finally rerun the **constrained** mode choice output files
:: through the summary process and give the RPT, TAB, and TXT files new name prefixes
::  '%_iter_%_MC_NL_CONSUMMARY' instead of '%_iter_%_MC_NL_SUMMARY'

:: Add a 10-second delay so that copy process completes before mc_NL_summary.s begins
@ping -n 11 127.0.0.1 > nul

if exist voya*.*  del voya*.*
if exist %_iter_%_MC_NL_CONSUMMARY.rpt   del       %_iter_%_MC_NL_CONSUMMARY.rpt
start /w Voyager.exe  ..\scripts\mc_NL_summary.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn copy voya*.prn      %_iter_%_mc_NL_CONSUMMARY.rpt

..\software\extrtab                    %_iter_%_mc_NL_CONSUMMARY.rpt
if exist extrtab.out copy extrtab.out  %_iter_%_mc_NL_CONSUMMARY.tab /y
if exist extrtab.out del  extrtab.out
if exist temp.rpt del  temp.rpt
if exist *.tb1 copy *.tb1              %_iter_%_mc_NL_CONSUMMARY.txt /y
if exist *.tb1 del  *.tb1

goto end

:error
REM  Processing Error....
PAUSE
:end
CD..
