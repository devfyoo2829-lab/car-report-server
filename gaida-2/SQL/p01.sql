-- p01.sql

-- 1. practice db 생성-사용 -> 코드가 없음
-- 2. userinfo 테이블 생성
	-- id INT PK
    -- nickname: 글자 20자 까지, 필수 입력
    -- phone 글자 11 글자 까지, 중복 방지
    -- reg_date 날짜, 기본값(오늘 날짜)

CREATE TABLE practice(
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	nickname VARCHAR(20) NOT NULL,
	PHONE VARCHAR(11) UNIQUE,
	reg_date DATE DEFAULT CURRENT_DATE
);

-- 3. userinfo 테이블 CRUD
-- 데이터 5건 넣기 (별명, 핸드폰) -> 별명 bob 을 포함하세요 C
('alice', '0104567890'),
('bob', '0104561234'),
('charlie', '01112345678'),
('david', '01874562131'),
('eric', '01054687913');

INSERT into practice
(nickname,phone)
VALUES
('alice', '0104567890'),
('bob', '0104561234'),
('charlie', '01112345678'),
('david', '01874562131'),
('eric', '01054687913');



-- 전체 조회 (중간중간 계속 실행하면서 모니터링) R
SELECT * FROM practice;

-- id 가 3인 사람 조회 R
SELECT * FROM practice WHERE id='3';

-- 별명이 bob 인 사람을 조회 R
SELECT * FROM practice WHERE nickname='bob';

-- 별명이 bob 인 사람의 핸드폰 번호를 01099998888 로 수정 (id로 수정) U
UPDATE practice 
SET phone='01099998888'
WHERE id=2;

-- 별명이 bob 인 사람 삭제 (id로 수정) D
DELETE FROM practice where id=2;

