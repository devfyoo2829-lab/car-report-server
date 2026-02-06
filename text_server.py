from flask import Flask, request, jsonify, send_file
from PIL import Image, ImageDraw, ImageFont
from datetime import datetime
import os
import io

app = Flask(__name__)

# 파일 위치 자동 파악 (맥북/Render 공용 환경 대응)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def wrap_text_with_indent(text, font, max_width, indent=15):
    text = text.replace('\\n', '\n')
    lines = []
    paragraphs = text.split('\n')
    for paragraph in paragraphs:
        if not paragraph.strip():
            lines.append('')
            continue
        is_bullet = paragraph.strip().startswith('-')
        if is_bullet:
            bullet_text = paragraph.strip()[1:].strip()
            words = bullet_text.split(' ')
            current_line = ''
            first_line = True
            for word in words:
                test_line = current_line + word + ' ' if current_line else word + ' '
                available_width = max_width if first_line else max_width - indent
                bbox = font.getbbox(test_line)
                width = bbox[2] - bbox[0]
                if width <= available_width:
                    current_line = test_line
                else:
                    if current_line:
                        if first_line:
                            lines.append('- ' + current_line.strip())
                            first_line = False
                        else:
                            lines.append(('INDENT', current_line.strip()))
                    current_line = word + ' '
            if current_line:
                if first_line: lines.append('- ' + current_line.strip())
                else: lines.append(('INDENT', current_line.strip()))
        else:
            words = paragraph.split(' ')
            current_line = ''
            for word in words:
                test_line = current_line + word + ' ' if current_line else word + ' '
                bbox = font.getbbox(test_line)
                width = bbox[2] - bbox[0]
                if width <= max_width:
                    current_line = test_line
                else:
                    if current_line: lines.append(current_line.strip())
                    current_line = word + ' '
            if current_line: lines.append(current_line.strip())
    return lines

@app.route('/add-text', methods=['POST'])
def add_text():
    try:
        data = request.json
        report_data = data['report_data']

        # 배경 이미지 경로 설정
        template_path = os.path.join(BASE_DIR, 'report_base_F.png')
        img = Image.open(template_path)
        
        # PNG는 RGBA를 지원하므로 별도의 모드 변환 없이 진행해도 무방합니다.
        draw = ImageDraw.Draw(img)

        # 폰트 로드 함수
        def load_smart_font(font_size, index=0):
            custom_font_path = os.path.join(BASE_DIR, 'font.ttc')
            if os.path.exists(custom_font_path):
                return ImageFont.truetype(custom_font_path, font_size, index=index)
            return ImageFont.load_default()

        # 폰트 설정
        font_price = load_smart_font(55, index=2)
        font_notice_body = load_smart_font(20) 
        font_content = load_smart_font(int(22 * 0.9))
        font_medium = load_smart_font(24)
        font_small = load_smart_font(20)
        font_tiny = load_smart_font(18)
        font_page = load_smart_font(16)

        black, gray = (0, 0, 0), (80, 80, 80)

        # 1. 문서번호 및 차량 기본 정보
        draw.text((895, 180), "문서번호", fill=gray, font=font_tiny)
        draw.text((900, 203), report_data['vin'][:10], fill=black, font=font_medium)
        draw.text((140, 365), report_data['car_basic']['model_name'], fill=black, font=font_small)
        draw.text((475, 365), report_data['car_basic']['model_year'], fill=black, font=font_small)
        draw.text((790, 365), report_data['vin'], fill=black, font=font_small)
        draw.text((140, 458), report_data['history']['mileage_doc'], fill=black, font=font_small)
        draw.text((475, 458), report_data['car_basic']['color'], fill=black, font=font_small)
        draw.text((790, 458), report_data['car_basic']['car_number'], fill=black, font=font_small)

        # 2. 감정가
        draw.text((585, 670), report_data['valuation']['final_price'], fill=black, font=font_price, anchor="mm")

        # 3. 시세 산정 근거
        valuation_note = report_data['valuation'].get('valuation_note', '')
        y_val = 855
        if valuation_note:
            val_lines = wrap_text_with_indent(valuation_note, font_notice_body, 920)
            for line in val_lines:
                draw.text((125, y_val), line, fill=gray, font=font_notice_body)
                y_val += 25

        # 4. 저당권 설정 안내
        mortgage_info = report_data.get('mortgage_info', {})
        if mortgage_info.get('has_mortgage', False):
            m_amount = mortgage_info.get('mortgage_amount', '0원')
            notice_text = f"이 차량에는 {m_amount}의 저당권이 설정되어 있습니다."
        else:
            notice_text = "리포트 발급일 기준 저당권 설정이 없으나, 매매 시점에 반드시 재확인하시기 바랍니다."
        
        draw.text((125, 942), notice_text, fill=gray, font=font_notice_body)

        # 5. 분석 요약 및 권고사항
        box_width = 400
        start_y = 1095 
        
        y_summary = start_y
        for line in wrap_text_with_indent(report_data.get('analysis_summary', ''), font_content, box_width):
            x = 155 if isinstance(line, tuple) else 140
            draw.text((x, y_summary), line[1] if isinstance(line, tuple) else line, fill=black, font=font_content)
            y_summary += 28

        y_recommend = start_y
        for line in wrap_text_with_indent(report_data.get('recommendations', ''), font_content, box_width):
            x = 663 if isinstance(line, tuple) else 648
            draw.text((x, y_recommend), line[1] if isinstance(line, tuple) else line, fill=black, font=font_content)
            y_recommend += 28

        # 6. 날짜 및 페이지 번호
        current_date = datetime.now().strftime("%Y년 %m월 %d일")
        draw.text((106, 1510), current_date, fill=black, font=font_medium)
        draw.text((img.width // 2, 1460), "1/1", fill=gray, font=font_page, anchor="mm")

        # [핵심 수정 부분] 이미지를 PNG 바이너리로 반환
        img_io = io.BytesIO()
        img.save(img_io, format='PNG')
        img_io.seek(0)

        # PNG 이미지로 반환 (mimetype 설정)
        # 미리보기를 위해 as_attachment=False로 설정하는 것이 좋습니다.
        return send_file(
            img_io, 
            mimetype='image/png', 
            as_attachment=False, 
            download_name='Cartells_Report.png'
        )

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)