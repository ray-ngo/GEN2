:: Version 2.3.75
:: 2018-03-30 RN 	HSR procedure is removed; 
::					A check for the existence of the constraining trip files is added 
::					Revised to be consitent for all model years


:: Version 2.3 TPB Travel Model on 3722 TAZ System

set _year_=2017
set _alt_=Ver2.3.75_2017
:: Maximum number of user equilibrium iterations used in traffic assignment
:: User should not need to change this.  Instead, change _relGap_ (below)
set _maxUeIter_=1000

:: Set transit constraint path and files
:: Current year used to set the constraint = 2020

set _constraintyear_=2020

:: set _tcpath_ and check for existence of constraining trip files
if %_year_% GTR %_constraintyear_% (
	set _tcpath_=%_constraintyear_%)
if %_year_% GTR %_constraintyear_% (
	if not exist    %_tcpath_%\i4_HBW_NL_MC.MTT (echo Missing i4_HBW_NL_MC.MTT of %_tcpath_% scenario, which should be run first && goto error)
	if not exist    %_tcpath_%\i4_HBS_NL_MC.MTT (echo Missing i4_HBS_NL_MC.MTT of %_tcpath_% scenario, which should be run first && goto error)
	if not exist    %_tcpath_%\i4_HBO_NL_MC.MTT (echo Missing i4_HBO_NL_MC.MTT of %_tcpath_% scenario, which should be run first && goto error)
	if not exist    %_tcpath_%\i4_NHW_NL_MC.MTT (echo Missing i4_NHW_NL_MC.MTT of %_tcpath_% scenario, which should be run first && goto error)
	if not exist    %_tcpath_%\i4_NHO_NL_MC.MTT (echo Missing i4_NHO_NL_MC.MTT of %_tcpath_% scenario, which should be run first && goto error)
)

:: UE relative gap threshold: Progressive (10^-2 for pp-i2, 10^-3 for i3, & 10^-4 for i4)
:: Set the value below

rem ====== Pump Prime Iteration ==========================================

set _iter_=pp
set _prev_=pp
set _relGap_=0.01

REM call ArcPy_Walkshed_Process.bat %1
call Set_CPI.bat                %1
call PP_Highway_Build.bat       %1
call PP_Highway_Skims.bat       %1
call Transit_Skim_All_Modes_Parallel.bat %1
call Trip_Generation.bat        %1
call Trip_Distribution.bat      %1
call PP_Auto_Drivers.bat        %1
call Time-of-Day.bat            %1
call Highway_Assignment_Parallel.bat     %1
call Highway_Skims.bat          %1

:: rem ====== Iteration 1 ===================================================

set _iter_=i1
set _prev_=pp

call Transit_Skim_All_Modes_Parallel.bat %1
call Transit_Fare.bat           %1
call Trip_Generation.bat        %1
call Trip_Distribution.bat      %1
if %_year_% GTR %_constraintyear_% (
	call Mode_Choice_TC_V23_Parallel.bat  %1
	) else ( call Mode_Choice_Parallel.bat      %1)
call Auto_Driver.bat            %1
call Time-of-Day.bat            %1
call Highway_Assignment_Parallel.bat     %1
call Highway_Skims.bat          %1

:: rem ====== Iteration 2 ===================================================

set _iter_=i2
set _prev_=i1

call Transit_Skim_All_Modes_Parallel.bat %1
call Transit_Fare.bat           %1
call Trip_Generation.bat        %1
call Trip_Distribution.bat      %1
if %_year_% GTR %_constraintyear_% (
	call Mode_Choice_TC_V23_Parallel.bat  %1
	) else ( call Mode_Choice_Parallel.bat      %1)
call Auto_Driver.bat            %1
call Time-of-Day.bat            %1
call Highway_Assignment_Parallel.bat     %1
call Average_Link_Speeds.bat    %1
call Highway_Skims.bat          %1

:: rem ====== Iteration 3 ===================================================

set _iter_=i3
set _prev_=i2
set _relGap_=0.001

call Transit_Skim_All_Modes_Parallel.bat %1
call Transit_Fare.bat           %1
call Trip_Generation.bat        %1
call Trip_Distribution.bat      %1
if %_year_% GTR %_constraintyear_% (
	call Mode_Choice_TC_V23_Parallel.bat  %1
	) else ( call Mode_Choice_Parallel.bat      %1)
call Auto_Driver.bat            %1
call Time-of-Day.bat            %1
call Highway_Assignment_Parallel.bat     %1
call Average_Link_Speeds.bat    %1
call Highway_Skims.bat          %1

:: rem ====== Iteration 4 ===================================================

set _iter_=i4
set _prev_=i3
set _relGap_=0.0001

call Transit_Skim_All_Modes_Parallel.bat %1
call Transit_Fare.bat           %1
call Trip_Generation.bat        %1
call Trip_Distribution.bat      %1
if %_year_% GTR %_constraintyear_% (
	call Mode_Choice_TC_V23_Parallel.bat  %1
	) else ( call Mode_Choice_Parallel.bat      %1)
call Auto_Driver.bat            %1
call Time-of-Day.bat            %1
call Highway_Assignment_Parallel.bat     %1
call Average_Link_Speeds.bat    %1
call Highway_Skims.bat          %1

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

:error
exit