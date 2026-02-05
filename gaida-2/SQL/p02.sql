-- p02.sql

SELECT * FROM userinfo;

-- userinfo에 email 컬럼 추가 40글자 제한, 기본값 ex@gmail.com
ALTER TABLE userinfo
ADD COLUMN email VARCHAR(40) DEFAULT 'ex@gmail.com';

-- nickname 길이제한 100자로 늘리기
ALTER TABLE userinfo
ALTER COLUMN nickname TYPE VARCHAR(100);

-- reg_date 컬럼 삭제
ALTER TABLE userinfo
DROP COLUMN reg_date;

-- 실제 아무나 한 명의 email을 수정하기
UPDATE userinfo
SET email = 'fyoo2829@gmail.com'
WHERE nickname = 'alice';

SELECT * FROM userinfo;


