@echo off
setlocal enabledelayedexpansion

rem Get the current date and time
for /f "tokens=1-3 delims=/ " %%a in ("01/03/2020") do (
@REM for /f "tokens=1-3 delims=/ " %%a in ("31/12/22") do (
  set /a "day=1000%%a %% 100"
  set /a "month=1000%%b %% 100"
  set /a "year=1000%%c %% 100"
)

for /f "tokens=1-3 delims=: " %%a in ("00:01:50") do (
@REM for /f "tokens=1-3 delims=: " %%a in ("23:59:50") do (
  set /a "hours=%%a"
  set /a "minutes=%%b"
  set /a "seconds=%%c"
)
set "month=2"
set "year=2024"
call :calculate_last_day "%month%" "%year%" last_day
echo The last day of the month is: %last_day%



set operation="sub"
rem Add 5 minutes to the current time
if %operation%=="add" (
  set /a "minutes+=5"
  if !minutes! geq 60 (
    set /a "hours+=1"
    set /a "minutes-=60"
  )
  if !hours! geq 24 (
    set /a "day+=1"
    set /a "hours-=24"
  )
) else if %operation%=="sub" (
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


rem Check for end-of-month boundary conditions
set "last_day=31"
if !month! equ 4 set "last_day=30"
if !month! equ 6 set "last_day=30"
if !month! equ 9 set "last_day=30"
if !month! equ 11 set "last_day=30"
if !month! equ 2 (
  set /a "leap=year%%4"
  if !leap! equ 0 (
    set /a "leap=year%%100"
    if !leap! neq 0 (
      set "last_day=29"
    ) else (
      set /a "leap=year%%400"
      if !leap! equ 0 set "last_day=29"
    )
  )
  if !leap! neq 0 set "last_day=28"
)
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

  set "last_day=31"
  echo %month%
    if !month! equ 4 set "last_day=30"
    if !month! equ 6 set "last_day=30"
    if !month! equ 9 set "last_day=30"
    if !month! equ 11 set "last_day=30"
    if !month! equ 2 (
        set /a "leap=year%%4"
        if !leap! equ 0 (
            set /a "leap=year%%100"
            if !leap! neq 0 (
                set "last_day=29"
            ) else (
                set /a "leap=year%%400"
                if !leap! equ 0 set "last_day=29"
    )
  )
  if !leap! neq 0 set "last_day=28"
  
)
)
echo !leap!
set /a x=year%%4
echo !x!
echo ================================
echo !last_day!
if !day! lss 1 (
    set /a "day=!last_day!"
  )



rem Display the updated date and time
if !day! lss 10 set "day=0!day!"
if !month! lss 10 set "month=0!month!"
if !year! lss 10 set "year=0!year!"
if !hours! lss 10 set "hours=0!hours!"
if !minutes! lss 10 set "minutes=0!minutes!"
if !seconds! lss 10 set "seconds=0!seconds!"
echo %day%/%month%/%year% %hours%:%minutes%:%seconds%


:EOF 
:calculate_last_day
setlocal EnableDelayedExpansion
set "month=%~1"
set "year=%~2"
set "last_day="
if %month% equ 4 set "last_day=30"
if %month% equ 6 set "last_day=30"
if %month% equ 9 set "last_day=30"
if %month% equ 11 set "last_day=30"
if %month% equ 2 (
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
goto :eof