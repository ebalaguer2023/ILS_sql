USE IowaLiquorSales

SELECT TOP 1000 FROM ILS20222024

select count(*) from ILS
WHERE YEAR(ILS.[Date])=2015
LEFT OUTER JOIN Items ON ITEMS.IdItem = ILS.IdItem
WHERE Items.[Item Description] like 'CAZADORES BLANCO' and YEAR(ILS.[Date])=2023

select * from ILS
left outer JOIN Items ON ITEMS.IdItem = ILS.IdItem
where Items.iditem is null



SELECT DISTINCT City FROM Stores WHERE IdStore IN
(SELECT IdStore FROM ILS where YEAR(date) =2023 AND [Bottles Sold]>0)
AND City IS NOT NULL
ORDER BY City 
----------------------
CREATE PROCEDURE Sales_by_city @City nvarchar(50) AS

SELECT [Invoice Item Description], Date, i.IdItem, c.[Category Name],cg.[Category group],IdVendor, IdStore, Pack, [Bottle Volume (ml)], [State Bottle Cost], [State Bottle Retail], [Bottles Sold], [Sale (Dollars)], [Volume Sold (Liters)], [Volume Sold (Gallons)]
FROM     ILS
INNER JOIN Items I ON I.IdItem=ILS.IdItem
LEFT JOIN Categories c ON c.IdCategory=I.IdCategory
LEFT JOIN CategoryGroups CG ON CG.IdCatGroup=c.IdCatGroup
WHERE  (YEAR(Date) = 2023) AND (IdStore IN
                      (SELECT IdStore
                       FROM      Stores
                       WHERE   (City LIKE @City)))
------------------------------


EXEC CITYTOP5STORES 'SIOUX CITY'

SELECT COUNT(Distinct ILS.IdStore) 
	FROM ILS INNER JOIN Stores 
	ON Stores.IdStore=ILS.IdStore AND City like 'SIOUX CITY'
	WHERE YEAR(date) =2023 


----------CASEYS STORES UNDER THE AVERAGE SALES
WITH AVERAGE_BOTTLES_SOLD_CASEYS AS (
	SELECT DISTINCT AVG([Bottles Sold]) OVER () AS AVG_CASEYS_2023 
		FROM ILS INNER JOIN Stores AS s 
		ON s.[IdStore] = ILS.[IdStore]
		AND s.[Store Name] LIKE 'CASEY%' 
		WHERE year([Date])=2023
)

SELECT DISTINCT  s.[IdStore], [Store Name], 
AVG([Bottles Sold]) AS average_bottles_sold_store
	FROM ILS INNER JOIN Stores AS s ON s.[IdStore] = ILS.[IdStore] 
	AND s.[Store Name] LIKE 'CASEY%' 
	AND YEAR(ILS.[DATE])=2023
	GROUP BY s.[IdStore], [Store Name]
	HAVING AVG([Bottles Sold]) < (SELECT AVG_CASEYS_2023 FROM AVERAGE_BOTTLES_SOLD_CASEYS)



SELECT *
FROM information_schema.columns

select count(*) from ILS

SELECT table_name, 
       STRING_AGG(column_name, ', ') AS columns
FROM information_schema.columns
WHERE table_schema = 'dbo'
GROUP BY table_name;

SELECT * FROM ILS
-------------------POWERBI VIEWS
CREATE VIEW POWERBI AS
SELECT [Invoice Item Description], YEAR([Date]) AS [YEAR], MONTH([Date]) AS MONTH, IdItem, IdVendor, IdStore, Pack, [Bottle Volume (ml)], [State Bottle Cost], [State Bottle Retail], [Bottles Sold], [Sale (Dollars)], [Volume Sold (Liters)], [Volume Sold (Gallons)]
FROM     ILS
WHERE  YEAR([Date]) BETWEEN 2015 AND 2024
--------------------

select substring([store location],8,9) as latitude, substring([Store Location],patindex('% [0-9]%',[Store Location]),8) as longitude, [Store Location] from iowaliquorsales.dbo.stores

select * from [Stores] where city like 'humboldt'

SELECT * FROM [Stores] WHERE LATITUDE LIKE '%43.4538%'

