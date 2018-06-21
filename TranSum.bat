:: TranSum.bat
:: To be run from the root directory (e.g., E:\modelRuns\fy13\Ver2.3.46)


REM Change to the Transum folder, under the scenario-specific folder
REM Output report files will be stored in the Transum folder
REM The Transum folder starts out empty, since station_names.dbf is stored in Controls
CD %1\Transum

REM Copy the lineSum control files from the Controls folder to the Transum folder
copy ..\..\Controls\LineSum_*.ctl

REM Consolidate peak and off-peak volumes from transit assignment
..\..\software\LineSum.exe  LineSum_Volume.ctl
if %ERRORLEVEL% == 1 goto error

REM Metrorail station access (does not include transfers)
..\..\software\LineSum.exe  lineSum_MR_access.ctl
if %ERRORLEVEL% == 1 goto error

REM Metrorail line summaries
..\..\software\LineSum.exe  lineSum_MR_line.ctl
if %ERRORLEVEL% == 1 goto error




goto end
:error
REM  Processing Error......
PAUSE
:end
::CD..
CD..
CD..
