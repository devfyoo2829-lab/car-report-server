-- 07-alter-drop.sql
SELECT * FROM members;

--컬럼 추가
ALTER TABLE members
ADD COLUMN address VARCHAR(100) NOT NULL DEFAULT '';

--컬럼 이름 수정
ALTER TABLE members
RENAME COLUMN juso TO address;

--컬럼 데이터타입 수정
ALTER TABLE members
ALTER COLUMN address TYPE VARCHAR(100);

ALTER TABLE members
ALTER COLUMN address SET DEFAULT 10;
SELECT * FROM members;

--컬럼 삭제
ALTER TABLE members
DROP COLUMN address;