SELECT * FROM ILS WHERE [Bottles Sold]<0
------------------CREA VISTA ILS CON DETALLES COMPLETOS
CREATE VIEW CONSULTA AS 
SELECT        [Invoice Item Description], DATE, 
REPLACE(REPLACE([Store Name],char(39),''),',',' ') AS 'Store Name', 
[LATITUDE], [LONGITUDE], REPLACE([City], char(39), '') AS 'City', [Category group],
REPLACE([Category Name],char(39),'') AS 'Category Name', 
REPLACE(REPLACE([Vendor Name],char(39),''),',','') AS 'Vendor Name', 
REPLACE(REPLACE([Item Description],char(39),''),',','') AS 'Item Description', 
Pack, [Bottle Volume (ml)], [State Bottle Cost], [State Bottle Retail], 
[Bottles Sold], [Sale (Dollars)], [Volume Sold (Liters)], [Volume Sold (Gallons)]

FROM            IowaLiquorSales.dbo.ILS
LEFT OUTER JOIN IowaLiquorSales.dbo.[Stores] AS Stores on Stores.[IdStore] = ILS.[IdStore]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Vendors] AS Vendors on Vendors.[IdVendor] = ILS.[IdVendor]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Items] AS Items on Items.[IdItem] = ILS.[IdItem]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Categories] AS Categories on Categories.[IdCategory] = Items.[IdCategory]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[CategoryGroups] AS CategoryGroups on CategoryGroups.[IdCatGroup]=Categories.[IdCatGroup]
WHERE YEAR([Date]) BETWEEN 2022 AND 2024
--------------VERIFYING MAX SIZE OF SOME VARCHAR VALUES
SELECT MAX(LEN([City])) from ILS_REFERENCE_TABLES.dbo.Stores
--name 45
--address 30
--ZipCode 5LEFT OUTER JOIN IowaLiquorSales.dbo.[Stores] AS Stores on Stores.[IdStore] = ILS.[IdStore]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Vendors] AS Vendors on Vendors.[IdVendor] = ILS.[IdVendor]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Items] AS Items on Items.[IdItem] = ILS.[IdItem]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Categories] AS Categories on Categories.[IdCategory] = Items.[IdCategory]--store location 45
--City 

SELECT * FROM CategoryGroups

--STATISTICS. 1. SUM PER CATEGORY
SELECT        [Category Group], CAST(count([Invoice Item Description]) AS bigint),
CAST (SUM(Pack) AS bigint) AS 'Total Packs', SUM([Bottle Volume (ml)]) AS 'Total Bottle Volume(ml)', 
CAST(SUM([State Bottle Cost])  AS NUMERIC) AS 'Total Cost', CAST(SUM([State Bottle Retail]) AS NUMERIC) AS 'Total Retail', 
CAST(SUM([Bottles Sold]) AS bigint) AS [BOTTLES SOLD], SUM([Sale (Dollars)]) AS [TOTAL SALE (Dollars)], 
SUM([Volume Sold (Liters)]) AS 'Total Volume Sold (Lts)', SUM([Volume Sold (Gallons)]) AS 'Total Volume Sold (Gal)'
FROM            IowaLiquorSales.dbo.ILS
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Items] AS Items on Items.[IdItem] = ILS.[IdItem]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Categories] AS Categories on Categories.[IdCategory] = Items.[IdCategory]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[CategoryGroups] AS CategoryGroups on CategoryGroups.[IdCatGroup]=Categories.[IdCatGroup]
WHERE YEAR([Date]) =2015
GROUP BY [Category group]


 USE IowaLiquorSales
CREATE VIEW ILS20152024 AS
SELECT YEAR([Date]) AS [YEAR],MONTH([Date]) AS [MONTH],ILS.[IdItem],ILS.[IdVendor], ILS.[IdStore],
CAST(count([Invoice Item Description]) AS bigint) AS [SALES],
CAST (SUM(Pack) AS bigint) AS 'Total Packs', SUM([Bottle Volume (ml)]) AS 'Total Bottle Volume(ml)', 
CAST(SUM([State Bottle Cost])  AS NUMERIC) AS 'Total Cost', CAST(SUM([State Bottle Retail]) AS NUMERIC) AS 'Total Retail', 
CAST(SUM([Bottles Sold]) AS bigint) AS [BOTTLES SOLD], SUM([Sale (Dollars)]) AS [TOTAL SALE (Dollars)], 
SUM([Volume Sold (Liters)]) AS 'Total Volume Sold (Lts)', SUM([Volume Sold (Gallons)]) AS 'Total Volume Sold (Gal)'
FROM            IowaLiquorSales.dbo.ILS
LEFT OUTER JOIN IowaLiquorSales.dbo.[Stores] AS Stores on Stores.[IdStore] = ILS.[IdStore]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Vendors] AS V on V.[IdVendor] = ILS.[IdVendor]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Items] AS Items on Items.[IdItem] = ILS.[IdItem]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Categories] AS Categories on Categories.[IdCategory] = Items.[IdCategory]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[CategoryGroups] AS CategoryGroups on CategoryGroups.[IdCatGroup]=Categories.[IdCatGroup]
WHERE YEAR([Date]) BETWEEN 2015 AND 2024
GROUP BY YEAR([Date]),MONTH([Date]),ILS.[IdItem],ILS.[IdVendor], ILS.[IdStore]

