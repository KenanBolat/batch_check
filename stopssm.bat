@ECHO OFF

@REM @REM TASKKILL /F /IM SSM.EXE

setlocal EnableDelayedExpansion


for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "currentDatestamp=%YYYY%%MM%%DD%" 
set "currentTimestamp=%HH%%Min%%Sec%"
set "currentFullstamp=%YYYY%-%MM%-%DD%-%HH%-%Min%-%Sec%"
set "comparingStamp=%YYYY%-%MM%-%DD%-%HH%:%Min%:%Sec%"

echo currentDatestamp: "%currentDatestamp%"
echo currentTimestamp: "%currentTimestamp%"
echo currentFullstamp: "%currentFullstamp%"
echo comparingStamp: "%comparingStamp%"


set da=GGS-L-%currentFullstamp% 

echo ====================================================
echo %comparingStamp%
call :string_to_date_number "2023-03-23T22:24:01Z" date_number & echo %date_number%
echo ====================================================


@REM Get the contact table "start" and "end" time seperately for each pass   
@REM For the GGS the station identifier within the XPATH keywords must be 0 
@REM For the MGS the station identifier within the XPATH keywords must be 1 

for /f "tokens=* delims=" %%# in ('xpath.bat "GKT_20230221103925_CONTACT.xml" "/CONTACT_TABLE/PASSES/STATION[0]//PASS/@START"') do set "start_date=%%#"
for /f "tokens=* delims=" %%# in ('xpath.bat "GKT_20230221103925_CONTACT.xml" "/CONTACT_TABLE/PASSES/STATION[0]//PASS/@END"') do set "end_date=%%#"

echo %start_date%
echo %end_date%


@REM if 2023-03-23T22:24:00Z GTR 2023-03-23T22:26:00Z  if 2023-03-23T22:26:00Z LSS 2023-03-23T22:29:39Z   goto ResultBetween

call :string_to_date_number  %comparingStamp% compare1
call :string_to_date_number %start_date% compare2
call :string_to_date_number %end_date% compare3
echo ====================================================
echo %compare1%
echo %compare2%
echo %compare3%
echo ====================================================
@REM call :string_to_date_number "2023-03-24T22:08:01Z" compare1
@REM call :string_to_date_number "2023-03-24T22:07:00Z" compare2
@REM call :string_to_date_number "2023-03-24T22:10:01Z" compare3

if "%compare2%" LSS "%compare1%" (
    if "%compare3%" GTR "%compare1%" (
        echo "inside" 
    ) else (
        goto end
    )
) else (goto end)


:end 
echo "Not worked"

@REM call :string_to_date_number "2023-03-23T22:24:00Z" compare1
@REM call :string_to_date_number "2023-03-24T22:24:00Z" compare2

@REM if "%compare1%" LSS "%compare2%"   goto ResultBetween


@REM :ResultBetween
@REM echo "Between"



:: Usage: call :string_to_date_number "2023-03-23T22:24:00Z" date_number
:string_to_date_number
setlocal
set "datestr=%~1"
set "yyyy=%datestr:~0,4%"
set "mm=%datestr:~5,2%"
set "dd=%datestr:~8,2%"
set "hh=%datestr:~11,2%"
set "nn=%datestr:~14,2%"
set "ss=%datestr:~17,2%"
set "ms=%datestr:~20,3%"
set "datetime=%yyyy%%mm%%dd%%hh%%nn%%ss%.%ms%"
endlocal & set "%~2=%datetime%"
exit /b