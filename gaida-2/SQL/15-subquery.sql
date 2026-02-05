-- 15-subquery.sql
-- 매출 평균보다 더 높은 금액을 주문한 판매 데이터(*)

SELECT AVG(total_amount) FROM sales;

SELECT *
FROM sales
WHERE total_amount >= 500000;

-- 특정 값을 매번 계산해서 잘 가져옴
SELECT *
FROM sales
WHERE total_amount >= (SELECT AVG(total_amount) FROM sales);


--
SELECT
	product_name AS 이름,
	total_amount AS 판매액,
	total_amount- (SELECT ROUND(AVG(total_amount),0) FROM sales) AS 평균차이
FROM sales
WHERE total_amount >= (SELECT AVG(total_amount) FROM sales);

-- sales 에서 가장 비싼 total_amount를 가진 데이터
SELECT * FROM sales
WHERE total_amount = (SELECT MAX(total_amount) FROM sales);

-- 가장 주문 금액 평균과 실제 주문액수의 차이가 적은 5개
SELECT
	ROUND(AVG(total_amount),0)
FROM sales
GROUP BY id;

SELECT
	total_amount-(SELECT ROUND(AVG(total_amount),0) FROM sales GROUP BY id) AS 차이
FROM sales
GROUP BY id;
ORDER BY total_amount-(SELECT	ROUND(AVG(total_amount),0) FROM sales GROUP BY id)


