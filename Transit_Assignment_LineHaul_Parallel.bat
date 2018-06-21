CD %1

if exist Transit_Assignment_%2.err   del Transit_Assignment_%2.err
if exist Transit_Assignment_%2.done  del Transit_Assignment_%2.done
@echo Transit_Assignment_%2
if exist voya*.* del voya*.*
if exist %_iter_%_Transit_Assgn_%2.RPT del %_iter_%_Transit_Assgn_%2.RPT

REM Cluster.exe MWCOG %subnode% start exit
start /w voyager.exe ..\Scripts\transit_assignment_%2.s /start -Pvoya -S..\%1
REM Cluster.exe MWCOG %subnode% close exit

if errorlevel 2 goto error
if exist voya*.prn copy voya*.prn %_iter_%_Transit_Assgn_%2.RPT /y
goto end
:error
echo Error in Transit Assignment %2 > Transit_Assignment_%2.err
PAUSE
:end
echo Finished Transit Assignment %2 > Transit_Assignment_%2.done
Exit