@echo off
REM 한글 깨짐 방지를 위해 코드 페이지를 UTF-8로 변경
chcp 65001 > nul
title 차량 번호판 인식 프로그램

:main
cls
echo ============================================================
echo.
echo              차량 번호판 자동 인식 프로그램
echo.
echo ============================================================
echo.

REM 시스템에서 오늘 날짜를 가져와 'yy.mm.dd' 형식으로 만듭니다.
set TODAY_FORMATTED=%date:~2,2%.%date:~5,2%.%date:~8,2%

REM 오늘 날짜를 먼저 보여줍니다.
echo 오늘은 %TODAY_FORMATTED% 입니다.

REM 사용자에게 날짜 입력을 요청합니다.
set /p FOLDER_DATE="날짜를 입력하세요 (그냥 엔터 시 오늘 날짜로 지정): "

REM 만약 사용자가 아무것도 입력하지 않고 엔터를 눌렀다면, 오늘 날짜를 기본값으로 사용합니다.
if not defined FOLDER_DATE set "FOLDER_DATE=%TODAY_FORMATTED%"

REM 날짜 폴더 경로 생성
set BASE_PATH="C:\Users\hoho\Desktop\test\image\%FOLDER_DATE%"

REM 날짜 폴더가 실제로 있는지 확인
if not exist %BASE_PATH% (
    echo.
    echo [오류] %BASE_PATH% 폴더를 찾을 수 없습니다.
    echo 날짜를 올바르게 입력했는지, 폴더가 실제로 있는지 확인해주세요.
    echo.
    pause
    goto main
)

:select_mode
cls
echo 날짜: %FOLDER_DATE%
echo ------------------------------------------------------------
echo.
echo ▶ 스캔 방식을 선택하세요.
echo.
echo    1. 전체 스캔 (모든 하위 폴더)
echo    2. 특정 위치 선택 스캔
echo.
choice /c 12 /n /m "번호를 입력하세요 [1,2]: "

if errorlevel 2 goto select_specific
if errorlevel 1 goto scan_all


:scan_all
REM 'ALL' 이라는 키워드를 파이썬으로 전달
set "LOCATIONS_TO_SCAN=ALL"
goto run_python


:select_specific
set "SELECTED_LIST="
set "SELECTED_NAMES="

:select_loop
cls
echo 날짜: %FOLDER_DATE%
echo ------------------------------------------------------------
echo.
echo ▶ 스캔할 위치를 선택하세요. (번호 입력 후 엔터)
echo.
echo 1.1동 2.2동 3.3동 4.4동 5.5동 6.6동 7.7동 8.8동 9.9동 10.10동 11.11동 12.12동 13.13동 14.14동 15.15동 16.중앙동 17.민원동 18.2청사
echo.
echo ------------------------------------------------------------
echo.
echo [현재 선택된 위치: %SELECTED_NAMES%]
echo.
echo - 번호를 입력하여 위치를 추가/제거할 수 있습니다.
echo - 선택을 완료하려면 '.'를 입력하세요.
echo.

set /p "CHOICE=▶ 입력: "
REM =================================================================
REM ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
REM 엔터 대신, '.'을 입력하면 선택 완료로 변경
REM =================================================================
if "%CHOICE%"=="." goto selection_done

REM 사용자가 입력한 번호에 해당하는 폴더 이름을 변수에 할당
set "NAME="
if "%CHOICE%"=="1" set "NAME=1동"
if "%CHOICE%"=="2" set "NAME=2동"
if "%CHOICE%"=="3" set "NAME=3동"
if "%CHOICE%"=="4" set "NAME=4동"
if "%CHOICE%"=="5" set "NAME=5동"
if "%CHOICE%"=="6" set "NAME=6동"
if "%CHOICE%"=="7" set "NAME=7동"
if "%CHOICE%"=="8" set "NAME=8동"
if "%CHOICE%"=="9" set "NAME=9동"
if "%CHOICE%"=="10" set "NAME=10동"
if "%CHOICE%"=="11" set "NAME=11동"
if "%CHOICE%"=="12" set "NAME=12동"
if "%CHOICE%"=="13" set "NAME=13동"
if "%CHOICE%"=="14" set "NAME=14동"
if "%CHOICE%"=="15" set "NAME=15동"
if "%CHOICE%"=="16" set "NAME=중앙동"
if "%CHOICE%"=="17" set "NAME=민원동"
if "%CHOICE%"=="18" set "NAME=2청사"

REM NAME이 설정되었을 경우에만 아래 로직 실행
if defined NAME (
    REM 중복 선택 확인 및 처리 (버그 수정된 로직)
    set "CHECK= %SELECTED_LIST% "
    echo "%CHECK%" | findstr /c:" %NAME% " > nul

    if errorlevel 1 (
        REM 리스트에 없으면 추가
        if not defined SELECTED_LIST (
            set "SELECTED_LIST=%NAME%"
        ) else (
            set "SELECTED_LIST=%SELECTED_LIST% %NAME%"
        )
    ) else (
        REM 리스트에 있으면 제거
        call set "TEMP_LIST=%%CHECK: %NAME% = %%"
        call set "SELECTED_LIST=%%TEMP_LIST:~1,-1%%"
    )
    set "SELECTED_NAMES=%SELECTED_LIST%"
)

goto select_loop


:selection_done
if not defined SELECTED_LIST (
    echo.
    echo [알림] 아무것도 선택되지 않았습니다. 다시 시도해주세요.
    pause
    goto select_specific
)
set "LOCATIONS_TO_SCAN=%SELECTED_LIST%"


:run_python
cls
echo ------------------------------------------------------------
echo.
echo ▶ 다음 위치에 대한 스캔을 시작합니다.
echo    [%LOCATIONS_TO_SCAN%]
echo.
echo 잠시 후 프로그램이 시작됩니다...
echo.
pause

"C:\Users\hoho\AppData\Local\Microsoft\WindowsApps\python.exe" "%~dp0run_ocr_select.py" %BASE_PATH% %LOCATIONS_TO_SCAN%


echo.
echo 모든 작업이 완료되었습니다.
pause