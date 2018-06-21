CD %1


if exist Transit_Skims_%2.err   del Transit_Skims_%2.err
if exist Transit_Skims_%2.done  del Transit_Skims_%2.done
@echo Transit_Skims_%2

if exist voya*.*  del voya*.*
if exist %_iter_%_TRANSIT_SKIMS_%2.RPT  del %_iter_%_TRANSIT_SKIMS_%2.RPT
start /w Voyager.exe ..\scripts\Transit_Skims_%2.s /start /high -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn  %_iter_%_TRANSIT_SKIMS_%2.RPT /y
goto end
:error
echo Error in Transit Skim %2 > Transit_Skims_%2.err
REM  Processing Error......
REM PAUSE
:end
echo Finished Transit Skim %2 > Transit_Skims_%2.done
Exit


