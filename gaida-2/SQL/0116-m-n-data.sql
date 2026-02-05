-- 0116-m-n-data.sql

DROP TABLE IF EXISTS students_courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;

CREATE TABLE students (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(20)
);

CREATE TABLE courses (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(50),
  classroom VARCHAR(20)
);

CREATE TABLE students_courses (
  student_id INT,
  course_id INT,
  grade VARCHAR(5),
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(id),
  FOREIGN KEY (course_id) REFERENCES courses(id)
);

INSERT INTO students (name) VALUES
('김학생'),
('이학생'),
('박학생'),
('최학생'),
('정학생'),
('오학생'),
('강학생'),
('윤학생'),
('장학생'),
('임학생');

INSERT INTO courses (name, classroom) VALUES
('MySQL 데이터베이스', 'A관 101호'),
('PostgreSQL 고급', 'B관 203호'),
('데이터 분석', 'A관 704호'),
('SQL 튜닝', 'B관 305호'),
('파이썬 데이터 처리', 'C관 402호'),
('통계 기초', 'C관 210호');

INSERT INTO students_courses (student_id, course_id, grade) VALUES
(1, 1, 'A'),
(1, 2, 'B+'),
(1, 3, 'A-'),
(2, 1, 'A-'),
(2, 3, 'B'),
(2, 4, 'B+'),
(3, 2, 'A+'),
(3, 3, 'A'),
(3, 5, 'A'),
(4, 1, 'B+'),
(4, 4, 'A'),
(4, 6, 'B'),
(5, 2, 'A'),
(5, 5, 'A-'),
(6, 3, 'B'),
(6, 5, 'B+'),
(6, 6, 'A'),
(7, 1, 'A'),
(7, 2, 'A-'),
(7, 4, 'B'),
(8, 3, 'A+'),
(8, 4, 'A'),
(8, 6, 'A-'),
(9, 5, 'B+'),
(9, 6, 'B'),
(10, 2, 'A'),
(10, 3, 'A'),
(10, 4, 'A+');

SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM students_courses;
