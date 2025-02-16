--SQL Advance Project

USE [db_SQLCaseStudies];

SELECT * FROM DIM_CUSTOMER AS C;
SELECT * FROM DIM_DATE AS D;
SELECT * FROM DIM_LOCATION AS L;
SELECT * FROM DIM_MANUFACTURER AS M;
SELECT * FROM DIM_MODEL AS M_;
SELECT * FROM FACT_TRANSACTIONS AS T;

---

SELECT TOP 1 * FROM DIM_CUSTOMER AS C;
SELECT TOP 1 * FROM DIM_DATE AS D;
SELECT TOP 1 * FROM DIM_LOCATION AS L;
SELECT TOP 1 * FROM DIM_MANUFACTURER AS M;
SELECT TOP 1 * FROM DIM_MODEL AS M_;
SELECT TOP 1 * FROM FACT_TRANSACTIONS AS T;

--Q1--BEGIN 
	
SELECT L.State, L. City, L.IDLocation, M_.IDModel, YEAR(F.Date) AS YEAR_  FROM DIM_LOCATION AS L
INNER JOIN FACT_TRANSACTIONS AS F
ON L.IDLocation = F.IDLocation
INNER JOIN DIM_MODEL AS M_
ON F.IDModel = M_.IDModel
WHERE YEAR(F.DATE) >= '2005';


--Q1--END


--Q2--BEGIN
	
SELECT TOP 1 L.State,L.Country, M.Manufacturer_Name,  SUM( T.Quantity) AS MAX_SELL FROM DIM_LOCATION AS L
INNER JOIN FACT_TRANSACTIONS AS T
ON L.IDLocation = T.IDLocation
INNER JOIN DIM_MODEL AS M_
ON T.IDModel = M_.IDModel
INNER JOIN DIM_MANUFACTURER AS M
ON M_.IDManufacturer = M.IDManufacturer
WHERE L.Country = 'US' AND  M.Manufacturer_Name = 'SAMSUNG'
GROUP BY L.State, L.Country, M.Manufacturer_Name
ORDER BY MAX_SELL DESC;

--Q2--END

--Q3--BEGIN

 SELECT L.ZipCode, L.State, T.Quantity, T.TotalPrice, M_.Model_Name, COUNT(T.IDCustomer) AS NO_TRNS FROM DIM_LOCATION AS L
 INNER JOIN FACT_TRANSACTIONS AS T
 ON L. IDLocation = T.IDLocation
 INNER JOIN DIM_MODEL AS M_
 ON T.IDModel = M_.IDModel
 GROUP BY L.ZipCode, L.State, T.Quantity, T.TotalPrice, M_.Model_Name
 ORDER BY NO_TRNS DESC;


--Q3--END

--Q4--BEGIN

SELECT  TOP 1 M.Manufacturer_Name, M_.Unit_price, M.IDManufacturer FROM DIM_MODEL AS M_
INNER JOIN DIM_MANUFACTURER AS M
ON M_.IDManufacturer = M.IDManufacturer
ORDER BY M_.Unit_price ASC;

--Q4--END

--Q5--BEGIN 

SELECT M_.Model_Name, AVG(M_.Unit_price) AS AVG_PRICE FROM DIM_MODEL AS M_
INNER JOIN DIM_MANUFACTURER AS M
ON M_.IDManufacturer = M.IDManufacturer
WHERE M.Manufacturer_Name IN 
                         (SELECT TOP 5 M.Manufacturer_Name FROM FACT_TRANSACTIONS AS T
                          INNER JOIN DIM_MODEL AS M_
                          ON T.IDModel = M_.IDModel
                          INNER JOIN DIM_MANUFACTURER AS M
                          ON M_.IDManufacturer = M.IDManufacturer
                          GROUP BY M.Manufacturer_Name
                          ORDER BY SUM(T.Quantity))
GROUP BY M_.MODEL_NAME
ORDER BY AVG_PRICE DESC;

--Q5--END

--Q6--BEGIN

SELECT C.Customer_Name, C.IDCustomer,
AVG(T.TotalPrice) AS AVG_PRICE, YEAR(T.DATE) AS YEAR_ FROM DIM_CUSTOMER AS C
INNER JOIN FACT_TRANSACTIONS AS T
ON C.IDCustomer = T.IDCustomer
WHERE YEAR(T.Date) = '2009'
GROUP BY C.IDCustomer, C.Customer_Name, T.Date
HAVING AVG(T.TotalPrice) > '500';

