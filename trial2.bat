@echo off
setlocal enabledelayedexpansion

rem Get the current date and time
for /f "tokens=1-3 delims=- " %%a in ("01-01-01") do (
  set /a "day=%%a"
  set /a "month=%%b"
  set /a "year=%%c"
)
for /f "tokens=1-3 delims=: " %%a in ("00:01:00") do (
  set /a "hours=%%a"
  set /a "minutes=%%b"
  set /a "seconds=%%c"
)

rem Add 5 minutes to the current time
set /a "minutes=%minutes%-5"
if !minutes! geq 60 (
  set /a "hours+=1"
  set /a "minutes-=60"
)
if !hours! geq 24 (
  set /a "day+=1"
  set /a "hours-=24"
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
)

rem Display the updated date and time
if !day! lss 10 set "day=0!day!"
if !month! lss 10 set "month=0!month!"
if !year! lss 10 set "year=0!year!"
if !hours! lss 10 set "hours=0!hours!"
if !minutes! lss 10 set "minutes=0!minutes!"
if !seconds! lss 10 set "seconds=0!seconds!"
echo %day%/%month%/%year% %hours%:%minutes%:%seconds%