@echo off
rem 한글 폴더 이름이 깨지지 않도록 코드 페이지를 UTF-8로 변경합니다.
chcp 65001 > nul

rem --- 경로 및 폴더 이름 설정 ---
set TARGET_DIR="C:\Users\User\Desktop\test\image"
set FOLDER_NAME=%date:~2,2%.%date:~5,2%.%date:~8,2%
set DAILY_FOLDER_PATH=%TARGET_DIR%\%FOLDER_NAME%

echo.
echo 오늘 작업할 폴더: %DAILY_FOLDER_PATH%
echo.

rem --- 오늘 날짜 폴더가 없으면 새로 만듭니다. ---
if not exist %DAILY_FOLDER_PATH% (
    mkdir %DAILY_FOLDER_PATH%
    echo [%FOLDER_NAME%] 폴더를 새로 만들었습니다.
) else (
    echo [%FOLDER_NAME%] 폴더는 이미 존재합니다.
)

echo.
echo 하위 폴더 생성을 시작합니다...
echo ---------------------------------

rem for 반복문을 사용해 지정된 이름의 하위 폴더들을 한 번에 생성합니다.
for %%F in (1동 2동 3동 4동 5동 6동 7동 8동 9동 10동 11동 12동 13동 14동 15동 중앙동 민원동 2청사) do (
    if not exist "%DAILY_FOLDER_PATH%\%%F" (
        mkdir "%DAILY_FOLDER_PATH%\%%F"
        echo  - '%%F' 폴더 생성 완료.
    ) else (
        echo  - '%%F' 폴더는 이미 있습니다.
    )
)

echo ---------------------------------
echo.
echo 모든 작업이 완료되었습니다.
pause