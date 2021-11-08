@echo off
Setlocal EnableDelayedExpansion
set "_new2=nwmerge"
set "_work2=olmerge"
set "new_doc=new"
set "_merge=updated"
set "comp_doc=complete"
set "_uid1=idlist1"
set "_uid2=idlist2"
type nul > %_work2%.csv
REM read of fixed file containing changes to be merged
REM with new dataset file
for /f %%a in ('dir /b *.csv') do (
    REM prevent processing of output
    if %%a neq %_work2%.csv ( if %%a neq %new_doc%.csv (
        call :reformat %%a , %_work2%.csv
    ))
)
type nul > %_new2%.csv
call :reformat %new_doc%.csv , %_new2%.csv
type nul > %_merge%.csv
sort /uniq %_work2%.csv >nul
sort /uniq %_new2%.csv >nul
for /f "tokens=1-5 delims=," %%a in (%_work2%.csv) do (
    for /f "delims=," %%f in (%_new2%.csv) do (
        if %%a equ %%f ( echo %%a,%%b,%%c,%%d,%%e >> %_merge%.csv )
    )
) || (
    echo Error in File Read and Comparing Datasets &Exit /b 1
)
type nul > %_uid1%.csv
type nul > %_uid2%.csv
REM subroutine calls to extract uinque id list comparatives
call :extract %_new2%.csv %_uid1%.csv
call :extract %_merge%.csv %_uid2%.csv
REM comparison method to filter differences
for /f %%a in ('fc %_uid1%.csv %_uid2%.csv ^| find /i "cod"') do (
    for /f "tokens=1-5 delims=," %%b in (%_new2%.csv) do (
        if %%a equ %%b (
            echo %%b,%%c,%%d,%%e,%%f >> %_merge%.csv
        )
    )
) || (
    echo Error in File Read and Comparing Datasets &Exit /b 1
)

type nul > %comp_doc%.csv
echo uid,datetime,text,num, > %comp_doc%.csv
type %_merge%.csv >> %comp_doc%.csv
del %_new2%.csv %_work2%.csv %_merge%.csv %_uid1%.csv %_uid2%.csv
endlocal
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
for /f "tokens=1 delims=," %%a in (%1) do (
    REM token selectivity for unique id column
    REM at position 1 - after reformat subroutine
    echo %%a >> %2
) || (
    echo Error Reading File Found &Exit /b 1
)
exit /b

goto :eof