SELECT TOP 1000 * FROM ILS20152024
WHERE [YEAR]=2024

/*
SELECT
YEAR([Date]) AS [YEAR], MONTH([Date]) AS [MONTH], CAST(SUM([Bottles Sold]) AS numeric) AS [BOTTLES SOLD], SUM([Sale (Dollars)]) AS [TOTAL SALE (Dollars)], 
SUM([Volume Sold (Liters)]) AS 'Total Volume Sold (Lts)', SUM([Volume Sold (Gallons]) AS 'Total Volume Sold (Gal)'
FROM ILS_REFERENCE_TABLES.dbo.ILS  
GROUP BY [YEAR],[MONTH]

*/
select * from items with (nolock)

Use IowaLiquorSales
select count(distinct [Item Number]) from ILS_TEMP
select count(distinct [Vendor Number]) from ILS_TEMP
select count(distinct [Category]) from ILS_TEMP
select count(distinct [Store Number]) from ILS_TEMP

-------------------
use IowaLiquorSales
-----------------
with toplist (IdVendor, [Bottles Sold]) as (select TOP 5 V.IdVendor,sum([Bottles Sold])
	from ILS
	LEFT OUTER JOIN IowaLiquorSales.[dbo].[Vendors] AS V on V.[IdVendor] = ILS.[IdVendor]
	LEFT OUTER JOIN IowaLiquorSales.[dbo].[Items] AS I on I.[IdItem] = ILS.[IdItem]
	LEFT OUTER JOIN IowaLiquorSales.[dbo].[Categories] AS C on C.[IdCategory] = I.[IdCategory]
	LEFT OUTER JOIN IowaLiquorSales.[dbo].[CategoryGroups] AS CG on CG.[IdCatGroup]=C.[IdCatGroup]
	WHERE YEAR([Date]) =2023
	GROUP BY V.IdVendor
	ORDER BY sum([Bottles Sold]) DESC
) 

SELECT coalesce(V.[Vendor Name],'All stores') AS 'Vendor', 
coalesce(CG.[Category Group], 'All categories') AS 'Category', 
Sum(ILS.[Bottles Sold]) AS 'Bottles Sold 2023' 
FROM toplist           
LEFT OUTER JOIN IowaLiquorSales.dbo.ILS on ILS.IdVendor=toplist.IdVendor
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Vendors] AS V on V.[IdVendor] = ILS.[IdVendor]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Items] AS I on I.[IdItem] = ILS.[IdItem]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Categories] AS C on C.[IdCategory] = I.[IdCategory]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[CategoryGroups] AS CG on CG.[IdCatGroup]=C.[IdCatGroup]
WHERE YEAR([Date]) =2023 
GROUP BY CUBE (CG.[Category Group],V.[Vendor Name])
ORDER BY [Vendor Name],Sum(ILS.[Bottles Sold])



CREATE PROCEDURE CITYTOP5STORES @city varchar(50)
AS
WITH toplistStore (IdStore, [Bottles Sold]) as (select TOP 5 S.IdStore,sum([Bottles Sold])
	from ILS
	LEFT OUTER JOIN IowaLiquorSales.[dbo].[Stores] AS S on S.[IdStore] = ILS.[IdStore]
	LEFT OUTER JOIN IowaLiquorSales.[dbo].[Items] AS I on I.[IdItem] = ILS.[IdItem]
	LEFT OUTER JOIN IowaLiquorSales.[dbo].[Categories] AS C on C.[IdCategory] = I.[IdCategory]
	LEFT OUTER JOIN IowaLiquorSales.[dbo].[CategoryGroups] AS CG on CG.[IdCatGroup]=C.[IdCatGroup]
	WHERE YEAR([Date]) =2023 --AND [Store Name] IS NOT NULL
	GROUP BY S.IdStore
	ORDER BY sum([Bottles Sold]) DESC
) 

