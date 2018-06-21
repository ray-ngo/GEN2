::setErrorLev.bat

:: Set the error level to 5
 @echo off
 call :setError 5
 echo Current error level (return code) is %errorlevel%
 goto :eof
 
:setError
 exit /B %1

