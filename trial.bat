@echo off 
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "currentDatestamp=%YYYY%%MM%%DD%" 
set "currentTimestamp=%HH%%Min%%Sec%"
set "currentFullstamp=%YYYY%-%MM%-%DD%-%HH%-%Min%-%Sec%"
set "comparingStamp=%YYYY%-%MM%-%DD%-%HH%:%Min%:%Sec%"



echo %comparingStamp%
for /f "tokens=1-4,5-6 delims=-:Z" %%a in ("%comparingStamp%Z") do (
  echo %%a
  echo %%b
  echo %%c
  echo %%d
  echo %%e
  echo %%f

  set /a "second=%%f"
  set /a "minute=%%e+5"
  set /a "hour=%%d+(%minute%/60)"
  set /a "day=%%c+(%hour%/24)"
  set /a "month=%%b+(%day%/12)"
  set /a "year=%%a + %month%"
  set "modified_timestamp=%year%-%month%-%day%-%hour%:%minute%:%second%"
)

echo %modified_timestamp%