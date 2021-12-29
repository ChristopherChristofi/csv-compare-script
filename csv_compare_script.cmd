@echo off
Setlocal EnableDelayedExpansion
for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set DateTime=%%a
set tstamp=%DateTime:~0,4%%DateTime:~4,2%%DateTime:~6,2%%DateTime:~8,2%%DateTime:~10,2%%DateTime:~12,2%
set "edit_doc=edit_data"
set "_proc_edit=_edit_process"
set "_proc_new=_new_process"
set "_merge_uid=_merge_uid"
set "new_doc=new"
set "_new_uid=_new_uid"
set "_merge=updated"
set "comp_doc=complete%tstamp%"
REM procedures for reformatting original data to prevent parsing errors.
if exist %new_doc%.csv ( if exist %edit_doc%.csv (
    type nul > %_proc_edit%.csv && attrib +h %_proc_edit%.csv
    type nul > %_proc_new%.csv && attrib +h %_proc_new%.csv
    call :reformat %edit_doc%.csv , %_proc_edit%.csv
    call :reformat %new_doc%.csv , %_proc_new%.csv
)) else (( echo File Error: either %edit_doc%.csv or %new_doc%.csv was not found. ) && pause &exit /b 1 )
REM procedures for pairing persistent data tuples with the newest dataset,
REM and merging matches into a newly generated dataset.
if exist %_proc_edit%.csv ( if exist %_proc_new%.csv (
    type nul > %_merge%.csv && attrib +h %_merge%.csv
    for /f "tokens=1-7 delims=," %%a in (%_proc_new%.csv) do (
        for /f "tokens=1-7 delims=," %%h in (%_proc_edit%.csv) do (
            if %%b equ %%i ( echo %%a,%%b,%%c,%%d,%%e,%%f,%%n >> %_merge%.csv )))
)) else (
    ( echo Processing Error 1.1: temporary data file structures not found )
    call :clean_up
    pause &exit /b 1
)
REM procedures for subroutine calls to extract unique identifiers from newest dataset
REM and newly generated dataset.
if exist %_merge%.csv (
    type nul > %_merge_uid%.csv && attrib +h %_merge_uid%.csv
    type nul > %_new_uid%.csv && attrib +h %_new_uid%.csv
    call :extract %_merge%.csv , %_merge_uid%.csv , "tokens=2 delims=,"
    call :extract %new_doc%.csv , %_new_uid%.csv , "skip=1 tokens=2 delims=,"
) else (
    ( echo Processing Error 1.2: temporary data file structures not found )
    call :clean_up
    pause &exit /b 1
)
REM procedures for comparing differences between the extracted lists of unique identifiers,
REM missing items (not found in edited dataset) will be copied over from the newest dataset.
if exist %_new_uid%.csv ( if exist %_merge_uid%.csv (
    for /f %%a in ('type %_new_uid%.csv ^| find /i "cod" /c') do set line_cnt=%%a
    for /f %%a in ('fc /lb %line_cnt% %_new_uid%.csv %_merge_uid%.csv ^| find /i "cod"') do (
        for /f "tokens=1-7 delims=," %%b in (%_proc_new%.csv) do (
            if %%a equ %%c ( echo %%b,%%c,%%d,%%e,%%f,%%g,%%h >> %_merge%.csv )))
)) else (
    ( echo Processing Error 1.3: temporary data file structures not found )
    call :clean_up
    pause &exit /b 1
)
type nul > %comp_doc%.csv && ( echo ,uid,date,datetime,text,num, > %comp_doc%.csv )
type %_merge%.csv >> %comp_doc%.csv
call :clean_up
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
    for /f "tokens=1-7 delims=," %%b in (^"!tpl!^") do (
        REM exhibit parsed token selectivity
        echo %%b,%%c,%%d,%%e,%%f,%%g,%%h >> %2
    ) || (
        echo Error Reading File Found &Exit /b 1
    )
)
exit /b

:extract
for /f %3 %%a in (%1) do (
    REM token selectivity for unique id column
    REM at position 1 - after reformat subroutine
    echo %%a >> %2
) || (
    echo Error Reading File Found &Exit /b 1
)
exit /b

:clean_up
if exist %_proc_edit%.csv ( del /A:H %_proc_edit%.csv )
if exist %_proc_new%.csv ( del /A:H %_proc_new%.csv )
if exist %_merge_uid%.csv ( del /A:H %_merge_uid%.csv )
if exist %_new_uid%.csv ( del /A:H %_new_uid%.csv )
if exist %_merge%.csv ( del /A:H %_merge%.csv )
exit /b

goto :eof