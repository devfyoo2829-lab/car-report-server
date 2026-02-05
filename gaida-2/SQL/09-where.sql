-- 08-where.sql

CREATE TABLE students(
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(10) NOT NULL,
	age INT
);

SELECT * FROM students;

INSERT INTO students (name, age) VALUES
('김 수환무', 5),
('박 혁거세', 3);

-- 특정 컬럼의 값
-- 같음
SELECT * FROM students WHERE name='송 민재'
-- 아님
SELECT * FROM students WHERE id!=1;
-- 이상
SELECT * FROM students WHERE age>= 20;
-- 초과
SELECT * FROM students WHERE age> 20;
-- 범위(이상-이하)
SELECT * FROM students WHERE age BETWEEN 20 AND 40;
-- 다중 선택
SELECT * FROM students WHERE id=1 OR age=30 OR id=5;
SELECT * FROM students WHERE id IN (1,3,5);

-- 문자열 패턴 찾기 (% -> 있을 수도 없을 수도, _ -> 개수만큼 있다)
-- 최씨 찾기
SELECT * FROM students WHERE name LIKE '최%';
-- 이름에 '민' 글자가 있으면 모두
SELECT * FROM students WHERE name LIKE '%민%';
-- 이름이 '훈' 으로 끝나는 사람 모두
SELECT * FROM students WHERE name LIKE '%훈'

-- '박' 이후에 글자가 3개 있어야 한다.
SELECT * FROM students WHERE name LIKE '박 ___';

