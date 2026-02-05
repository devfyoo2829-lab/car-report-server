from flask import Flask, request, jsonify, send_file
from PIL import Image, ImageDraw, ImageFont
from datetime import datetime

app = Flask(__name__)

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
                if first_line:
                    lines.append('- ' + current_line.strip())
                else:
                    lines.append(('INDENT', current_line.strip()))
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
                    if current_line:
                        lines.append(current_line.strip())
                    current_line = word + ' '

            if current_line:
                lines.append(current_line.strip())

    return lines


@app.route('/add-text', methods=['POST'])
def add_text():
    try:
        data = request.json
        report_data = data['report_data']

        template_path = '/Users/yonniii/Desktop/gaida-2/n8n프로젝트/DB/tmp/report_base_F.png'
        img = Image.open(template_path)
        draw = ImageDraw.Draw(img)

        try:
            # 감정가 폰트 크기 60px로 고정 적용
            try:
                font_price = ImageFont.truetype("/System/Library/Fonts/SF-Pro-Display-Bold.otf", 55)
            except:
                try:
                    font_price = ImageFont.truetype("/System/Library/Fonts/Avenir Next.ttc", 55)
                except:
                    font_price = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 55)

            font_notice_body = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 20)

            try:
                font_content = ImageFont.truetype(
                    "/System/Library/Fonts/Supplemental/AppleGothic.ttf",
                    int(22 * 0.9)
                )
            except:
                font_content = ImageFont.truetype(
                    "/System/Library/Fonts/AppleSDGothicNeo.ttc",
                    int(22 * 0.9)
                )

            font_large = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 28)
            font_medium = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 24)
            font_small = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 20)
            font_tiny = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 18)
            font_micro = ImageFont.truetype(
                "/System/Library/Fonts/AppleSDGothicNeo.ttc",
                int(16 * 0.9)
            )
        except:
            font_price = font_notice_body = font_content = font_large = font_medium = font_small = font_tiny = font_micro = ImageFont.load_default()

        black = (0, 0, 0)
        gray = (80, 80, 80)

        # 문서번호
        draw.text((895, 180), "문서번호", fill=gray, font=font_tiny)
        draw.text((900, 203), report_data['vin'][:10], fill=black, font=font_medium)

        # 표 1행
        draw.text((140, 365), report_data['car_basic']['model_name'], fill=black, font=font_small)
        draw.text((475, 365), report_data['car_basic']['model_year'], fill=black, font=font_small)
        draw.text((790, 365), report_data['vin'], fill=black, font=font_small)

        # 표 2행
        draw.text((140, 457), report_data['history']['mileage_doc'], fill=black, font=font_small)
        draw.text((475, 457), report_data['car_basic']['color'], fill=black, font=font_small)
        draw.text((790, 457), report_data['car_basic']['car_number'], fill=black, font=font_small)

        # 감정가 (좌표 유지: 585, 670)
        draw.text(
            (585, 670),
            report_data['valuation']['final_price'],
            fill=black,
            font=font_price,
            anchor="mm"
        )

        # 저당권 안내
        mortgage_info = report_data.get('mortgage_info', {})
        has_mortgage = mortgage_info.get('has_mortgage', False)
        mortgage_amount = mortgage_info.get('mortgage_amount', '0원')
        amount_value = int(''.join(filter(str.isdigit, mortgage_amount))) if mortgage_amount else 0

        if has_mortgage and amount_value > 0:
            mortgage_holder = mortgage_info.get('mortgage_holder', '')
            notice_text = f"이 차량에는 {mortgage_amount}의 저당권이 설정되어 있습니다. (저당권자: {mortgage_holder})"
            draw.text((125, 862), notice_text, fill=black, font=font_notice_body)
        else:
            notice_text = "리포트 발급일 기준 저당권 설정이 없으나, 실제 매매 시점에 저당권 설정 여부를 반드시 재확인하시기 바랍니다."
            words = notice_text.split(' ')
            current_line = ''
            max_width = 880
            notice_lines = []

            for word in words:
                test_line = current_line + word + ' ' if current_line else word + ' '
                bbox = font_notice_body.getbbox(test_line)
                if bbox[2] - bbox[0] <= max_width:
                    current_line = test_line
                else:
                    notice_lines.append(current_line.strip())
                    current_line = word + ' '

            if current_line:
                notice_lines.append(current_line.strip())

            notice_y = 862
            for line in notice_lines:
                draw.text((125, notice_y), line, fill=black, font=font_notice_body)
                notice_y += 24

        # 분석 요약
        summary_lines = wrap_text_with_indent(
            report_data.get('analysis_summary', ''),
            font_content,
            int(450 * 0.95),
            indent=15
        )
        y = 1025
        for line in summary_lines:
            if isinstance(line, tuple):
                draw.text((145, y), line[1], fill=black, font=font_content)
            else:
                draw.text((130, y), line, fill=black, font=font_content)
            y += 28

        # 권고 사항
        recommend_lines = wrap_text_with_indent(
            report_data.get('recommendations', ''),
            font_content,
            int(450 * 0.95),
            indent=15
        )
        y = 1025
        for line in recommend_lines:
            if isinstance(line, tuple):
                draw.text((653, y), line[1], fill=black, font=font_content)
            else:
                draw.text((638, y), line, fill=black, font=font_content)
            y += 28

        # 시세 산정 근거
        valuation_note = report_data['valuation'].get('valuation_note', '')
        if valuation_note:
            draw.text((110, 1420), "※ 시세 산정 근거", fill=gray, font=font_small)
            words = valuation_note.split(' ')
            current_line = ''
            max_width = int(1050 * 0.95)
            note_lines = []

            for word in words:
                test_line = current_line + word + ' ' if current_line else word + ' '
                bbox = font_micro.getbbox(test_line)
                if bbox[2] - bbox[0] <= max_width:
                    current_line = test_line
                else:
                    note_lines.append(current_line.strip())
                    current_line = word + ' '

            if current_line:
                note_lines.append(current_line.strip())

            y = 1445
            for line in note_lines:
                draw.text((110, y), line, fill=gray, font=font_micro)
                y += 18

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