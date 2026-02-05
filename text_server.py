from flask import Flask, request, jsonify, send_file
from PIL import Image, ImageDraw, ImageFont
from datetime import datetime
import os

app = Flask(__name__)

# 현재 파이썬 파일이 실행되는 위치를 기준으로 경로 설정
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
        words = paragraph.strip()[1:].strip().split(' ') if is_bullet else paragraph.split(' ')
        current_line = ''
        first_line = True
        for word in words:
            test_line = current_line + word + ' ' if current_line else word + ' '
            available_width = max_width if (not is_bullet or first_line) else max_width - indent
            bbox = font.getbbox(test_line)
            if (bbox[2] - bbox[0]) <= available_width:
                current_line = test_line
            else:
                if current_line:
                    if is_bullet and first_line:
                        lines.append('- ' + current_line.strip())
                        first_line = False
                    elif is_bullet:
                        lines.append(('INDENT', current_line.strip()))
                    else:
                        lines.append(current_line.strip())
                current_line = word + ' '
        if current_line:
            if is_bullet and first_line: lines.append('- ' + current_line.strip())
            elif is_bullet: lines.append(('INDENT', current_line.strip()))
            else: lines.append(current_line.strip())
    return lines

@app.route('/add-text', methods=['POST'])
def add_text():
    try:
        data = request.json
        report_data = data['report_data']

        # [중요] 템플릿 이미지 경로를 상대 경로로 설정
        template_path = os.path.join(BASE_DIR, 'report_base_F.png')
        
        if not os.path.exists(template_path):
            return jsonify({'error': f'Template image not found at {template_path}'}), 404

        img = Image.open(template_path)
        draw = ImageDraw.Draw(img)

        # 폰트 설정 (서버에 폰트가 없을 경우를 대비해 기본 폰트 사용)
        def get_font(size):
            try:
                # 리눅스 서버(Render) 기본 폰트 경로 시도
                return ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", size)
            except:
                return ImageFont.load_default()

        font_price = get_font(53)
        font_notice_body = get_font(20)
        font_content = get_font(18)
        font_medium = get_font(24)
        font_small = get_font(20)
        font_tiny = get_font(18)
        font_micro = get_font(14)

        black, gray = (0, 0, 0), (80, 80, 80)

        # 데이터 입력 (좌표는 기존 유지)
        draw.text((895, 180), "문서번호", fill=gray, font=font_tiny)
        draw.text((900, 203), report_data['vin'][:10], fill=black, font=font_medium)
        draw.text((140, 365), report_data['car_basic']['model_name'], fill=black, font=font_small)
        draw.text((475, 365), report_data['car_basic']['model_year'], fill=black, font=font_small)
        draw.text((790, 365), report_data['vin'], fill=black, font=font_small)
        draw.text((140, 457), report_data['history']['mileage_doc'], fill=black, font=font_small)
        draw.text((475, 457), report_data['car_basic']['color'], fill=black, font=font_small)
        draw.text((790, 457), report_data['car_basic']['car_number'], fill=black, font=font_small)

        # 감정가 (중앙 정렬)
        draw.text((585, 670), report_data['valuation']['final_price'], fill=black, font=font_price, anchor="mm")

        # 분석 요약 및 권고 사항
        for section, start_x, start_indent_x in [('analysis_summary', 130, 145), ('recommendations', 638, 653)]:
            lines = wrap_text_with_indent(report_data.get(section, ''), font_content, 420)
            y = 1025
            for line in lines:
                x = start_indent_x if isinstance(line, tuple) else start_x
                draw.text((x, y), line[1] if isinstance(line, tuple) else line, fill=black, font=font_content)
                y += 28

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
