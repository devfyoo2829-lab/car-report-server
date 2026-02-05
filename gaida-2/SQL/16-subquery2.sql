-- 16-subquery2.sql
/*
Scala  -> 데이터 1개 | 14.56
Vector -> 데이터 1줄 | ("인천", "대구", "부산", "광주", "서울")
		  IN 뒤에 주로 사용
Matrix -> 행*열
		  FROM 뒤에 주로 사용
*/

-- Scala
SELECT AVG(total_amount) FROM sales;
-- Vector
SELECT DISTINCT region from sales;

-- VIP들의 주문내역만 확인
SELECT customer_id FROM customers WHERE customer_type='VIP';

SELECT * FROM sales 
WHERE customer_id 
-- IN("C001","C005",...)
IN (SELECT customer_id FROM customers WHERE customer_type='VIP');


-- 전자 제품을 구매한 고객들의 모든 주문
SELECT * FROM sales;


SELECT
	DISTINCT(customer_id)
FROM sales
WHERE category IN ('전자제품'); -- customer_id


SELECT * FROM sales
WHERE customer_id IN
	(SELECT DISTINCT(customer_id)
	 FROM sales
	 WHERE category IN ('전자제품'));


