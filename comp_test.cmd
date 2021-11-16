@echo off
Setlocal EnableDelayedExpansion
set "new_doc=new"
set "comp_doc=complete2"
set "list1=test_list1"
set "list2=test_list2"
if exist %new_doc%.csv (
    type nul > test_new.csv && attrib +h test_new.csv
    call :reformat %new_doc%.csv , test_new.csv
) else (( echo File Error: %new_doc%.csv not found. ) && del test_new.csv && pause &exit /b 1 )
if exist %comp_doc%.csv ( if exist test_new.csv (
    type nul > %list1%.csv && attrib +h %list1%.csv
    type nul > %list2%.csv && attrib +h %list2%.csv
    call :extract test_new.csv , %list1%.csv , "tokens=1 delims=,"
    call :extract %comp_doc%.csv , %list2%.csv , "skip=1 tokens=1 delims=,"
    sort /uniq %list1%.csv /o test_list11.csv && attrib +h test_list11.csv
    sort /uniq %list2%.csv /o test_list22.csv && attrib +h test_list22.csv
)) else (( echo File Error: %comp_doc%.csv not found. ) && del /A:H test_new.csv && pause &exit /b 1 )

echo Missing codes found: > test_error.csv
for /f %%a in ('fc test_list11.csv test_list22.csv ^| find /i "cod"') do ( echo %%a >> test_error.csv )

del /A:H %list1%.csv %list2%.csv test_list11.csv test_list22.csv test_new.csv
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
    )
)
exit /b

:extract
for /f %3 %%a in (%1) do (
    REM token selectivity for unique id column
    REM at position 1 - after reformat subroutine
    echo %%a >> %2
)
exit /b

goto :eof