SELECT coalesce(CONCAT(S.[Store Name],' Store ID: ',S.[IdStore]),'All stores') AS 'Store', 
coalesce(CG.[Category Group], 'All categories') AS 'Category', 
SUM(ILS.[Bottles Sold]) AS 'Bottles Sold 2023' 
FROM toplistStore           
LEFT OUTER JOIN IowaLiquorSales.dbo.ILS on ILS.IdStore=toplistStore.IdStore
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Stores] AS S on S.[IdStore] = ILS.[IdStore]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Items] AS I on I.[IdItem] = ILS.[IdItem]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[Categories] AS C on C.[IdCategory] = I.[IdCategory]
LEFT OUTER JOIN IowaLiquorSales.[dbo].[CategoryGroups] AS CG on CG.[IdCatGroup]=C.[IdCatGroup]
WHERE YEAR([Date]) =2023 and City=@city
GROUP BY CUBE (CONCAT(S.[Store Name],' Store ID: ',S.[IdStore]), CG.[Category Group])
ORDER BY CONCAT(S.[Store Name],' Store ID: ',S.[IdStore]),SUM(ILS.[Bottles Sold])

 select distinct city from stores order by city 

 EXEC CITYTOP5STORES 'SIOUX CITY'

 -------------MoM growth rate KPI Bottles Sold monthly by Store
CREATE PROCEDURE MoMStore @StoreName varchar(100)
AS

 SELECT MONTH([Date]) AS [MONTH],ILS.[IdStore], [Store Name], 
 
 SUM([Bottles Sold]) 'Bottles sold of the month', 
 
 LAG(SUM([Bottles Sold]), 1) OVER (PARTITION BY ILS.[IdStore] ORDER BY MONTH([Date])) AS 'Previous month bottles sold',
 
 
 ROUND((CAST(SUM([Bottles Sold]) AS FLOAT)/
 CAST(LAG(SUM([Bottles Sold]), 1) OVER (PARTITION BY ILS.[IdStore] ORDER BY MONTH([Date])) AS FLOAT)-1),2) AS 'Month on Month Variation'
 
 
 FROM ILS
  INNER JOIN Stores AS s ON s.[IdStore] = ILS.IdStore
 WHERE YEAR([Date])=2013 and [Store Name] LIKE @StoreName 
 GROUP BY MONTH([Date]), ILS.[IdStore], [Store Name]
 ORDER BY [IdStore], [Store Name], MONTH([Date])

 ---------------------------------------
 EXEC MoMStore 'HOMETOWN FOODS / TRAER'
----------------------------------------

CREATE VIEW MoMStoreView_OLD AS

  SELECT MONTH([Date]) AS [MONTH],ILS.[IdStore], [Store Name], 
 
 SUM([Bottles Sold]) 'Bottles sold of the month', 
 
 COALESCE(LAG(SUM([Bottles Sold]), 1) OVER (PARTITION BY ILS.[IdStore] ORDER BY MONTH([Date])),'') AS 'Previous month bottles sold',
 
 COALESCE(
 ROUND((CAST(SUM([Bottles Sold]) AS FLOAT)/
 CAST(LAG(SUM([Bottles Sold]), 1) OVER (PARTITION BY ILS.[IdStore] ORDER BY MONTH([Date])) AS FLOAT)-1),2) 
 ,'') AS 'Month on Month Variation'
 
 FROM ILS
  INNER JOIN Stores AS s ON s.[IdStore] = ILS.IdStore  WHERE YEAR([Date])=2013  
 GROUP BY MONTH([Date]), ILS.[IdStore], [Store Name]

-------------------------
CREATE VIEW MoMStoreView AS
WITH MonthlySales AS (
    SELECT 
        MONTH([Date]) AS [MONTH],
        ILS.[IdStore],
        s.[Store Name],
        SUM([Bottles Sold]) AS [Bottles sold of the month]
    FROM ILS
    INNER JOIN Stores AS s ON s.[IdStore] = ILS.IdStore  
    WHERE YEAR([Date]) = 2013  
    GROUP BY MONTH([Date]), ILS.[IdStore], s.[Store Name]
)

