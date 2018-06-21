::CD %1
if exist %2.err del %2.err
if exist %2.done del %2.done
@echo %2
@date /t & time /t
if exist %2_NL_MC.* del %2_NL_MC.*
..\timethis ..\software\AEMS   ..\controls\%2_NL_MC.ctl | ..\tee %2.txt
@echo %2 Finished
@date /t & time /t

goto end

:error
REM  Processing Error....
	@echo ERROR: %2 Mode Choice failed >> %2.txt
	@echo %2 Error > %2.err	
	@echo Error > %2.done
	@pause
	exit
:end
	echo %2 Mode Choice Done >> %2.txt
	@echo Done > %2.done
	exit