@ECHO OFF

@REM ======================================
@REM 
@REM Author                 : Kenan BOLAT
@REM Initialization Date    : 2023.02.23  
@REM Update Date            : 2023.02.24  
@REM 
@REM ======================================


@REM config the batch parameters 
setlocal EnableDelayedExpansion

@REM define directory to look for the xml files  
set  "xml_folder=C:\Users\knn\Desktop\BATCH"

@REM get the current date and format date string similar to the xml date format   
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

@REM Example date strings to compare the different date strings 
echo ====================================================
echo CurrentDate: %comparingStamp%
call :string_to_date_number "2023-03-23T22:24:01Z" date_number 
echo ExampleDate: %date_number%
echo ====================================================


@REM get the contact table "start" and "end" time seperately for each pass   
@REM For the GGS the station identifier within the XPATH keywords must be 0 
@REM For the MGS the station identifier within the XPATH keywords must be 1 

@REM populate start and end datetime arrays for each xml file 
for %%f in ("%xml_folder%\*.xml") do (
    echo "CONTACT_TABLE : %%f" 
    set index=0
    for /f "tokens=* delims=" %%# in ('xpath.bat %%f "/CONTACT_TABLE/PASSES/STATION[0]//PASS/@START"') do (set START[!index!]=%%# & set /A index+=1)
    
    set index=0
    for /f "tokens=* delims=" %%# in ('xpath.bat %%f "/CONTACT_TABLE/PASSES/STATION[0]//PASS/@END"') do (set END[!index!]=%%# & set /A index+=1)
)



@REM Compare start and end array agains the current datetime 
call :string_to_date_number  %comparingStamp% compare1
echo ==================================================================================
for /l %%a in (0 , 1, %index%) do (
    echo %%a 
    echo !START[%%a]! 
    echo !END[%%a]! 
    call :string_to_date_number  !START[%%a]! compare2
    call :string_to_date_number  !END[%%a]! compare3
    echo !compare1!
    echo !compare2!
    echo !compare3!
    call :check_date !compare1! !compare2! !compare3!
    )
echo ==================================================================================

@REM for /f "tokens=* delims=" %%# in ('xpath.bat "GKT_20230221103925_CONTACT.xml" "/CONTACT_TABLE/PASSES/STATION[0]//PASS/@START"') do set "start_date=%%#"
@REM for /f "tokens=* delims=" %%# in ('xpath.bat "GKT_20230221103925_CONTACT.xml" "/CONTACT_TABLE/PASSES/STATION[0]//PASS/@END"') do set "end_date=%%#"

@REM echo %start_date%
@REM echo %end_date%


@REM if 2023-03-23T22:24:00Z GTR 2023-03-23T22:26:00Z  if 2023-03-23T22:26:00Z LSS 2023-03-23T22:29:39Z   goto ResultBetween

call :string_to_date_number "2023-03-24T22:08:00Z" compare1
call :string_to_date_number "2023-03-24T22:07:00Z" compare2 @REM Start Date 
call :string_to_date_number "2023-03-24T22:10:00Z" compare3 @REM End Date 
echo ====================================================
echo %compare1%
echo %compare2%
echo %compare3%
echo ====================================================

@REM if "%compare2%" LSS "%compare1%" (
@REM     if "%compare3%" GTR "%compare1%" (
@REM         echo "inside" 
@REM     ) else (
@REM         goto end
@REM     )
@REM ) else (goto end)

call :check_date %compare1% %compare2% %compare3%
:check_date
if "%~2" LSS "%~1" (
    if "%~3" GTR "%~1" (
        echo "inside"
        exit /b 0
    )
) 
exit /b 1


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


@REM :kill_ssm_task
@REM echo "INFO"
@REM @rem TASKKILL /F /IM SSM.EXE
@REM exit /b 

:trial 
echo "aaaaaaaaaaaaaaaaa"
exit /b 