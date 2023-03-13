@ECHO OFF
@REM START  
@REM ======================================
@REM 
@REM Author                 : Kenan BOLAT
@REM Initialization Date    : 2023.02.23  
@REM Update Date            : 2023.03.09  
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

set logfile=%currentDatestamp%_ssm_check.log
set process_folder=%currentDatestamp% 

call :log "INFO" ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
call :log "INFO" "Script Has been initiated"

@REM Example date strings to compare the different date strings 
call :log "INFO" "Currentdate : %comparingStamp%"

@REM get the contact table "start" and "end" time seperately for each pass or the orbit 
@REM For the GGS the station identifier within the XPATH keywords must be 0 
@REM For the MGS the station identifier within the XPATH keywords must be 1 

@REM error handling tags
set toi_flag="false"
set empty_folder="true"
set xpath_start_flag="true"
set xpath_end_flag="true"
set xpath_pass_flag="true"

@REM populate start and end datetime arrays for each xml file 
call :log "INFO" "Contact table is being searched"
for %%f in ("%xml_folder%\*.xml") do (
  call :log "INFO" "CONTACT_TABLE : %%f"

  set index=0
  for /f "tokens=* delims=" %%# in ('xpath.bat %%f "/CONTACT_TABLE/PASSES/STATION[0]//PASS/@START"') do (set START[!index!]=%%# & set /A index+=1 & set xpath_start_flag="false")

  set index=0
  for /f "tokens=* delims=" %%# in ('xpath.bat %%f "/CONTACT_TABLE/PASSES/STATION[0]//PASS/@END"') do (set END[!index!]=%%# & set /A index+=1 & set xpath_end_flag="false" )

  set index=0
  for /f "tokens=* delims=" %%# in ('xpath.bat %%f "/CONTACT_TABLE/PASSES/STATION[0]//PASS/@ORBIT_ID"') do (set ORBIT_ID[!index!]=%%# & set /A index+=1 & set xpath_pass_flag="false" )
  set empty_folder="false"
)

@REM Error Handling
if %empty_folder% equ "true" (
  call :log "ERROR" "No xml has been found. Please provide a contact table in the form of xml"
  goto :exit  
)

if %xpath_start_flag% equ "true" (
  call :log "ERROR" "There is an error in the filtering mechanism.Check XPATH tags [START]."
  goto :exit 
)

if %xpath_end_flag% equ "true" (
  call :log "ERROR" "There is an error in the filtering mechanism.Check XPATH tags [END]."
  goto :exit 
)

if %xpath_pass_flag% equ "true" (
  call :log "ERROR" "There is an error in the filtering mechanism.Check XPATH tags [PASS]."
  goto :exit 
)

@REM @REM Compare start and end array agains the current datetime 
call :string_to_date_number  %comparingStamp% current_date
set /a limit=%index%-1 
for /l %%a in (0 , 1, %limit%) do (
    set "formattedValue=000000%%a"
    for /f "tokens=* delims=" %%# in ('date_boundary.bat !START[%%a]! "sub"') do set left=%%#
    for /f "tokens=* delims=" %%# in ('date_boundary.bat !END[%%a]! "add"') do set right=%%#

    call :string_to_date_number  !left! left_num
    call :string_to_date_number  !right! right_num

    call :check_date !current_date! !left_num! !right_num! toi_flag 
    call :log "INFO" "[!formattedValue:~-3!] : !START[%%a]! : !END[%%a]! : !ORBIT_ID[%%a]! : !toi_flag!"
    
    if !toi_flag! equ "true" (  
      set orbit_id_flag=!ORBIT_ID[%%a]!
      set "toi_folder=!START[%%a]:~0,10!__!orbit_id_flag!"
      goto :end_loop
    )
)

:end_loop

if %toi_flag% equ "true" (
  call :log "INFO" "Examined time of interest lies within the time of contact table"
  
  call :check_ssm ssm_flag
  if !ssm_flag! equ "true" (
    call :log "INFO" "Currently an ssm instance is working on storing the necessary information. No new instance is going to be initiated."
  ) else ( 
    start /B "" "C:\Program Files (x86)\KE5FX\GPIB\ssm.exe" 
    call :log "WARNING"  "Currently there is no ssm instance is working. A new instance is going to be initiated."
  )
  
) else (

  call :log "INFO" "For the time slots examined within the contact table there is no intersection or they are out of bounds."
  call :log "WARNING" "Therefore any running instance of ssm will be terminated."
  @REM TASKKILL /F /IM SSM.EXE 2>&1 
  for /f "tokens=* delims=" %%z in ('TASKKILL /f /im ssm.exe 2^>^&1') do (
    set "message=%%~z"
    )
  call :log "INFO" !message!
)

goto :exit 

@REM END 
@REM Subroutines 
:check_date 
if "%~2" LSS "%~1" (
    if "%~3" GTR "%~1" (
        set toi_flag="true"
        exit /b 0
    )
) 
exit /b 1

:check_ssm
tasklist /fi "imagename eq ssm.exe" 2>NUL | find /i "ssm.exe" >NUL
if %errorlevel% equ 0 (
    set ssm_flag="true"
    
) else (
    set ssm_flag="false"
)
exit /b 

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

:log
setlocal enabledelayedexpansion
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
echo %2
echo [%YYYY%%MM%%DD% %HH%:%Min%:%Sec%][%1] %2 >> %logfile%
exit /b


:exit
call :log "INFO" "Script has been finalized."
call :log "INFO" ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
goto :EOF

:EOF 