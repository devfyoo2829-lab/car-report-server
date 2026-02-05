-- 05-update.sql

-- 데이터 추가 (name='익명')

INSERT INTO members (name) VALUES ('익명');
SELECT * FROM members;

-- 데이터 수정
UPDATE members
SET name='홍길동'
WHERE name='익명';

-- 마지막 사람(id=12)의 메일과 나이를 수정
UPDATE members
SET name='홍길동',age=20
WHERE id=12;