SELECT 
    [MONTH],
    [IdStore],
    [Store Name],
    [Bottles sold of the month],
    LAG([Bottles sold of the month], 1) OVER (PARTITION BY [IdStore] ORDER BY [MONTH]) AS [Previous month bottles sold],
	CAST(
	  ROUND(
		(CAST([Bottles sold of the month] AS FLOAT) / 
		 NULLIF(CAST(LAG([Bottles sold of the month], 1) OVER (PARTITION BY [IdStore] ORDER BY [MONTH]) AS FLOAT), 0) - 1),
		2
	  ) AS FLOAT
	) AS [Month on Month Variation]
	FROM MonthlySales;

-------------------------
SELECT * FROM MoMStoreView where IdStore=3547;
SELECT * FROM MoMStoreView_OLD where IdStore=3547;

select top 1000 * from ils where IdStore=3547;

-------------------------
CREATE PROCEDURE AvgCityStores @City varchar(100)
AS

WITH AVGsales ([Month], AVGsales) AS (
SELECT MONTH([Date]),AVG([Bottles Sold]) AS AVG_Bottles_Sold_Month_City
FROM ILS
  INNER JOIN Stores AS s ON s.[IdStore] = ILS.IdStore
  WHERE YEAR([Date])=2013 AND [City] LIKE @City
  GROUP BY MONTH([Date])
)

 
SELECT MONTH([Date]),[Store Name], AVG([Bottles Sold]) 'Average bottles sold month', a.AVGsales 
  FROM ILS
  INNER JOIN Stores AS s ON s.[IdStore] = ILS.IdStore
  INNER JOIN AVGsales AS a ON a.[Month] = MONTH(ILS.[Date])
  WHERE YEAR([Date])=2013 AND [City] LIKE @City 
  GROUP BY MONTH([Date]), AvgSales, [Store Name], [City]
  HAVING AVG([Bottles Sold]) < AVGsales
  ORDER BY [Store Name], MONTH([Date])

EXEC AvgCityStores  'DES MOINES'
-------------ESTADÍSTICOS GENERALES

SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [Bottles Sold]) OVER () AS MEDIAN
FROM ILS
WHERE YEAR([Date])=2013

SELECT
AVG([Bottles Sold]) AS AVG_BOTTLES_SOLD, 
STDEV([Bottles Sold]) AS STD_BOTTLES_SOLD, 
MIN([Bottles Sold]) AS MIN_BOTTLES_SOLD, 
MAX([Bottles Sold]) AS MAX_BOTTLES_SOLD,
SUM([Bottles Sold]) AS SUM_BOTTLES_SOLD
FROM ILS
WHERE YEAR([Date])=2013


-------------ESTADÍSTICOS AGRUPADOS
SELECT DISTINCT 
cg.[Category group],
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [Bottles Sold]) OVER (PARTITION BY [Category Group]) AS MEDIAN
FROM ILS
INNER JOIN ITEMS AS i ON i.IdItem=ILS.IdItem
INNER JOIN Categories AS c ON c.IdCategory=I.IdCategory
INNER JOIN CategoryGroups AS cg ON cg.IdCatGroup=c.IdCatGroup
WHERE YEAR([Date])=2013
GROUP BY cg.[Category group], [Bottles Sold]


USE IowaLiquorSales
SELECT 
cg.[Category group],
AVG([Bottles Sold]) AS AVG_BOTTLES_SOLD, 
STDEV([Bottles Sold]) AS STD_BOTTLES_SOLD, 
MIN([Bottles Sold]) AS MIN_BOTTLES_SOLD, 
MAX([Bottles Sold]) AS MAX_BOTTLES_SOLD,
SUM([Bottles Sold]) AS SUM_BOTTLES_SOLD
FROM ILS
LEFT OUTER JOIN ITEMS AS i ON i.IdItem=ILS.IdItem
LEFT OUTER JOIN Categories AS c ON c.IdCategory=I.IdCategory
LEFT OUTER JOIN CategoryGroups AS cg ON cg.IdCatGroup=c.IdCatGroup
WHERE YEAR([Date])=2023
GROUP BY cg.[Category group]

