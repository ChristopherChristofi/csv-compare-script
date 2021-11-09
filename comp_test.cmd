@echo off
Setlocal EnableDelayedExpansion
set "list1=list1"
set "list2=list2"
type nul > %list1%.csv
type nul > %list2%.csv
type nul > testnew.csv
call :reformat new.csv , testnew.csv
call :extract testnew.csv , %list1%.csv
call :extract complete.csv , %list2%.csv
sort /uniq %list1%.csv /o list11.csv
sort /uniq %list2%.csv /o list22.csv
for /f %%a in ('fc list11.csv list22.csv ^| find /i "cod"') do (
echo %%a >> error.csv
) || ( echo Error in File Read and Comparing Datasets &Exit /b 1 )

pause
exit

:reformat
for /f "skip=1 delims=" %%# in (%1) do (
    REM error handle - for comma delimiter sequences
    REM and empty values in tuple - with replacement
    set tpl=%%#
    set tpl=!tpl:,,=, ,!
    set tpl=!tpl:,,=, ,!
    for /f "tokens=2-7 delims=," %%b in (^"!tpl!^") do (
        REM exhibit parsed token selectivity
        echo %%b,%%d,%%e,%%f,%%g >> %2
    ) || (
        echo Error Reading File Found &Exit /b 1
    )
)
exit /b

:extract
for /f "skip=1 tokens=1 delims=," %%a in (%1) do (
    REM token selectivity for unique id column
    REM at position 1 - after reformat subroutine
    echo %%a >> %2
) || (
    echo Error Reading File Found &Exit /b 1
)
exit /b

goto :eof