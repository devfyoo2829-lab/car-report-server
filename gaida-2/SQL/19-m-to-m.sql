-- 19-m-to-m.sql

-- 각 학생별 수강 수업 확인
SELECT
	*
FROM students s
INNER JOIN students_courses sc ON s.id = sc.student_id
INNER JOIN courses c ON sc.course_id = c.id ;

SELECT
	*
FROM courses c
INNER JOIN students_courses sc ON c.id = sc.student_id
INNER JOIN students s ON sc.student_id = s.id
ORDER BY c.name;

SELECT
	s.id,
	s.name,
	COUNT(c.id) AS 수업수,
	STRING_AGG(c.name,',')
FROM courses c
INNER JOIN students_courses sc ON c.id = sc.student_id
INNER JOIN students s ON sc.student_id = s.id
GROUP BY s.id, s.name;

-- 과목별 정리
/*수업id, 수업 이름, 강의실, 수강인원, 학생들 이름 한번에,
학점평균(소수점 2자리)
(A+=4.3, A=4, A-=3.7 B+ =3.5 B=3.0 B-=2.7) */

SELECT * FROM students;
SELECT * FROM students_courses;
SELECT * FROM courses;

SELECT
	c.id,
	c.name AS 수업이름,
	c.classroom AS 강의실,
	COUNT(sc.student_id) AS 수강인원,
	STRING_AGG(s.name, ',') AS 학생명단,
	ROUND(AVG
	(CASE
		WHEN sc.grade = 'A+' THEN 4.3
		WHEN sc.grade = 'A' THEN 4
		WHEN sc.grade = 'A-' THEN 3.7
		WHEN sc.grade = 'B+' THEN 3.5
		WHEN sc.grade = 'B' THEN 3
		WHEN sc.grade = 'B-' THEN 2.7
		ELSE 0
	END),2) AS 평균학점
FROM courses c
INNER JOIN students_courses sc ON c.id = sc.student_id
INNER JOIN students s ON sc.student_id = s.id
GROUP BY c.id, c.name, c.classroom;
