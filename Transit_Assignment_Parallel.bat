CD %1

:: Combine Mode Choice Output for Transit Assignment

if exist voya*.* del voya*.*
if exist %_iter_%_Combine_Tables_For_TrAssign_Parallel.RPT del %_iter_%_Combine_Tables_For_TrAssign_Parallel.RPT

Cluster.exe MWCOG %subnode% start exit
start /w voyager.exe ..\Scripts\Combine_Tables_For_TrAssign_Parallel.s /start -Pvoya -S..\%1
Cluster.exe MWCOG %subnode% close exit

if errorlevel 2 goto error
if exist voya*.prn copy voya*.prn %_iter_%_Combine_Tables_For_TrAssign_Parallel.RPT /y
CD..

:: =======================================
:: = Transit Assignment Section          =
:: =======================================

::  Transit Assignment Commuter Rail

if %useMDP%==t goto Parallel_Processing
if %useMDP%==T goto Parallel_Processing
@echo Start Transit Assignments 

START /wait Transit_Assignment_LineHaul_Parallel.bat %1 CR

::  Transit Assignment Metrorail
START /wait Transit_Assignment_LineHaul_Parallel.bat %1 MR

::  Transit Assignment All Bus
START /wait Transit_Assignment_LineHaul_Parallel.bat %1 AB

::  Transit Assignment Bus and Metrorail
START /wait Transit_Assignment_LineHaul_Parallel.bat %1 BM

goto Transit_Assignmets_Are_Done

:Parallel_Processing
@echo Start Transit Assignments - Parallel

START Transit_Assignment_LineHaul_Parallel.bat %1 CR
@ping -n 11 127.0.0.1

::  Transit Assignment Metrorail
START Transit_Assignment_LineHaul_Parallel.bat %1 MR
@ping -n 11 127.0.0.1

::  Transit Assignment All Bus
START Transit_Assignment_LineHaul_Parallel.bat %1 AB
@ping -n 11 127.0.0.1

::  Transit Assignment Bus and Metrorail
START /wait Transit_Assignment_LineHaul_Parallel.bat %1 BM

:Transit_Assignmets_Are_Done

CD %1
goto checkIfDone

:waitForMC
@ping -n 11 127.0.0.1

:checkIfDone

@REM Check file existence to ensure that there are no errors
if exist Transit_Assignment_CR.err echo Error in Transit_Assignment_CR && goto error
if exist Transit_Assignment_MR.err echo Error in Transit_Assignment_MR && goto error
if exist Transit_Assignment_AB.err echo Error in Transit_Assignment_AB && goto error
if exist Transit_Assignment_BM.err echo Error in Transit_Assignment_BM && goto error

@REM Check to ensure that each of the batch processes have finished successfully, if not wait.
if not exist Transit_Assignment_CR.done goto waitForMC
if not exist Transit_Assignment_MR.done goto waitForMC
if not exist Transit_Assignment_AB.done goto waitForMC
if not exist Transit_Assignment_BM.done goto waitForMC

goto end
:error
REM  Processing Error.....
PAUSE
:end
cd..