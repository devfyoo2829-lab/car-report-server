-- 11-number-func.sql

SELECT
	name,
	score AS 원점수,
	ROUND(score) AS 반올림,
	CEIL(score) AS 올림,
	FLOOR(score) AS 내림
FROM dt_demo;

-- 사칙연산
SELECT
	10+5 AS plus,
	10-5 AS minus,
	10*5 AS multiply,
	10/5 AS divide,
	10/3 AS 몫,
	10%3 AS 나머지,
	POWER(10,3) AS 거듭제곱,
	SQRT(16) AS 루트,
	ABS(-5) AS 절댓값
	; --AS 지정 안 하면 컬럼명 ?몰?루?

SELECT
	name,
	score,
	--IF(score >=80.0, '우수', '보통') --80점 이상이면 우수, 나머지는 보통
	CASE
		WHEN score >=90 THEN 'A'
		WHEN score >=80 THEN 'B'
		WHEN score >=70 THEN 'C'
		ELSE 'D'
	END AS 몰루
FROM dt_demo;

-- dt_demo에서 id가 홀수인지 짝수인지 판별하는 컬럼을 추가하여 확인

SELECT
	id,
	name,
	CASE
		WHEN id%2 = 1 THEN '홀'
		ELSE '짝'
	END AS 홀짝
FROM dt_demo;


