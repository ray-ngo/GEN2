CD %1

REM  Transit Network Building (Final)
REM    -- for Selected Paths Only --
del tppl*.*
del transit_skims.rpt
start /w TPPLUS.EXE  ..\scripts\transit_skims_Select_Paths.s /start -Ptppl -S..\%1
if errorlevel 2 goto error
copy tppl*.prn  %_iter_%_TRANSIT_SKIMS_Select_Paths.RPT /y
goto end
:error
REM  Processing Error......
PAUSE
:end
CD..
