@ECHO off

@REM call :check_date "2022-12-31T00:01:50" add updated
@REM call :check_date "2022-03-01T00:01:50" sub updated
@REM call :check_date "2020-03-01T00:01:50" sub updated
@REM call :check_date "2020-03-01T00:01:50" sub updated
call :check_date "2022-12-31T23:59:50" sub updated
echo !updated!


:EOF
:check_date 
setlocal enabledelayedexpansion
@REM datestring must be either in the format of "yyyy-MM-ddThh:mm:ss"
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

echo !year!
echo !operation!



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
endlocal & set "updated_date=%year%-%month%-%day%T%hours%:%minutes%:%seconds%"
echo %updated_date%
goto :EOF


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