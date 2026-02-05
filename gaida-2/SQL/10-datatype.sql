-- 10-datatype.sql

CREATE TABLE dt_demo (
	id 			INT 		GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name 		VARCHAR(20) NOT NULL,
	nickname 	VARCHAR(20),
	birth 		DATE, --YYYY-MM-DD
	score 		FLOAT, --소수점 포함 저장 가능. 정확도 100% 아님
	salary 		DECIMAL(20,3), --전체 20자리, 소수점 이하 3자리. 정확도 100%
	description TEXT, --길이제한 없는 문자열
	is_active 	BOOL 		DEFAULT TRUE, -- 참/거짓
	created_at 	TIMESTAMP 	DEFAULT CURRENT_TIMESTAMP --날짜+시간
);

SELECT * FROM dt_demo;


INSERT INTO dt_demo (name, nickname, birth, score, salary, description)
VALUES
('김철수', 'kim', '1995-01-01', 88.75, 3500000, '우수한 학생입니다.'),
('이영희', 'lee', '1990-05-15', 92.30, 4200000.8888, '성실하고 열심히 공부합니다.'),
('박민수', 'park', '1988-09-09', 75.80, 2800000.75, '기타 사항 없음');

SELECT * FROM dt_demo;