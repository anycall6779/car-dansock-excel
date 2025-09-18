@echo off
REM 한글 깨짐 방지를 위해 코드 페이지를 UTF-8로 변경
chcp 65001 > nul

REM 사용자에게 날짜 입력을 요청
set /p FOLDER_DATE="오늘 날짜를 입력하세요 (예: 25.09.17): "

REM 입력받은 날짜로 이미지 폴더 전체 경로를 생성
set IMAGE_PATH="C:\Users\User\Desktop\test\image\%FOLDER_DATE%"

echo.
echo %IMAGE_PATH% 폴더의 이미지를 스캔합니다...
echo.

REM 파이썬 스크립트 실행
REM ※ 중요: 아래 경로들은 사용자님의 실제 경로에 맞게 확인해주세요.
REM 1. 파이썬 실행 파일 경로
REM 2. 방금 저장한 run_ocr.py 파일 경로
"C:\Users\hUser\AppData\Local\Microsoft\WindowsApps\python3.10.exe" "C:\Users\User\Desktop\test\run_ocr.py" %IMAGE_PATH%


echo.
echo 모든 작업이 완료되었습니다.
REM 사용자가 결과를 확인할 수 있도록 잠시 대기
pause