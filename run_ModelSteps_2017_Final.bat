:: E:\Data\fy18\CGV2_3_70_Conformity2016_off_cycle_Xmittal\run_ModelSteps_2017_Final.bat
:: Version 2.3.70
:: 10/25/2016 3:59:28 PM


:: Version 2.3 TPB Travel Model on 3722 TAZ System

set _year_=2017
set _alt_=Ver2.3.70_2017_Final
:: Maximum number of user equilibrium iterations used in traffic assignment
:: User should not need to change this.  Instead, change _relGap_ (below)
set _maxUeIter_=1000

:: Set transit constraint path and files
:: Current year used to set the constraint = 2020
:: For years before constraint year:  set _tcpath_=<blank>
:: For years after  constraint year:  set _tcpath_=..\2020_final
set _tcpath_=

:: Location of substitute HOV3+ skims
set _HOV3PATH_=..\2017_base

:: UE relative gap threshold: Progressive (10^-2 for pp-i2, 10^-3 for i3, & 10^-4 for i4)
:: Set the value below

rem ====== Pump Prime Iteration ==========================================

set _iter_=pp
set _prev_=pp
set _relGap_=0.01

call ArcPy_Walkshed_Process.bat %1
call Set_CPI.bat                %1
call PP_Highway_Build.bat       %1
call PP_Highway_Skims.bat       %1
call Transit_Skim_All_Modes_Parallel.bat %1
call Trip_Generation.bat        %1
call Trip_Distribution.bat      %1
call PP_Auto_Drivers.bat        %1
call Time-of-Day.bat            %1
call Highway_Assignment_Parallel.bat     %1
REM rem  call Highway_Skims.bat          %1
call HSR_Highway_Skims_2017HOV2.bat    %1

:: rem ====== Iteration 1 ===================================================

set _iter_=i1
set _prev_=pp

call Transit_Skim_All_Modes_Parallel.bat %1
call Transit_Fare.bat           %1
call Trip_Generation.bat        %1
call Trip_Distribution.bat      %1
call Mode_Choice_Parallel.bat            %1
call Auto_Driver.bat            %1
call Time-of-Day.bat            %1
call Highway_Assignment_Parallel.bat     %1
rem  call Highway_Skims.bat          %1
call HSR_Highway_Skims_2017HOV2.bat    %1

:: rem ====== Iteration 2 ===================================================

set _iter_=i2
set _prev_=i1

call Transit_Skim_All_Modes_Parallel.bat %1
call Transit_Fare.bat           %1
call Trip_Generation.bat        %1
call Trip_Distribution.bat      %1
call Mode_Choice_Parallel.bat            %1
call Auto_Driver.bat            %1
call Time-of-Day.bat            %1
call Highway_Assignment_Parallel.bat     %1
call Average_Link_Speeds.bat    %1
rem  call Highway_Skims.bat          %1
call HSR_Highway_Skims_2017HOV2.bat    %1

:: rem ====== Iteration 3 ===================================================

set _iter_=i3
set _prev_=i2
set _relGap_=0.001

call Transit_Skim_All_Modes_Parallel.bat %1
call Transit_Fare.bat           %1
call Trip_Generation.bat        %1
call Trip_Distribution.bat      %1
call Mode_Choice_Parallel.bat            %1
call Auto_Driver.bat            %1
call Time-of-Day.bat            %1
call Highway_Assignment_Parallel.bat     %1
call Average_Link_Speeds.bat    %1
rem  call Highway_Skims.bat          %1
call HSR_Highway_Skims_2017HOV2.bat    %1

:: rem ====== Iteration 4 ===================================================

set _iter_=i4
set _prev_=i3
set _relGap_=0.0001

call Transit_Skim_All_Modes_Parallel.bat %1
call Transit_Fare.bat           %1
call Trip_Generation.bat        %1
call Trip_Distribution.bat      %1
call Mode_Choice_Parallel.bat            %1
call Auto_Driver.bat            %1
call Time-of-Day.bat            %1
call Highway_Assignment_Parallel.bat     %1
call Average_Link_Speeds.bat    %1
rem  call Highway_Skims.bat          %1
call HSR_Highway_Skims_2017HOV2.bat    %1

:: rem ====== Transit assignment ============================================
@echo Starting Transit Assignment Step
@date /t & time/t

call Transit_Assignment_Parallel.bat %1
call TranSum.bat %1


@echo End of batch file
@date /t & time/t
:: rem ====== End of batch file =============================================

REM cd %1
REM copy *.txt MDP_%useMDP%\*.txt
REM copy *.rpt MDP_%useMDP%\*.rpt
REM copy *.log MDP_%useMDP%\*.log
REM CD..

set _year_=
set _alt_=
set _iter_=
set _prev_=
set _maxUeIter_=
set _relGap_=
