-- 20-cross-join.sql

SELECT
	s.name,
	c.name
FROM students s
CROSS JOIN courses c
WHERE NOT EXISTS (
	SELECT 1
	FROM students_courses sc
	WHERE sc.student_id = s.id
	AND sc.course_id = c.id
);


SELECT * FROM students;
SELECT * FROM courses;