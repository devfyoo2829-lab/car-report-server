-- 14-having.sql

/*
SQL 실행 순서
1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT ← 여기서 컬럼 alias가 만들어짐 (AS)
6. ORDER BY
*/

SELECT
	category,
	COUNT(*) AS 주문건수,
	SUM(total_amount) AS 총매출액
FROM sales
WHERE total_amount >= 1000000
GROUP BY category;

-- GROUP BY로 만들어진 피벗테이블을 필터
-- 카테고리별 총매출액 천만원 이상만 주문건수, 총매출액을 확인
SELECT
	category,
	COUNT(*) AS 주문건수,
	SUM(total_amount) AS 총매출액
FROM sales
WHERE total_amount>=1000
GROUP BY category
HAVING SUM(total_amount) >= POWER(10,7);

-- 활성 지역 찾기
-- 지역, 주문건수, 고객수, 총매출액, 평균주문액 (고객수 >=15 AND 주문건수 >= 20)
SELECT
	region AS 지역,
	COUNT(*) AS 주문건수,
	COUNT(DISTINCT customer_id) AS 고객수,
	SUM(total_amount) AS 총매출액,
	ROUND(AVG(total_amount),0) AS 평균주문액
FROM sales
GROUP BY region
HAVING COUNT(customer_id)>=15 AND COUNT(*)>=20;

-- 우수 영업사원 -> 달 평균 매출액 50만원 이상인 sales_rep
SELECT * FROM sales;

SELECT
	TO_CHAR(order_date, 'YYYY-MM') AS 월,
	sales_rep AS 영업사원,
	SUM(total_amount) AS 총매출액,
	ROUND(SUM(total_amount)/12,0) AS 월평균매출액
FROM sales
GROUP BY sales_rep, 월
ORDER BY 월 ASC, 월평균매출액 DESC;


SELECT
	sales_rep AS 영업사원,
	COUNT(*) AS 판매건수,
	COUNT(DISTINCT customer_id) AS 고객수,
	SUM(total_amount) AS 총매출액,
	COUNT(DISTINCT TO_CHAR(order_date, 'YYYY-MM')) AS 활동개월수,
	-- 정수->실수 / 정수 => 실수
	SUM(total_amount)/COUNT(DISTINCT TO_CHAR(order_date, 'YYYY-MM')) AS 월평균매출액
FROM sales
GROUP BY sales_rep
HAVING SUM(total_amount)/COUNT(DISTINCT TO_CHAR(order_date, 'YYYY-MM')) >=1300000
ORDER BY 월평균매출액 DESC;



