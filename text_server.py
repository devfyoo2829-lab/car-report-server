from flask import Flask, request, jsonify, send_file
from PIL import Image, ImageDraw, ImageFont
from datetime import datetime
import os

app = Flask(__name__)

# [수정] 파일 위치 자동 파악 (맥북/Render 공용)
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

        # [수정] 템플릿 경로를 상대 경로로 변경
        template_path = os.path.join(BASE_DIR, 'report_base_F.png')
        img = Image.open(template_path)
        draw = ImageDraw.Draw(img)

        # [수정] 폰트 로직: 우리가 올린 font.ttc를 최우선으로 사용
        def load_smart_font(font_size, is_bold=False):
            # 1. GitHub에 같이 올린 font.ttc 경로
            custom_font_path = os.path.join(BASE_DIR, 'font.ttc')
            
            # 2. 파일이 있으면 그걸 쓰고, 없으면 시스템 폰트나 기본 폰트 사용
            if os.path.exists(custom_font_path):
                return ImageFont.truetype(custom_font_path, font_size)
            else:
                # 파일이 없을 때를 대비한 백업 로직
                font_paths = [
                    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if is_bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
                    "/System/Library/Fonts/AppleSDGothicNeo.ttc"
                ]
                for path in font_paths:
                    if os.path.exists(path):
                        return ImageFont.truetype(path, font_size)
                return ImageFont.load_default()

        font_price = ImageFont.truetype(os.path.join(BASE_DIR, 'font.ttc'), 55, index=2)
        font_notice_body = load_smart_font(20)
        font_content = load_smart_font(int(22 * 0.9))
        font_medium = load_smart_font(24)
        font_small = load_smart_font(20)
        font_tiny = load_smart_font(18)
        font_micro = load_smart_font(int(16 * 0.9))

        black, gray = (0, 0, 0), (80, 80, 80)

        # 문서번호
        draw.text((895, 180), "문서번호", fill=gray, font=font_tiny)
        draw.text((900, 203), report_data['vin'][:10], fill=black, font=font_medium)

        # 표 1행/2행
        draw.text((140, 365), report_data['car_basic']['model_name'], fill=black, font=font_small)
        draw.text((475, 365), report_data['car_basic']['model_year'], fill=black, font=font_small)
        draw.text((790, 365), report_data['vin'], fill=black, font=font_small)
        draw.text((140, 457), report_data['history']['mileage_doc'], fill=black, font=font_small)
        draw.text((475, 457), report_data['car_basic']['color'], fill=black, font=font_small)
        draw.text((790, 457), report_data['car_basic']['car_number'], fill=black, font=font_small)

        # 감정가
        draw.text((585, 670), report_data['valuation']['final_price'], fill=black, font=font_price, anchor="mm")

        # 저당권 안내
        mortgage_info = report_data.get('mortgage_info', {})
        if mortgage_info.get('has_mortgage', False):
            notice_text = f"이 차량에는 {mortgage_info.get('mortgage_amount', '0원')}의 저당권이 설정되어 있습니다."
            draw.text((125, 862), notice_text, fill=black, font=font_notice_body)
        else:
            notice_text = "리포트 발급일 기준 저당권 설정이 없으나, 매매 시점에 반드시 재확인하시기 바랍니다."
            draw.text((125, 862), notice_text, fill=black, font=font_notice_body)

        # 분석 요약 & 권고 사항 (기존 좌표 적용)
        y_summary = 1025
        for line in wrap_text_with_indent(report_data.get('analysis_summary', ''), font_content, 420):
            x = 145 if isinstance(line, tuple) else 130
            draw.text((x, y_summary), line[1] if isinstance(line, tuple) else line, fill=black, font=font_content)
            y_summary += 28

        y_recommend = 1025
        for line in wrap_text_with_indent(report_data.get('recommendations', ''), font_content, 420):
            x = 653 if isinstance(line, tuple) else 638
            draw.text((x, y_recommend), line[1] if isinstance(line, tuple) else line, fill=black, font=font_content)
            y_recommend += 28

        # 시세 산정 근거
        val_note = report_data['valuation'].get('valuation_note', '')
        if val_note:
            draw.text((110, 1420), "※ 시세 산정 근거", fill=gray, font=font_small)
            draw.text((110, 1445), val_note[:100] + "...", fill=gray, font=font_micro)

        # 날짜
        current_date = datetime.now().strftime("%Y년 %m월 %d일")
        draw.text((106, 1510), current_date, fill=black, font=font_medium)

        output_path = '/tmp/final_report.png'
        img.save(output_path)
        return send_file(output_path, mimetype='image/png')

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(port=5000, debug=True)
