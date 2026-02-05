-- 03-insert.sql

INSERT INTO members(name, email, age)
VALUES ('곽승연', 'fyoo2829@gmail.com', '30');

SELECT * FROM members;

INSERT INTO members(email) values ('a@g.com')
INSERT INTO members(name) values ('라라라')

DELETE FROM members where id=5;

INSERT INTO members (name, email)
VALUES
('이이이', 'lee@lee.com'),
('최최최', '최@최.com'),
('정정정', '정@정.com');

-- 테이블 모든 데이터 확인
SELECT * FROM members;