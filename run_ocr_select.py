# 파일명: run_ocr_select.py

import cv2
import easyocr
import re
import os
import glob
import pandas as pd
from datetime import datetime
import sys
import numpy as np

# ==============================================================================
# 1단계: 번호판 추출 및 엑셀 생성 함수 (기존과 동일)
# ==============================================================================

def extract_license_plate(image_path, reader):
    """하나의 이미지 파일에서 (단속위치, 번호판)을 추출하는 함수"""
    location = os.path.basename(os.path.dirname(image_path))
    filename = os.path.basename(image_path)
    
    try:
        # 한글 경로 문제를 해결하기 위한 이미지 로딩 방식
        stream = open(image_path, "rb")
        bytes = bytearray(stream.read())
        numpy_array = np.asarray(bytes, dtype=np.uint8)
        img = cv2.imdecode(numpy_array, cv2.IMREAD_UNCHANGED)

        if img is None: 
            return (location, filename, "이미지 열기 실패")

        result = reader.readtext(img, detail=0, paragraph=False)
        pattern = re.compile(r'^\d{2,3}[가-힣]{1}\d{4}$')

        for text in result:
            cleaned_text = text.replace(" ", "")
            if pattern.match(cleaned_text):
                print(f"  [성공] {location} - {filename:30s} -> {cleaned_text}")
                return (location, filename, cleaned_text)
        
        print(f"  [실패] {location} - {filename:30s} -> 번호판을 찾지 못했습니다.")
        return (location, filename, "번호판을 찾지 못했습니다.")

    except Exception as e:
        return (location, filename, f"처리 중 오류: {e}")

def create_final_excel_report(results_list, output_filename):
    """처리 결과 리스트로 최종 엑셀 파일을 생성하는 함수"""
    if not results_list:
        print("\n엑셀 파일에 저장할 결과가 없습니다.")
        return
    try:
        print(f"\n인식 결과를 바탕으로 최종 엑셀 파일을 생성합니다.")
        
        today_date = datetime.now().strftime('%Y-%m-%d')
        df = pd.DataFrame(results_list, columns=['단속위치', '파일명(참고용)', '차량번호'])
        df.insert(0, '날짜', today_date)
        df['사유'] = ''
        df = df[['날짜', '단속위치', '사유', '차량번호']]

        df.to_excel(output_filename, index=False)
        
        print("-" * 40)
        print("--- 엑셀 파일 생성 완료 ---")
        print(f"결과가 '{os.path.abspath(output_filename)}' 파일에 저장되었습니다.")
    except Exception as e:
        print(f"엑셀 파일 생성 중 오류가 발생했습니다: {e}")

# ==============================================================================
# 2단계: 메인 프로그램 실행
# ==============================================================================
if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("오류: 올바른 인수가 전달되지 않았습니다.")
        print("실행 방법: python run_ocr_select.py <기본 폴더 경로> <스캔할 위치1> <스캔할 위치2> ...")
        sys.exit()

    target_directory = sys.argv[1].strip('"')
    locations_to_scan = [loc.strip('"') for loc in sys.argv[2:]]
    output_excel_filename = f"주차단속_결과_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"

    if not os.path.isdir(target_directory):
         print(f"오류: '{target_directory}'는 올바른 폴더가 아닙니다.")
         sys.exit()

    print("EasyOCR 모델을 로딩합니다... (처음 실행 시 시간이 걸릴 수 있습니다)")
    try:
        reader = easyocr.Reader(['ko', 'en'], gpu=False)
    except Exception as e:
        print(f"EasyOCR 로딩 중 오류가 발생했습니다: {e}")
        sys.exit()

    print(f"'{target_directory}' 폴더에서 다음 위치의 이미지를 검색합니다:")
    print(f" -> {locations_to_scan}")

    image_extensions = ['*.jpg', '*.jpeg', '*.png', '*.bmp']
    image_files = []

    if locations_to_scan == ['ALL']:
        print("\n[전체 스캔 모드] 모든 하위 폴더에서 이미지 파일을 검색합니다...")
        for ext in image_extensions:
            search_path = os.path.join(target_directory, '**', ext)
            image_files.extend(glob.glob(search_path, recursive=True))
    else:
        print("\n[선택 스캔 모드] 지정된 하위 폴더에서 이미지 파일을 검색합니다...")
        for location in locations_to_scan:
            location_path = os.path.join(target_directory, location)
            if not os.path.isdir(location_path):
                print(f"  [경고] '{location}' 폴더를 찾을 수 없어 건너뜁니다.")
                continue
            
            for ext in image_extensions:
                search_path = os.path.join(location_path, '**', ext)
                image_files.extend(glob.glob(search_path, recursive=True))

    image_files = sorted(image_files)
    
    if not image_files:
        print(f"\n오류: 지정된 위치에서 이미지 파일을 찾을 수 없습니다.")
    else:
        print(f"\n총 {len(image_files)}개의 이미지 파일을 찾았습니다. 순차 처리를 시작합니다.")
        print("-" * 40)

        all_results = []
        for image_path in image_files:
            result = extract_license_plate(image_path, reader)
            all_results.append(result)

        print("-" * 40)
        print(f"총 {len(all_results)}개의 이미지 처리가 완료되었습니다.")
        
        create_final_excel_report(all_results, output_excel_filename)