SELECT 
(Avg(ILS.[State Bottle Retail] * ILS.[Sale (Dollars)]) - (Avg(ILS.[State Bottle Retail]) * Avg(ILS.[Sale (Dollars)])))
/ (StDevP(ILS.[State Bottle Retail]) * StDevP(ILS.[Sale (Dollars)]))
FROM ILS WHERE YEAR([Date])=2013


SELECT  
        -- For Population
        (avg([State Bottle Retail] * [Sale (Dollars)]) - avg([State Bottle Retail]) * avg([Sale (Dollars)])) / 
        (sqrt(avg([State Bottle Retail] * [State Bottle Retail]) - avg([State Bottle Retail]) * avg([State Bottle Retail])) * sqrt(avg([Sale (Dollars)] * [Sale (Dollars)]) - avg([Sale (Dollars)]) * avg([Sale (Dollars)]))) 
        AS correlation_coefficient_population,
        -- For Sample
        (count(*) * sum([State Bottle Retail] * [Sale (Dollars)]) - sum([State Bottle Retail]) * sum([Sale (Dollars)])) / 
        (sqrt(count(*) * sum([State Bottle Retail] * [State Bottle Retail]) - sum([State Bottle Retail]) * sum([State Bottle Retail])) * sqrt(count(*) * sum([Sale (Dollars)] * [Sale (Dollars)]) - sum([Sale (Dollars)]) * sum([Sale (Dollars)]))) 
        AS correlation_coefficient_sample
    FROM 
	ILS WHERE YEAR([Date])=2013

	--SOURCE:https://stackoverflow.com/questions/6933784/is-there-a-way-to-calculate-correlation-in-tsql-using-over-clauses-instead-of-ct



USE IowaLiquorSales
SELECT YEAR([Date]) AS [YEAR], CG.[Category group] , I.[Item Description],
HASGIFT,
ROUND(SUM([Bottles Sold]),2) as 'SUM BOTTLES SOLD', 
ROUND(SUM([Sale (Dollars)]),2) AS 'SUM SALE (Dollars)', 
ROUND(SUM([Volume Sold (Liters)]),2) AS 'SUM Volume Sold (Liters)'
INTO ILS20212023
FROM     ILS
LEFT OUTER JOIN IowaLiquorSales.dbo.Items AS I ON I.IdItem = ILS.[IdItem]
LEFT OUTER JOIN IowaLiquorSales.dbo.Categories AS C ON C.IdCategory = I.[IdCategory]
LEFT OUTER JOIN IowaLiquorSales.dbo.CategoryGroups AS CG ON CG.IdCatGroup = C.[IdCatGroup]
WHERE  YEAR([Date]) BETWEEN 2021 AND 2023
GROUP BY YEAR([Date]), [Category group] , I.[Item Description],HASGIFT
ORDER BY YEAR([Date]), [Category group] , I.[Item Description],HASGIFT
DROP TABLE ILS20212023
SELECT * FROM IowaLiquorSales.DBO.ITEMS
WHERE [Item Description] LIKE '%W/%'


UPDATE IowaLiquorSales.DBO.ITEMS 
SET [HASGIFT] = 1
WHERE [Item Description] LIKE '% W/%'



SELECT A.[City],SUM(A.[Volume Sold (Liters)]) 
FROM IowaLiquorSales_TEST.dbo.ILS20152024 A
GROUP BY [City] ORDER BY  SUM(A.[Volume Sold (Liters)]) DESC


UPDATE  IowaLiquorSales.dbo.Stores 
SET [City] = SUBSTRING([Store Name], PATINDEX('%/%', [Store Name]) + 1, LEN([Store Name]))
WHERE [City] IS NULL 
  AND [Store Name] IS NOT NULL 
  AND [Store Name] LIKE '%/%'

SELECT [Store Name], SUBSTRING([Store Name],PATINDEX('/',[Store Name]),LEN([Store Name])) 
FROM IowaLiquorSales.dbo.Stores A
WHERE [City] is null and [Store Name] is not null and [Store Name] LIKE '%/%'

SELECT MIN([DATE]), MAX([DATE])
FROM IowaLiquorSales.dbo.ILS A
--WHERE [Store Name] LIKE 'CASEY%3009%'

EXEC IowaLiquorSales.DBO.MoMStore 'CASEY%3009%'

SELECT TOP 1000 * FROM MoMStoreView

SELECT 
  COLUMN_NAME, 
  DATA_TYPE, 
  CHARACTER_MAXIMUM_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'MoMStoreView';
