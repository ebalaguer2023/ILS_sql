

--First we load the dataset on a temporary table (we name it ILS_TEMP) on a database that is also temporary
--(We are going to name the temporary database "IowaLiquorSales_REF")
--From this table we will build the reference table on the definitive database
--And finally our main table that will be normalized with foreign keys to the reference tables
--We will use different databases due to the limits in SQL Express, but maybe it´s not bad idea
--keeping separated the temporary tables (that it is one in this case) in a different database so we can drop them all once we are sure 
--we will no longer use them (but we have got to be sure)

USE master;
GO


--Later we can improve the next 'Drop' statement checking before that the database doesn' t exist
--And even better if we create a function to do that check, because maybe we will use it with the main database too
--(or even with other databases of other projects)
IF EXISTS (
        SELECT *
        FROM sys.databases
        WHERE name = 'IowaLiquorSales_REF'
        )
BEGIN
    DROP DATABASE IowaLiquorSales_REF 
END
GO

BEGIN
	CREATE DATABASE IowaLiquorSales_REF ON
	(NAME = IowaLiquorSales_REF_dat,
		FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\IowaLiquorSales_REF.mdf',
		SIZE = 136 MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 64 MB)
	LOG ON
	(NAME = Sales_log,
		FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\IowaLiquorSales_REF.ldf',
		SIZE = 8 MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 64 MB);
END
GO

