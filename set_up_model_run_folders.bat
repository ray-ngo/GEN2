@echo off
:: set_up_model_run_folders.bat
:: 2012-12-20 msm Batch file created
:: Copy a travel model and its constituent folders to a new location so thay
:: you may set up a new model run.
set source_folder=X:\modelRuns\fy13\Ver2.3.48
set destin_folder=C:\Users\mmoran\Documents\modelRuns\fy13\Ver2.3.48
set files_to_copy=*.*

:: options
:: /create :: Create directory tree structure + zero-length files only
:: /L      :: List only (don't copy)
:: /E      :: Copy subfolders, including empyt folders
:: /Z      :: Copy files in restartable mode
:: /XF *   :: Exclude files matching given names/paths/wildcards

:: Just folder structure
robocopy %source_folder% %destin_folder% %files_to_copy% /create /E /Z /XF *

:: Copy the files, but exclude the output directories
robocopy %source_folder% %destin_folder% %files_to_copy% /E /Z /XD 20*

:: Copy files from the inputs subdirectories (not yet working correctly)
::robocopy %source_folder% %destin_folder% %files_to_copy%
