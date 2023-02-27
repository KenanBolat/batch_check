@echo off

setlocal

rem Get the current date and time
for /f "tokens=1-6 delims=:-" %%a in ("31-12-2022:23:59:01") do (
  set "day=%%a"
  set "month=%%b"
  set "year=%%c"
  set "hours=%%d"
  set "minutes=%%e"
  set "seconds=%%f"
)

echo %day%
echo %month%
echo %year%
echo %hours%
echo %minutes%
echo %seconds%
@REM exit /b

rem Set the number of minutes to add or subtract
set /a "delta_minutes=5"
if "%~1"=="sub" set /a "delta_minutes=-5"

rem Convert the time to total minutes
set /a "total_minutes=hours*60+minutes"

rem Add or subtract the delta minutes
set /a "total_minutes+=delta_minutes"

rem Calculate the new time
set /a "hours=total_minutes/60"
set /a "minutes=total_minutes%%60"

rem Handle boundary conditions
if !minutes! lss 0 (
  set /a "hours-=1"
  set /a "minutes+=60"
)
if !hours! lss 0 (
  set /a "hours+=24"
  if !day! equ 1 (
    set /a "month-=1"
    if !month! lss 1 (
      set /a "month=12"
      set /a "year-=1"
    )
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
    set /a "day=!last_day!"
  ) else (
    set /a "day-=1"
  )
)
if !hours! gtr 23 (
  set /a "hours-=24"
  if !day! gtr 27 (
    set /a "day=1"
    set /a "month+=1"
    if !month! gtr 12 (
      set /a "month=1"
      set /a "year+=1"
    )
  ) else (
    set /a "day+=1"
  )
)

echo %day%
rem Output the new date and time
set "datestring=%day%.%month%.%year% %hours%:%minutes%:00"
echo %datestring%

pause >nul