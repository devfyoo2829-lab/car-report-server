-- 02-create-table.sql
CREATE TABLE sample (
	name VARCHAR(30),  --30글자 이하
	age INT			   --정수 (integer)
);


-- 테이블 삭제
DROP TABLE sample;

-- members 테이블을 생성
CREATE TABLE members (
	-- 자동으로 1씩 올라가게
	id 			INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	-- 비어있지 않게 (Null)
	name 		VARCHAR(30) NOT NULL,
	-- 중복 허용하지 않게
	email 		VARCHAR(100) UNIQUE,
	age			INT DEFAULT 20,
	-- 자동으로 오늘 날짜
	join_date 	DATE DEFAULT CURRENT_DATE
);

--DROP TABLE members;

