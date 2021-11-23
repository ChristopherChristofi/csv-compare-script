@echo off
Setlocal EnableDelayedExpansion
REM script for handling and comparing both the newest dataset
REM and the edited dataset that is in the resulting format of
REM the first compare script; that handles datasets only in
REM their original formats.
set "_new2=nwmerge"
set "_work2=olmerge"
set "new_doc=new"
set "_merge=updated"
set "comp_doc=complete"
set "comp_doc2=complete2"
set "_uid1=idlist1"
set "_uid2=idlist2"
REM read of fixed file containing changes to be merged
REM with new dataset file
if exist %comp_doc%.csv (
    type nul > %_work2%.csv && attrib +h %_work2%.csv
    call :reformat_fixed %comp_doc%.csv , %_work2%.csv , 1 , 5
) else (( echo File Error: %comp_doc%.csv not found. ) && pause &exit /b 1 )
if exist %new_doc%.csv (
    type nul > %_merge%.csv && attrib +h %_merge%.csv
    type nul > %_new2%.csv && attrib +h %_new2%.csv
    call :reformat_fixed %new_doc%.csv , %_new2%.csv , 2 , 7
    for /f "tokens=1-5 delims=," %%a in (%_new2%.csv) do (
        for /f "tokens=1-5 delims=," %%f in (%_work2%.csv) do (
            if %%a equ %%f ( echo %%a,%%c,%%d,%%e,%%j >> %_merge%.csv ))
    )
) else (
    ( echo File Error: %new_doc%.csv not found. )
    del /A:H %_work2%.csv
    pause &exit /b 1
)
REM subroutine calls to extract uinque id list comparatives
if exist %_new2%.csv ( if exist %_merge%.csv (
    type nul > %_uid1%.csv && attrib +h %_uid1%.csv
    type nul > %_uid2%.csv && attrib +h %_uid2%.csv
    call :extract %_new2%.csv %_uid1%.csv
    call :extract %_merge%.csv %_uid2%.csv
    REM comparison method to filter differences between collated merge
    REM file from old edited file and the new dataset file
    for /f %%a in ('type %_uid1%.csv ^| find /i "cod" /c') do set ln_cnt=%%a
    for /f %%a in ('fc /lb %ln_cnt% %_uid1%.csv %_uid2%.csv ^| find /i "cod"') do (
        for /f "tokens=1-5 delims=," %%b in (%_new2%.csv) do (
            if %%a equ %%b ( echo %%b,%%c,%%d,%%e,%%f >> %_merge%.csv ))
    )
)) else (
    ( echo Processing Error: temporary file structures not found )
    if exist %_new2%.csv ( del /A:H %_new2%.csv )
    if exist %_merge%.csv ( del /A:H %_merge%.csv )
    del /A:H %_work2%.csv
    pause &exit /b 1
)
type nul > %comp_doc2%.csv
echo uid,datetime,text,num, > %comp_doc2%.csv
type %_merge%.csv >> %comp_doc2%.csv
del /A:H %_merge%.csv %_new2%.csv %_work2%.csv %_uid1%.csv %_uid2%.csv
endlocal
pause
exit

:reformat_fixed
for /f "skip=1 delims=" %%# in (%1) do (
    REM error handle - for comma delimiter sequences
    REM and empty values in tuple - with replacement
    set tpl=%%#
    set tpl=!tpl:,,=, ,!
    set tpl=!tpl:,,=, ,!
    for /f "tokens=%3-%4 delims=," %%a in (^"!tpl!^") do (
        REM exhibit parsed token selectivity
        echo %%a,%%b,%%c,%%d,%%e >> %2
    )
)
exit /b

:extract
for /f "tokens=1 delims=," %%a in (%1) do (
    REM token selectivity for unique id column
    REM at position 1 - after reformat subroutine
    echo %%a >> %2
)
exit /b

goto :eof