-- 13-groupby.sql

SELECT * FROM sales WHERE region = '서울' AND category = '식품';

SELECT
	region,
	category,
	COUNT(id) AS 지역_카테고리_매출건수,
	ROUND(AVG(total_amount),2) AS 지역_카테고리_평균매출
FROM sales
GROUP BY region, category
ORDER BY 지역_카테고리_평균매출 DESC
LIMIT 3;

-- 자료의 내용 다시보기
SELECT * FROM sales;

-- 구매빈도에 따른 인기 제품군
SELECT
	category,
	COUNT(id) AS 카테고리_매출건수,
	ROUND(AVG(total_amount),2) AS 카테고리_평균매출
FROM sales
GROUP BY category
ORDER BY 카테고리_매출건수 DESC;

-- 구매빈도에 따른 지역별 구매빈도에 따른 인기 제품군
SELECT
	region,
	category,
	COUNT(id) AS 지역별_카테고리별_매출건수
FROM sales
GROUP BY region, category
ORDER BY 지역별_카테고리별_매출건수 DESC;

-- 지역별 구매빈도에 따른 인기 제품
SELECT
	region,
	product_name,
	COUNT(id) AS 지역별_매출건수,
	ROUND(AVG(total_amount),0) AS 지역별_평균매출
FROM sales
GROUP BY region, product_name
ORDER BY 지역별_평균매출 DESC;

-- 카테고리별 분석
-- 카테고리, 주문건수, 총 매출, 평균 매출 -> 총매출 내림차순
SELECT
	category AS 카테고리,
	COUNT(*) AS 주문건수,
	SUM(total_amount) AS 총매출,
	ROUND(AVG(total_amount),0) AS 평균매출
FROM sales
GROUP BY category
ORDER BY 총매출 DESC;

-- 지역별 매출 분석
-- 지역, 주문건수, 총매출, 고객수, 고객당주문수, 고객당평균매출
SELECT * FROM sales;

SELECT
	region AS 지역,
	COUNT(*) AS 주문건수,
	SUM(total_amount) AS 총매출,
	COUNT(DISTINCT customer_id) AS 고객수,
	-- 정수 / 정수 -> 정수 But 실수 / 정수 -> 실수, 둘 중 하나만 실수로 바꿔주면 됨!
	ROUND(
		COUNT(*)::DECIMAL/COUNT(DISTINCT customer_id),0
	) AS 고객당평균주문수,
	ROUND(
		SUM(total_amount)::DECIMAL/COUNT(DISTINCT customer_id),0
	) AS 고객당평균매출
FROM sales
GROUP BY region
ORDER BY 고객당평균매출 DESC;


-- 영업사원별-지역별 성과
-- 영업사원, 지역, 주문건수, 총매출액, 지역월별성과
SELECT
	sales_rep AS 영업사원,
	region AS 지역,
	COUNT(*) AS 주문건수,
	SUM(total_amount) AS 총매출액
FROM sales
GROUP BY sales_rep, region
ORDER BY 총매출액 DESC;

-- 영업사원별 월별 매출 분석
-- 월, 사원, 주문건수, 월매출액, 평균매출액
-- 월, 월매출액 순으로 정렬
SELECT
	TO_CHAR(order_date, 'YYYY-MM') AS 월,
	sales_rep AS 사원,
	COUNT(*) AS 주문건수,
	SUM(total_amount) AS 월매출액,
	ROUND(AVG(total_amount),2) AS 평균매출액
FROM sales
GROUP BY sales_rep, 월
ORDER BY 월, 월매출액 DESC;

-- MAU(Monthly Active User) -> 월간활성고객
-- 월, 주문건수, 월매출액, MAU
SELECT
	TO_CHAR(order_date, 'YYYY-MM') AS 월,
	COUNT(*) AS 주문건수,
	SUM(total_amount) AS 월매출액,
	COUNT(DISTINCT customer_id) AS MAU
FROM sales
GROUP BY 월
ORDER BY 월;
	

-- 요일별 매출 패턴 (날짜->요일 함수?)
-- 요일, 주문건수, 총매출, 평균매출
SELECT
	TO_CHAR(order_date, 'Day') AS 요일,
	-- EXTRACT(DOW FROM order_date) AS 요일번호 0(일) ~ 6(토)
	COUNT(*) AS 주문건수,
	SUM(total_amount) AS 총매출액,
	SUM(total_amount)/COUNT(*) AS 평균매출
FROM sales
GROUP BY 요일
ORDER BY 총매출액 DESC;