BEGIN
	create table IowaLiquorSales_REF.dbo.ILS_TEMP
		([Invoice Item Description] varchar(50), [Date] varchar(50), [Store Number] varchar(50), [Store Name] varchar(100),
		[Address] varchar(100), [City] varchar(100), [Zip Code] varchar(100), [Store Location] varchar(100),
		[County Number] varchar(100), [County] varchar(100), [Category] varchar(100), [Category Name] varchar(100),
		[Vendor Number] varchar(100), [Vendor Name] varchar(100), [Item Number] varchar(100), [Item Description] varchar(100),
		[Pack] varchar(100), [Bottle Volume (ml)] varchar(100), [State Bottle Cost] varchar(100), [State Bottle Retail] varchar(100),
		[Bottles Sold] varchar(100), [Sale (Dollars)] varchar(100), [Volume Sold (Liters)] varchar(100), [Volume Sold (Gallons] varchar(100));
		
	BULK INSERT IowaLiquorSales_REF.dbo.ILS_TEMP
		FROM 'C:\Users\emili\Downloads\Iowa_Liquor_Sales_20250417.csv'
		WITH (FIRSTROW=2, ROWTERMINATOR = '0x0a', FORMAT='CSV', MAXERRORS=10000, FIELDQUOTE='"')

--(30305765 rows affected)

	--SELECT * FROM IowaLiquorSales_REF.dbo.ILS_TEMP WHERE [ITEM NUMBER] = 'x904631' --Making the items rererence table I found that this number throws error if I want to treat this field as a numeric type
	--SELECT * FROM IowaLiquorSales_REF.dbo.ILS_TEMP WHERE [ITEM Description] like 'TANQUERAY GIN MINI - USE 904631 CODE'--I verified that this is only value that causes trouble
	--SELECT * FROM IowaLiquorSales_REF.dbo.ILS_TEMP WHERE [ITEM NUMBER] = '9904631'--I check that this value doesn't exist so I can use it to replace the trouble value
	
	--Replacing the trouble value
		UPDATE IowaLiquorSales_REF.dbo.ILS_TEMP SET [Item Number] = '9904631' WHERE [Item Number] = 'x904631';

	
	--I add to the temporary table some columns where I will store the primary keys of the reference table later
	ALTER TABLE IowaLiquorSales_REF.dbo.ILS_TEMP
		ADD IdCategory integer, IdVendor integer, IdItem integer, IdStore integer;

END

--NOW WE CREATE THE MAIN DATABASE
IF EXISTS (
        SELECT *
        FROM sys.databases
        WHERE name = 'IowaLiquorSales'
        )
BEGIN
    DROP DATABASE IowaLiquorSales 
END
GO

BEGIN
	CREATE DATABASE IowaLiquorSales ON
	(NAME = IowaLiquorSales_dat,
		FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\IowaLiquorSales_REF.mdf',
		SIZE = 136 MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 64 MB)
	LOG ON
	(NAME = IowaLiquorSales_log,
		FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\IowaLiquorSales_REF.ldf',
		SIZE = 8 MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 64 MB);
END
GO

--Create the reference tables
BEGIN

	USE IowaLiquorSales_REF;

	IF OBJECT_ID (N'IowaLiquorSales.dbo.Stores', N'U') IS NOT NULL DROP TABLE IowaLiquorSales.dbo.Stores;
		create table IowaLiquorSales.dbo.Stores (IdStore integer IDENTITY (1,1) PRIMARY KEY, 
		[Store Number] integer, [Store Name] varchar (100), [Address] varchar (100), 
		[Zip Code] varchar(100), [City] varchar (100), [Store Location] varchar (100), 
		[County Number] integer);

	IF OBJECT_ID (N'IowaLiquorSales.dbo.Categories', N'U') IS NOT NULL 
		DROP TABLE IowaLiquorSales.dbo.Categories;
		create table IowaLiquorSales.dbo.Categories (IdCategory integer IDENTITY(1,1) PRIMARY KEY, 
		[Category] integer, [Category Name] varchar (100), [IdCatGroup] integer);
	
	IF OBJECT_ID (N'IowaLiquorSales_REF.dbo.CategorieGroups', N'U') IS NOT NULL 
		DROP TABLE IowaLiquorSales_REF.dbo.CategoryGroups;
	
	IF OBJECT_ID (N'IowaLiquorSales.dbo.Vendors', N'U') IS NOT NULL 
		DROP TABLE IowaLiquorSales.dbo.Vendors;
		create table IowaLiquorSales.dbo.Vendors (IdVendor integer IDENTITY(1,1) PRIMARY KEY, 
		[Vendor Number] integer, [Vendor Name] varchar (100));

	--The field IdCategory of the reference table 'Items' will be filled later
	--first we will need to work on that value on the reference table Categories (where that field is its primary key)
	
	IF OBJECT_ID (N'IowaLiquorSales.dbo.Items', N'U') IS NOT NULL 
		DROP TABLE IowaLiquorSales.dbo.Items;
		create table IowaLiquorSales.dbo.Items (IdItem integer IDENTITY (1,1) PRIMARY KEY, 
		[Item Number] integer, [IdCategory] integer, [Item Description] varchar (100));
			   
--In Categories we will fill the IdCatGroup with 9999999, this value is temporary
--Later will be a foreign key to a table to work aggregations
	INSERT INTO IowaLiquorSales.dbo.Categories
		SELECT distinct [Category], [Category Name], 9999999
		FROM IowaLiquorSales_REF.dbo.ILS_TEMP as ILSTEMP;

--Now we fill  the primary keys of the different reference tables,
--starting with IdCategory, because we will need that value in the Items reference table

	UPDATE IowaLiquorSales_REF.dbo.ILS_TEMP
		SET ILS_TEMP.[IdCategory] = (SELECT TOP 1 Categories.IdCategory
		FROM IowaLiquorSales.dbo.Categories AS Categories
		WHERE 
		Categories.[Category]=ILS_TEMP.[Category] 
		and Categories.[Category Name]=ILS_TEMP.[Category Name]);

	INSERT INTO IowaLiquorSales.dbo.Items
		SELECT distinct [Item Number], [IdCategory],[Item Description]
		FROM IowaLiquorSales_REF.dbo.ILS_TEMP as ILSTEMP;

	--Adding constraints 
			ALTER TABLE IowaLiquorSales.dbo.Items
			ADD CONSTRAINT FK_Categories
			FOREIGN KEY (IdCategory) REFERENCES Categories(IdCategory);

	INSERT INTO IowaLiquorSales.dbo.Vendors
		SELECT distinct [Vendor Number], [Vendor Name]
		FROM IowaLiquorSales_REF.dbo.ILS_TEMP as ILSTEMP;

	INSERT INTO IowaLiquorSales.dbo.Stores
		SELECT distinct [Store Number], [Store Name], [Address], [Zip Code] , [City],[Store Location],[County Number] 
		FROM IowaLiquorSales_REF.dbo.ILS_TEMP as ILSTEMP;

	--Now we fill the empty Cities with values that we know are included in 'Store Name'
	UPDATE  IowaLiquorSales.dbo.Stores 
		SET [City] = SUBSTRING([Store Name], PATINDEX('%/%', [Store Name]) + 1, LEN([Store Name]))
		WHERE [City] IS NULL 
		  AND [Store Name] IS NOT NULL 
		  AND [Store Name] LIKE '%/%'

	USE IowaLiquorSales;
	--We are going to add two columns on the table Stores, for store's Location:
	ALTER TABLE [Stores]
		ADD LATITUDE VARCHAR(9);

	ALTER TABLE [Stores]
		ADD LONGITUDE VARCHAR(9);

	--We fill that columns manipulating the string value on [Store Location]
	UPDATE [Stores]
		SET LATITUDE=substring([Store Location],patindex('% [0-9]%',[Store Location]),8);

	UPDATE [Stores]
		SET LONGITUDE=substring([store location],8,9);


	--We won´t work the reference table 'Counties' as we did the others, because there are too many null values on that field in the dataset

	UPDATE IowaLiquorSales_REF.dbo.ILS_TEMP 
		SET ILS_TEMP.IdVendor = (
		SELECT TOP 1 Vendors.IdVendor
		FROM IowaLiquorSales.dbo.Vendors AS Vendors
		WHERE 
		Vendors.[Vendor Name]=ILS_TEMP.[Vendor Name] 
		and Vendors.[Vendor Number]=ILS_TEMP.[Vendor Number]);


	UPDATE IowaLiquorSales_REF.dbo.ILS_TEMP
		SET ILS_TEMP.IdItem = (
			SELECT TOP 1 Items.IdItem
			FROM IowaLiquorSales.dbo.Items AS Items
			WHERE
			Items.[Item Number]=ILS_TEMP.[Item Number] 
			and Items.[Item Description]=ILS_TEMP.[Item Description] 
			and Items.IdCategory = IdCategory);


	UPDATE IowaLiquorSales_REF.dbo.ILS_TEMP
		SET ILS_TEMP.IdStore = (
			SELECT TOP 1 Stores.IdStore
			FROM IowaLiquorSales.dbo.Stores AS Stores
			WHERE
			Stores.[Store Number]=ILS_TEMP.[Store Number] 
			and Stores.[Store Name] like ILS_TEMP.[Store Name]
			and IdStore IS NOT NULL);
	--and Stores.[Address] like ILS_TEMP.[Address] and Stores.[Zip Code]=ILS_TEMP.[Zip Code]
	--and Stores.[City] like ILS_TEMP.[City] and Stores.[Store Location] like ILS_TEMP.[Store Location] 
	--and Stores.[County Number]=ILS_TEMP.[County Number] )
	--I comment these last conditions because with store's names and numbers was enough, 
	--I noticed that adding other conditions just generates several combinations for the same store 
	--(bringing different inconsistencies)

