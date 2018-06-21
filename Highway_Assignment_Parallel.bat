CD %1


REM  Highway Assignment

if exist voya*.*  del voya*.*
if exist %_iter_%_Highway_Assignment.rpt   del %_iter_%_Highway_Assignment.rpt

Cluster.exe AM %AMsubnode% start exit
Cluster.exe MD %MDsubnode% start exit
start /w Voyager.exe ..\scripts\Highway_Assignment_Parallel.s  /start -Pvoya -S..\%1
if errorlevel 2 goto error ; Moved from below Cluster + Changed to 2 (due to crash on Cube 6.4.1)
Cluster.exe AM %AMsubnode% close exit
Cluster.exe MD %MDsubnode% close exit



copy Voya*.prn       %_iter_%_Highway_Assignment.rpt /y

goto end
:error
REM  Processing Error....
PAUSE
:end
CD..
