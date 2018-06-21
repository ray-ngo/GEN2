:: I:\ateam\team_mem\Moran\software\citilabs\updating_tpp_dll_files.bat
:: 2011-06-29 Wed 08:35:58
:: A potential fix for TPB Travel Model, Ver2.3.19 and later
:: This batch file is to be run only if certain error conditions are
::   encountered in model run
:: The user must set two environment variables:  progrLoc, rootDir

:: Location of Citilabs program files

:: For 32-bit OS, progrLoc=Program Files
set progrLoc=Program Files
:: For 64-bit OS, progrLoc=Program Files (x86)
::set progrLoc=Program Files (x86)
:: Root folder for model run
set rootDir=O:\model_dev\Ver2.3.27x

copy C:\%progrLoc%\Citilabs\Cube\tppdlibx.dll  %rootDir%\software /y
copy C:\%progrLoc%\Citilabs\Cube\TpUtLib.dll   %rootDir%\software /y



