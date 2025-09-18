@echo off
REM 한글 깨짐 방지를 위해 코드 페이지를 UTF-8로 변경
chcp 65001 > nul

:main
cls
echo ============================================================
echo.
echo              차량 번호판 자동 인식 프로그램
echo.
echo ============================================================
echo.


REM --- 수정된 부분 ---
REM 시스템에서 오늘 날짜를 가져와 'yy.mm.dd' 형식으로 만듭니다.
set TODAY_FORMATTED=%date:~2,2%.%date:~5,2%.%date:~8,2%

REM 오늘 날짜를 먼저 보여줍니다.
echo 오늘은 %TODAY_FORMATTED% 입니다.

REM 사용자에게 날짜 입력을 요청합니다.
set /p FOLDER_DATE="날짜를 입력하세요 (그냥 엔터 시 오늘 날짜로 지정): "

REM 만약 사용자가 아무것도 입력하지 않고 엔터를 눌렀다면, 오늘 날짜를 기본값으로 사용합니다.
if not defined FOLDER_DATE set "FOLDER_DATE=%TODAY_FORMATTED%"
REM --- 여기까지 수정 ---

REM 입력받은 날짜로 이미지 폴더 전체 경로를 생성
set IMAGE_PATH="C:\Users\hoho\Desktop\test\image\%FOLDER_DATE%"

echo.
echo %IMAGE_PATH% 폴더의 이미지를 스캔합니다...
echo.

REM 파이썬 스크립트 실행
REM ※ 중요: 아래 경로들은 사용자님의 실제 경로에 맞게 확인해주세요.
"C:\Users\hoho\AppData\Local\Microsoft\WindowsApps\python.exe" "%~dp0run_ocr.py" %IMAGE_PATH%


echo.
echo 모든 작업이 완료되었습니다.
REM 사용자가 결과를 확인할 수 있도록 잠시 대기
pause