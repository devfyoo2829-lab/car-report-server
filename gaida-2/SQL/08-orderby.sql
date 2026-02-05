-- 08-orderby.sql
-- 특정 컬럼을 기준으로 정렬한다.
-- ASC 오름차순| DESC 내림차순

-- 이름 ㄱㄴㄷ 순 정렬
SELECT * FROM students ORDER BY name;
SELECT * FROM students ORDER BY name ASC; --기본값
SELECT * FROM students ORDER BY name DESC; --내림차순

-- 테이블 컬럼 추가 및 데이터 수정
SELECT * FROM students ORDER BY id DESC; --id 22까지
ALTER TABLE students ADD COLUMN grade VARCHAR(1) DEFAULT 'B';
UPDATE students SET grade='A' WHERE id BETWEEN 1 AND 7;
UPDATE students SET grade='C' WHERE id BETWEEN 15 AND 22;

-- 다중 컬럼 정렬 -> 앞에 오는 컬럼이 먼저 정렬 기준
-- 같은 성적끼리 나이 줄세우기
SELECT * FROM students ORDER BY
grade DESC, age ASC;
-- 같은 나이끼리 성적 줄세우기
SELECT * FROM students ORDER BY
age ASC, grade DESC;

SELECT * FROM students ORDER BY id LIMIT 5;

-- 나이가 40 미만인 학생들 중에서 학점이 가장 높은 사람들 중에
-- 나이많은순 으로 상위 5명 뽑기

SELECT * FROM students
WHERE age < 40
ORDER BY grade ASC, age DESC
LIMIT 5;

CREATE TABLE userinfo(
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(20),
	age INT

)

