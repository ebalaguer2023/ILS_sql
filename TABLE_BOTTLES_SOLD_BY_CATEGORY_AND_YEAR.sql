EXEC BOTTLES_SOLD_CATEGORY_YEAR;
EXEC DROP_TABLES_TEMP_FOR_SUMMARY;
DROP TABLE SUMMARY_BOTTLES_SOLD_CATEGORY_YEAR
----
ALTER PROCEDURE BOTTLES_SOLD_CATEGORY_YEAR AS

declare @sql nvarchar(max)=''
declare @cat integer=1;
declare @catname varchar(30)=''

WHILE @CAT<11
	BEGIN
		SELECT @catname = [Category group] FROM IowaLiquorSales.dbo.CategoryGroups WHERE IdCatGroup = @cat;

		SET @sql = @sql+ 'select  year([Date]) as [Year], round(sum(ILS.[Bottles Sold]),2) as '''+@catname+''''
		SET @sql = @sql+ ' INTO '+@catname
		SET @sql = @sql+ ' from IowaLiquorSales.dbo.ILS '
		SET @sql = @sql+ 'LEFT OUTER JOIN IowaLiquorSales.[dbo].[Items] AS Items on Items.[IdItem] = ILS.[IdItem]'
		SET @sql = @sql+ 'LEFT OUTER JOIN IowaLiquorSales.[dbo].[Categories] AS Categories on Categories.[IdCategory] = Items.[IdCategory] '
		SET @sql = @sql+ 'LEFT OUTER JOIN IowaLiquorSales.[dbo].[CategoryGroups] AS CategoryGroups on CategoryGroups.[IdCatGroup]=Categories.[IdCatGroup] '
		SET @sql = @sql+ 'where year([Date]) between 2015 and 2024 and CategoryGroups.IdCatGroup='+cast(@cat AS VARCHAR(2))
		SET @sql = @sql+ ' group by CategoryGroups.IdCatGroup,CategoryGroups.[Category group],year([Date]) '
		SET @sql = @sql+ ' order by CategoryGroups.[Category group],year([Date]);';
		SET @cat = @cat + 1
	END

EXECUTE sp_executesql @SQL;

SELECT WHISKEY.[YEAR], WHISKEY, VODKA, BRANDIE, COCKTAILS, GIN, LIQUEUR, RUM, SCHNAPPS, TEQUILA, OTHERS
INTO SUMMARY_BOTTLES_SOLD_CATEGORY_YEAR
FROM     WHISKEY
LEFT JOIN VODKA ON VODKA.[YEAR]=WHISKEY.[YEAR] 
LEFT JOIN BRANDIE ON BRANDIE.[YEAR]=WHISKEY.[YEAR] 
LEFT JOIN COCKTAILS ON COCKTAILS.[YEAR]=WHISKEY.[YEAR] 
LEFT JOIN GIN ON GIN.[YEAR]=WHISKEY.[YEAR] 
LEFT JOIN LIQUEUR ON LIQUEUR.[YEAR]=WHISKEY.[YEAR] 
LEFT JOIN RUM ON RUM.[YEAR]=WHISKEY.[YEAR] 
LEFT JOIN SCHNAPPS ON SCHNAPPS.[YEAR]=WHISKEY.[YEAR] 
LEFT JOIN TEQUILA ON TEQUILA.[YEAR]=WHISKEY.[YEAR] 
LEFT JOIN OTHERS ON OTHERS.[YEAR]=WHISKEY.[YEAR] 
ORDER BY WHISKEY.[YEAR]

SELECT * FROM SUMMARY_BOTTLES_SOLD_CATEGORY_YEAR
ORDER BY [YEAR]


-----------------------------------------
CREATE PROCEDURE DROP_TABLES_TEMP_FOR_SUMMARY AS
--DROP THE TABLES
DECLARE @sql NVARCHAR(MAX)=''
DECLARE @cat INT = 1;
DECLARE @catname VARCHAR(30)='';
WHILE @CAT<11
	BEGIN
		SELECT @catname = [Category group] FROM IowaLiquorSales.dbo.CategoryGroups WHERE IdCatGroup = @cat;

		SET @sql = @sql+ 'DROP TABLE '+@catname+'; '
		SET @cat = @cat + 1
	END
EXECUTE sp_executesql @SQL;

-------------------------------------

--EXTENDED TO MONTHS

CREATE PROCEDURE BOTTLES_SOLD_SUMMARY_BOTTLES_SOLD_CATEGORY_YEAR_MONTH AS

declare @sql nvarchar(max)=''
declare @cat integer=1;
declare @catname varchar(30)=''

WHILE @CAT<11
	BEGIN
		SELECT @catname = [Category group] FROM IowaLiquorSales.dbo.CategoryGroups WHERE IdCatGroup = @cat;

		SET @sql = @sql+ 'select  year([Date]) as [Year], month([Date]) as [Month], round(sum(ILS.[Bottles Sold]),2) as '''+@catname+''''
		SET @sql = @sql+ ' INTO '+@catname
		SET @sql = @sql+ ' from IowaLiquorSales.dbo.ILS '
		SET @sql = @sql+ 'LEFT OUTER JOIN IowaLiquorSales.[dbo].[Items] AS Items on Items.[IdItem] = ILS.[IdItem]'
		SET @sql = @sql+ 'LEFT OUTER JOIN IowaLiquorSales.[dbo].[Categories] AS Categories on Categories.[IdCategory] = Items.[IdCategory] '
		SET @sql = @sql+ 'LEFT OUTER JOIN IowaLiquorSales.[dbo].[CategoryGroups] AS CategoryGroups on CategoryGroups.[IdCatGroup]=Categories.[IdCatGroup] '
		SET @sql = @sql+ 'where year([Date]) between 2015 and 2024 and CategoryGroups.IdCatGroup='+cast(@cat AS VARCHAR(2))
		SET @sql = @sql+ ' group by CategoryGroups.IdCatGroup,CategoryGroups.[Category group],year([Date]),month([Date]) '
		SET @sql = @sql+ ' order by CategoryGroups.[Category group],year([Date]),month([Date]);';
		SET @cat = @cat + 1
	END
EXECUTE sp_executesql @SQL;

SELECT WHISKEY.[YEAR], WHISKEY.[Month],WHISKEY, VODKA, BRANDIE, COCKTAILS, GIN, LIQUEUR, RUM, SCHNAPPS, TEQUILA, OTHERS
INTO SUMMARY_BOTTLES_SOLD_YM
FROM     WHISKEY
LEFT JOIN VODKA ON VODKA.[YEAR] = WHISKEY.[YEAR] and VODKA.[Month] = WHISKEY.[Month]
LEFT JOIN BRANDIE ON BRANDIE.[YEAR]=WHISKEY.[YEAR] and BRANDIE.[Month] = WHISKEY.[Month]
LEFT JOIN COCKTAILS ON COCKTAILS.[YEAR]=WHISKEY.[YEAR] and COCKTAILS.[Month] = WHISKEY.[Month]
LEFT JOIN GIN ON GIN.[YEAR]=WHISKEY.[YEAR] and GIN.[Month] = WHISKEY.[Month] 
LEFT JOIN LIQUEUR ON LIQUEUR.[YEAR]=WHISKEY.[YEAR] and LIQUEUR.[Month] = WHISKEY.[Month] 
LEFT JOIN RUM ON RUM.[YEAR]=WHISKEY.[YEAR] and RUM.[Month] = WHISKEY.[Month]
LEFT JOIN SCHNAPPS ON SCHNAPPS.[YEAR]=WHISKEY.[YEAR] and SCHNAPPS.[Month] = WHISKEY.[Month]
LEFT JOIN TEQUILA ON TEQUILA.[YEAR]=WHISKEY.[YEAR] and TEQUILA.[Month] = WHISKEY.[Month]
LEFT JOIN OTHERS ON OTHERS.[YEAR]=WHISKEY.[YEAR] and OTHERS.[Month] = WHISKEY.[Month]
ORDER BY WHISKEY.[YEAR], WHISKEY.[Month]


SELECT * FROM SUMMARY_BOTTLES_SOLD_YM 
ORDER BY [YEAR],[Month]


