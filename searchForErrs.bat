:: tms3  O:\model_dev\fy14\Ver2.3.56\searchForErrs.bat
:: 2014-04-23 Wed 19:24:09

:: Analyst: msm
:: This batch file will scan travel model reports and output files for errors 
::   and other anomalies.  It is designed to work with the Ver. 2.3 travel model.
:: This is to be run from the root dir, e.g., E:\modelRuns\fy12\Ver2.3.37_conf
:: It is called from the "run model" batch file, so it can make use of the environment
::  variables in that file
:: Usage:  searchForErrs.bat <name of scenario folder>
::  e.g.,  searchForErrs.bat 2007
::
:: Updates
:: DATE        PERSON  CHANGE
:: 2009-01-07  msm     Searches for different versions of TP+/Voyager
::                     User must supply expected version, e.g., 6.1.0


:: if searchForErrs.txt exists, copy it to new file with the same name and the date appended to it
if exist %root%\%scenar%\%scenar%_searchForErrs.txt call datename.bat %root%\%scenar%\%scenar%_searchForErrs.txt

:: Print header records in search output file (searchForErrs.txt)
echo ********** Searching for errors and anomalies after a travel model run **********  > %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo Program name: searchForErrs.bat >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1


:: Search *fulloutput.txt
echo ***** Searching *fulloutput.txt >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo   *** Searching for cases where a file could not be found >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
(findstr /i /p /c:"Could Not Find"  %1\*fulloutput.txt) >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
(findstr /i /p /c:"cannot find"  %1\*fulloutput.txt) >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1


:: Search report files
echo ***** Searching report files (*.rpt) >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo   *** Searching for evidence that TP+ (TPMAIN) is running, instead of Voyager (PILOT) >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
(findstr /i /p /c:"TPMAIN"  %1\*.rpt) >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo   *** Searching for evidence of LINKO nodes that do not have XY values >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
(findstr /i /p /c:"The following LINKO nodes do not have XY values"  %1\*.rpt) >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1

echo   *** Searching for different versions of Cube Voyager >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo       *** Expected version: 6.1.0  >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
 findstr /i /p /r    /c:"\[[0-9]\.[0-9]\.[0-9]\]"  %1\*.rpt > tppVoyVers.txt
(findstr /i /p /r /v /c:"\[[6]\.[1]\.[0]\]"                   tppVoyVers.txt)  >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1

echo   *** Searching for return codes greater than 1 >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
(findstr /i /p /r /c:"ReturnCode = [2-9]"  %1\*.rpt) >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1

echo   *** Searching for fatal errors >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
(findstr /i /p /r /c:"F([0-9]*):"  %1\*.rpt) >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1

echo   *** Searching for warnings >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
(findstr /i /p /r /c:"W([0-9]*):"  %1\*.rpt) >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1


:: Search output files
echo ***** If this file (AT_override.TXT) exists, >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo   ***  there may be area-type overrides      >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo   ***  (a 2nd value of zero => no override)  >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
(type  %1\inputs\AT_override.TXT)       >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
echo. >> %root%\%scenar%\%scenar%_searchForErrs.txt 2>&1
