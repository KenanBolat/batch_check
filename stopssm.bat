@ECHO OFF

@REM ======================================
@REM 
@REM Author                 : Kenan BOLAT
@REM Initialization Date    : 2023.02.23  
@REM Update Date            : 2023.02.28  
@REM 
@REM ======================================


@REM call :date_boundary "2022-12-31T00:01:50" add updated
@REM call :date_boundary "2022-03-01T00:01:50" sub updated
@REM call :date_boundary "2020-03-01T00:01:50" sub updated
@REM call :date_boundary "2020-03-01T00:01:50" sub updated
call :date_boundary "2022-12-31T23:59:50" sub updated
echo %updated%





@REM config the batch parameters 
setlocal EnableDelayedExpansion
TASKKILL /F /IM SSM.EXE
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

    set index=0
    for /f "tokens=* delims=" %%# in ('xpath.bat %%f "/CONTACT_TABLE/PASSES/STATION[0]//PASS/@ORBIT_ID"') do (set ORBIT_ID[!index!]=%%# & set /A index+=1)
)

for /f "tokens=* delims=" %%a in ('date_boundary.bat "2020-03-01T00:00:03" "add"') do set "left=%%a"
for /f "tokens=* delims=" %%a in ('date_boundary.bat "2020-03-01T00:00:03" "sub"') do set "right=%%a"
echo %left%
echo %right%
pause 

@REM @REM Compare start and end array agains the current datetime 
call :string_to_date_number  %comparingStamp% current_date
echo ==================================================================================
set /a limit=%index%-1 

for /l %%a in (0 , 1, %limit%) do (

    echo !START[%%a]! 
    echo !END[%%a]!
    echo !ORBIT_ID[%%a]!
    

    for /f "tokens=* delims=" %%# in ('date_boundary.bat !START[%%a]! "sub"') do set left=%%#
    for /f "tokens=* delims=" %%# in ('date_boundary.bat !END[%%a]! "add"') do set right=%%#

    call :string_to_date_number  !left! left_num
    call :string_to_date_number  !right! right_num

    echo !current_date!
    echo !left_num!
    echo !right_num!
    call :check_date !current_date! !left_num! !right_num!
     
    )
echo ==================================================================================
pause
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
        goto ResultBetween
        exit /b 0
    )
) 
exit /b 1


@REM call :string_to_date_number "2023-03-23T22:24:00Z" compare1
@REM call :string_to_date_number "2023-03-24T22:24:00Z" compare2

@REM if "%compare1%" LSS "%compare2%"   goto ResultBetween
:EOF 

:ResultBetween
echo "Between"
goto :EOF



@REM Usage: call :string_to_date_number "2023-03-23T22:24:00Z" date_number
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





:calculate_last_day
setlocal EnableDelayedExpansion
set "month=%~1"
set "year=%~2"
set "last_day="
if !month! equ 4 set "last_day=30"
if !month! equ 6 set "last_day=30"
if !month! equ 9 set "last_day=30"
if !month! equ 11 set "last_day=30"
if !month! equ 2 (
    set /a "leap=year%%4"
    set /a "leap1=year%%100"
    set /a "leap2=year%%400"
    if !leap! equ 0 (
        if !leap1! neq 0 (
            set "last_day=29"
        ) else (
            if !leap2! equ 0 (
                set "last_day=29"
            ) else (
                set "last_day=28"
            )
        )
    ) else (
        set "last_day=28"
    )
)
if not defined last_day (
    set "last_day=31"
)
endlocal & set "last_day=%last_day%"
goto :EOF



:date_boundary 
setlocal enabledelayedexpansion

@REM datestring must be either in the format of yyyy-MM-ddThh:mm:ss
set "date_string=%~1"

@REM operation must be either sub and add
set "operation=%~2"

@REM Get the current date and time
for /f "tokens=1-6 delims=-T:" %%a in ("%date_string%") do (
    set /a "year=1000%%a %% 100"
    set /a "month=1000%%b %% 100"
    set /a "day=1000%%c %% 100"
    set /a "hours=1000%%d %% 100"
    set /a "minutes=1000%%e %% 100"
    set /a "seconds=1000%%f %% 100"
)

@REM Add 5 minutes to the current time
if !operation!==add (
  set /a "minutes+=5"
  if !minutes! geq 60 (
    set /a "hours+=1"
    set /a "minutes-=60"
  )
  if !hours! geq 24 (
    set /a "day+=1"
    set /a "hours-=24"
  )
) else if !operation!==sub (

  set /a "minutes-=5"
  if !minutes! lss 0 (
    set /a "hours-=1"
    set /a "minutes+=60"
  )
  if !hours! lss 0 (
    set /a "day-=1"
    set /a "hours+=24"
  )
)


@REM Check for end-of-month boundary conditions
call :calculate_last_day !month! !year! last_day
if !day! gtr !last_day! (
  set /a "day=1"
  set /a "month+=1"
  if !month! gtr 12 (
    set /a "month=1"
    set /a "year+=1"
  )
) else if !day! lss 1 (

  set /a "month-=1"
  if !month! lss 1 (
    set /a "month=12"
    set /a "year-=1"
  )

call :calculate_last_day !month! !year! last_day
)
if !day! lss 1 (
  set /a "day=!last_day!"
)

@REM Display the updated date and time
if !day! lss 10 set "day=0!day!"
if !month! lss 10 set "month=0!month!"
if !year! lss 10 set "year=!year!"
set /a year=!year!+2000
if !hours! lss 10 set "hours=0!hours!"
if !minutes! lss 10 set "minutes=0!minutes!"
if !seconds! lss 10 set "seconds=0!seconds!"
@REM endlocal & set "updated_date=%year%-%month%-%day%T%hours%:%minutes%:%seconds%"
endlocal & set updated_date=!year!-!month!-!day!T!hours!:!minutes!:!seconds!
goto :EOF


@REM :kill_ssm_task
@REM echo "INFO"
@REM @rem TASKKILL /F /IM SSM.EXE
@REM exit /b 
