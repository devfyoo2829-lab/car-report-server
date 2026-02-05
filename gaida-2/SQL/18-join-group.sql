-- 18-join-group.sql
-- VIP 고객(c)들의 구매 내역(s) 조회(*)ABORT
SELECT
	*
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
WHERE c.customer_type = 'VIP';

-- 각 등급별 구매액 평균
SELECT
	c.customer_type AS 등급,
	COUNT(*) AS 고객수,
	ROUND(AVG(s.total_amount),0) AS 평균구매액
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
GROUP BY customer_type;

-- 모든 고객의 구매 현황 분석
-- 고객 이름, 고객 등급, 주문 횟수, 총구매액, 평균주문액, 최근주문일
-- 총구매액(없으면 0), 평균주문액(없으면 0.0), 최근주문일(없으면 '주문없음')
-- COALESCE(NULL, 0) -> A가 NULL이 아니면 A. A가 NULL이면 B

SELECT * FROM customers;
SELECT
	COUNT(DISTINCT customer_id)
FROM sales;

SELECT
	c.customer_name AS 고객이름,
	c.customer_type AS 등급,
	COUNT(s.customer_id) AS 주문횟수,
	COALESCE(SUM(s.total_amount, 0)) AS 총구매액
	--평균주문액
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id;
GROUP BY c.customer_name, c.customer_type;


SELECT
	c.customer_id,
	c.customer_name AS 고객이름,
	c.customer_type AS 등급,
	COUNT(s.id) AS 주문횟수,
	COALESCE(SUM(s.total_amount),0) AS 총구매액,
	ROUND(COALESCE(AVG(s.total_amount), 0.0),0) AS 평균주문액,
	COALESCE(TO_CHAR(MAX(s.order_date), 'YYYY-MM-DD'),'주문없음') AS 최근주문일,
	CASE
		WHEN COUNT(s.id) = 0 THEN '잠재고객'
		WHEN COUNT(s.id) >= 5 THEN '충성고객'
		WHEN COUNT(s.id) > 2 THEN '일반고객'
		ELSE '신규고객'
	END AS 고객분류
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type;



