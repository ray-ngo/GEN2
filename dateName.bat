:: c:\docs\model_dev\ver2.3_20080830voy\dateName.bat
:: 2008-09-23 Tue 09:22:13
:: Appends a date and time stamp to the end of a file name, e.g.,
:: copy "test.txt" test_20080910_1557.txt /y
:: Date/time format is <four-digit year><two-digit month><two-digit day>_<time>
@ECHO on
FOR %%V IN (%1) DO FOR /F "tokens=1-5 delims=/: " %%J IN ("%%~tV") DO copy "%%V" %%~nV_%%L%%J%%K_%%M%%N%%~xV