--Q6--END
	
--Q7--BEGIN

SELECT T1.Model_Name FROM
(SELECT TOP 5 M_.Model_Name, YEAR(T.Date) AS YEAR_, SUM(T.Quantity) AS SUM_QTY FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_MODEL AS M_
ON T.IDModel = M_.IDModel
WHERE YEAR(T.Date) = '2008' 
GROUP BY  M_.Model_Name,  YEAR(T.Date)
ORDER BY SUM_QTY DESC ) AS T1
INTERSECT
SELECT T2.Model_Name FROM (
SELECT TOP 5  M_.Model_Name, YEAR(T.Date) AS YEAR_, SUM(T.Quantity) AS SUM_QTY FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_MODEL AS M_
ON T.IDModel = M_.IDModel
WHERE YEAR(T.Date) = '2009' 
GROUP BY M_.Model_Name, YEAR(T.Date)
ORDER BY SUM_QTY DESC )  as T2
INTERSECT
SELECT T3.MODEL_NAME FROM (
SELECT TOP 5 M_.Model_Name, YEAR(T.Date) AS YEAR_, SUM(T.Quantity) AS SUM_QTY FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_MODEL AS M_
ON T.IDModel = M_.IDModel
WHERE YEAR(T.Date) = '2010' 
GROUP BY  M_.Model_Name, YEAR(T.Date)
ORDER BY SUM_QTY DESC) AS T3;

--Q7--END

--Q8--BEGIN

SELECT TOP 4 M.Manufacturer_Name, YEAR(T.Date)  AS YEAR_ ,SUM(T.Quantity) AS SUM_QTY FROM DIM_MANUFACTURER AS M
INNER JOIN DIM_MODEL AS M_
ON M.IDManufacturer = M_.IDManufacturer
INNER JOIN FACT_TRANSACTIONS AS T
ON M_.IDModel = T.IDModel
WHERE YEAR(T.Date ) IN ('2010' ,'2009')
GROUP BY M.Manufacturer_Name, YEAR(T.Date)
ORDER BY SUM_QTY DESC;

--Q8--END

--Q9--BEGIN
	
SELECT M.Manufacturer_Name, M_.Model_Name, YEAR(T.Date) AS YEAR_ FROM DIM_MANUFACTURER AS M
INNER JOIN DIM_MODEL AS M_
ON M.IDManufacturer = M_.IDManufacturer
INNER JOIN FACT_TRANSACTIONS AS T
ON M_.IDModel = T.IDModel
WHERE YEAR(T.DATE) = '2010' EXCEPT
SELECT M.Manufacturer_Name, M_.Model_Name, YEAR(T.Date) AS YEAR_ FROM DIM_MANUFACTURER AS M
INNER JOIN DIM_MODEL AS M_
ON M.IDManufacturer = M_.IDManufacturer
INNER JOIN FACT_TRANSACTIONS AS T
ON M_.IDModel = T.IDModel
WHERE YEAR(T.DATE) = '2009';

--Q9--END

--Q10--BEGIN

SELECT *,LAG(SUM_TOTAL_PRICE,1) OVER (PARTITION BY IDCUSTOMER ORDER BY YEAR_) AS PREVIOUS_TOTAL_PRICE
FROM(

    SELECT DISTINCT YEAR(T.DATE) AS YEAR_, T.IDCustomer, 
    AVG(T.TotalPrice) OVER (PARTITION BY T.IDCUSTOMER ORDER BY YEAR(T.DATE)) AS AVG_SPEND,
    AVG(T.QUANTITY) OVER (PARTITION BY T.IDCUSTOMER ORDER BY YEAR(T.DATE)) AS AVG_QUANTITY,
    AVG(T.TotalPrice) OVER (PARTITION BY T.IDCUSTOMER ORDER BY YEAR(T.DATE)) AS SUM_TOTAL_PRICE
    FROM FACT_TRANSACTIONS AS T
    INNER JOIN DIM_CUSTOMER AS C
    ON T.IDCustomer = C.IDCustomer
     WHERE T.IDCustomer IN (SELECT TOP 10 T.IDCustomer FROM FACT_TRANSACTIONS AS T 
                        GROUP BY T.IDCustomer
						ORDER BY SUM(T.TotalPrice) DESC)
					) AS T1;
					
--Q10--END
	