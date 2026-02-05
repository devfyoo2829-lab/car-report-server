-- 04-select.sql

-- * -> 모든 컬럼
SELECT * from members;

-- 컬럼 지정
SELECT name, email FROM members;

-- 조건 지정
SELECT * FROM members WHERE id!=1;

SELECT * FROM members WHERE age=20;

-- 컬럼 + 조건 (나이가 20인 사람들의 이름과 나이만 조회)
SELECT name, age FROM members WHERE age=20;