END

--Finally we create the main table that it is a normalized version of the original loaded
--There will be no string values here (store name, vendor name, category name and item description could be retrieved through foreign keys to its reference tables)
--Also the fields related to the location of each store were dropped
BEGIN 
 create table IowaLiquorSales.dbo.ILS
	([Invoice Item Description] varchar(50) PRIMARY KEY, 
	[Date] date, 
	[IdItem] integer,
	[IdVendor] integer,
	[IdStore] integer,
	[Pack] integer,
	[Bottle Volume (ml)] integer,
	[State Bottle Cost] float,
	[State Bottle Retail] float,
	[Bottles Sold] integer,
	[Sale (Dollars)] float,
	[Volume Sold (Liters)] float,
	[Volume Sold (Gallons)] float,
	Constraint FK_Store FOREIGN KEY (IdStore) REFERENCES IowaLiquorSales.dbo.Stores([IdStore]),
	Constraint FK_Vendor FOREIGN KEY (IdVendor) REFERENCES IowaLiquorSales.dbo.Vendors([IdVendor]),
	Constraint FK_Item FOREIGN KEY (IdItem) REFERENCES IowaLiquorSales.dbo.Items([IdItem]));




--The load itself


	INSERT INTO IowaLiquorSales.dbo.ILS 
	SELECT SUBSTRING([Invoice Item Description],1,16) AS [Invoice Item Description] , 
	CAST([Date] AS date) AS DATE, 
	[IdItem], [IdVendor], [IdStore],   
	CAST([Pack] AS INTEGER) AS [Pack], 
	CAST([Bottle Volume (ml)] AS FLOAT) as [Bottle Volume (ml)] , 
	CAST([State Bottle Cost] AS FLOAT) AS [State Bottle Cost], 
	CAST([State Bottle Retail] AS FLOAT) AS [State Bottle Retail] , 
	CAST([Bottles Sold] AS INTEGER) AS [Bottles Sold],
	CAST([Sale (Dollars)] AS FLOAT) AS [Sale (Dollars)], 
	CAST([Volume Sold (Liters)] AS FLOAT) AS [Volume Sold (Liters)], 
	CAST([Volume Sold (Gallons] AS FLOAT) AS [Volume Sold (Gallons] 
	FROM IowaLiquorSales_REF.dbo.ILS_TEMP;


	--We add constraints for future loads



	--Armo otra tabla de referencia de tercer orden, donde van los agrupados de las categorías

	CREATE TABLE CategoryGroups (IdCatGroup integer IDENTITY (1,1)  PRIMARY KEY, [Category group] varchar (20));
	INSERT INTO CategoryGroups VALUES ('WHISKEY');
	INSERT INTO CategoryGroups VALUES('COCKTAILS');
	INSERT INTO CategoryGroups VALUES('RUM');
	INSERT INTO CategoryGroups VALUES('BRANDIE');
	INSERT INTO CategoryGroups VALUES('TEQUILA');
	INSERT INTO CategoryGroups VALUES('SCHNAPPS');
	INSERT INTO CategoryGroups VALUES('LIQUEUR');
	INSERT INTO CategoryGroups VALUES('VODKA');
	INSERT INTO CategoryGroups VALUES('GIN');
	INSERT INTO CategoryGroups VALUES('OTHERS');


	UPDATE Categories
	SET [IdCatGroup]=
	(CASE 
	WHEN [Category Name] LIKE '%BOURBON%' OR  [Category Name] LIKE '%SCOTCH%' 
	OR  [Category Name] LIKE '%JIM BEAM%' OR  [Category Name] LIKE '% WHISK%'
	OR  [Category Name] LIKE '%YR%' OR  [Category Name] LIKE '%RYE%' 
	OR  [Category Name] LIKE '% MALT%'  OR  [Category Name] LIKE '%JAMESON%' THEN 1
	WHEN [Category Name] LIKE '%MARGARITA%' OR [Category Name] LIKE '%COLADA%' 
	OR [Category Name] LIKE '%COCKTAIL%' THEN 2
	WHEN [Category Name] LIKE '%RUM%' THEN 3
	WHEN [Category Name] LIKE '%BRANDIE%' THEN 4
	WHEN [Category Name] LIKE '%TEQUILA%' THEN 5
	WHEN [Category Name] LIKE '%SCHNAPPS%' THEN 6
	WHEN [Category Name] LIKE '%LIQUEUR%' THEN 7
	WHEN [Category Name] LIKE '%VODKA%' THEN 8
	WHEN [Category Name] LIKE '%GIN%' THEN 9
	WHEN [Category Name] IS NULL THEN 10
	ELSE 10 
	END);

	--Adding constraints
			ALTER TABLE Categories
			ADD CONSTRAINT FK_Groups
			FOREIGN KEY (IdCatGroup) REFERENCES CategoryGroups(IdCatGroup);

	UPDATE CategoryGroups
		SET [Category group] = 'OTHERS'
		WHERE [Category group] IS NULL


END
--USE IowaLiquorSales_REF
--DROP DATABASE IowaLiquorSales_REF
