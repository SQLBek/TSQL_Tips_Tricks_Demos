/*-------------------------------------------------------------------
-- 3 - Clever Solutions to Common but Not Easily Coded Challenges
-- 
-- Written By: Andy Yun
-------------------------------------------------------------------*/
USE AutoDealershipDemo;
GO




-----
-- Example #1 - Fun with OUTPUT & inserted
IF OBJECT_ID('tempdb.dbo.#tmpDestination_One') IS NOT NULL
	DROP TABLE #tmpDestination_One;

CREATE TABLE #tmpDestination_One (
	VIN CHAR(17)
);

IF OBJECT_ID('tempdb.dbo.#tmpDestination_Two') IS NOT NULL
	DROP TABLE #tmpDestination_Two;

CREATE TABLE #tmpDestination_Two (
	VIN CHAR(17)
);




INSERT INTO #tmpDestination_One(VIN)
OUTPUT inserted.VIN			-- What's this?!
INTO #tmpDestination_Two
SELECT TOP 1000 VIN
FROM dbo.Inventory;




SELECT VIN
FROM #tmpDestination_One;

SELECT VIN
FROM #tmpDestination_Two;


-- What is OUTPUT & inserted?
-- Be clever!
-- Reference URL: https://docs.microsoft.com/en-us/sql/t-sql/queries/output-clause-transact-sql








-----
-- Example #2 - Horizontal Aggregations?  MIN & MAX across columns?
SELECT Inventory.InventoryID,
	Inventory.InvoicePrice,
	Inventory.MSRP,
	SalesHistory.SellPrice
FROM dbo.Inventory
INNER JOIN dbo.SalesHistory
	ON Inventory.InventoryID = SalesHistory.InventoryID
ORDER BY Inventory.InventoryID


-- Fun with VALUES()








SELECT Inventory.InventoryID,
	Inventory.InvoicePrice,
	Inventory.MSRP,
	SalesHistory.SellPrice,
	(
		SELECT SUM(PriceArray.Price)
		FROM (
			VALUES 
				(Inventory.InvoicePrice),
				(Inventory.MSRP),
				(SalesHistory.SellPrice)
			) AS PriceArray(Price)
	) AS MinPrice
FROM dbo.Inventory
INNER JOIN dbo.SalesHistory
	ON Inventory.InventoryID = SalesHistory.InventoryID
ORDER BY Inventory.InventoryID;


-- Didn't you say don't RBAR?
SET STATISTICS IO ON;




-- What happened?  Show Actual Execution Plan


-- Turn off Actual Execution Plan
SET STATISTICS IO OFF;








-----
-- Example #3 - Comma Separated Tricks
SELECT TOP 5 VIN
FROM dbo.Inventory








-- STUFF() & XML to the rescue!




-- FOR XML PATH('')
SELECT TOP 5 VIN
FROM dbo.Inventory
FOR XML PATH('');




-- Add our delimiter
SELECT TOP 5 ',' + VIN
FROM dbo.Inventory
FOR XML PATH('');




-- We must still chop off the first extra comma!  








-- Could use SUBSTRING?
SELECT 
	SUBSTRING(
		(
			SELECT TOP 5 ',' + VIN
			FROM dbo.Inventory
			FOR XML PATH('')
		), 2, 8000	
	) AS Column2CSVString;


-- Problem: How do I know what the actual length of my string is?








-- Use STUFF!
--
-- STUFF(character_expression, start, length, replaceWith_expression)  
-- Deletes a specified length of characters in the first string,
-- at the start position, 
-- then inserts the second string into the first string,
-- at the start position.
SELECT 
	'ABCDEFGHIJK' AS OriginalString,
	STUFF(
		'ABCDEFGHIJK',	-- starting string
		3,				-- start position
		5,				-- number of characters to replace
		'-12345-'		-- replacement string
	) AS StuffedString;




-- Stuff is a poor man's LEFT TRUNCATE!
SELECT
	',Sadie,Jess' AS OriginalString,
	STUFF(
		',Sadie,Jess',
		1,				-- start position
		1,				-- number of char to replace
		''				-- replace with nothing!
	) AS LeftTruncatedString;







-- FINAL
SELECT 
	STUFF(
		(
			SELECT TOP 5 ',' + VIN
			FROM dbo.Inventory
			FOR XML PATH('')
		), 1, 1, ''
	) AS Column2CSVString;








-- Grouped?!
IF OBJECT_ID('tempdb.dbo.#tmpVehicleList','U') IS NOT NULL
	DROP TABLE #tmpVehicleList;

CREATE TABLE #tmpVehicleList (
	RecID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
	ModelName VARCHAR(50),
	ColorName VARCHAR(50)
);

INSERT INTO #tmpVehicleList (ModelName, ColorName) 
SELECT Model.ModelName, Color.ColorName
FROM Vehicle.BaseModel
INNER JOIN Vehicle.Model
	ON BaseModel.ModelID = Model.ModelID
INNER JOIN Vehicle.Color
	ON BaseModel.ColorID = Color.ColorID
WHERE BaseModelID % 5 = 0
	AND ModelName IN ('4Runner', 'Camry', 'Highlander')
UNION 
SELECT Model.ModelName, Color.ColorName
FROM Vehicle.BaseModel
INNER JOIN Vehicle.Model
	ON BaseModel.ModelID = Model.ModelID
INNER JOIN Vehicle.Color
	ON BaseModel.ColorID = Color.ColorID
WHERE BaseModelID % 7 = 1
ORDER BY Model.ModelName, Color.ColorName

SELECT 
	RecID,
	ModelName, 
	ColorName
FROM #tmpVehicleList;








-- Apply FOR XML PATH('') again!
SELECT 
	ModelList.ModelName,
	STUFF(
		(
			SELECT 
				',' + ColorCSVList.ColorName 
			FROM #tmpVehicleList AS ColorCSVList
			WHERE ModelList.ModelName = ColorCSVList.ModelName	-- Like a SELF JOIN
			FOR XML PATH('')
		), 1, 1, ''
	) AS Column2CSVString  
FROM #tmpVehicleList AS ModelList
GROUP BY ModelList.ModelName








-----
-- Example #4 - Fun with String Functions!
IF OBJECT_ID('tempdb.dbo.#tmpFilePath') IS NOT NULL
	DROP TABLE #tmpFilePath;

CREATE TABLE #tmpFilePath (
	RecID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
	FilePath NVARCHAR(256)
);
INSERT INTO #tmpFilePath 
VALUES (
	'C:\My Documents\FolderName\AnotherFolder\MyTextFile.txt'
);


--
SELECT FilePath
FROM #tmpFilePath;

-- Give me the Filename only!
-- MyTextFile.txt








-- CHARINDEX()?
SELECT FilePath,
	CHARINDEX('\', FilePath) AS LeftCharIndex
FROM #tmpFilePath;








-- Drive in REVERSE!
SELECT FilePath,
	CHARINDEX('\', FilePath) AS LeftCharIndex,
	REVERSE(FilePath) AS FilePathReversed
FROM #tmpFilePath;








-- CHARINDEX on the right side
SELECT FilePath,
	CHARINDEX('\', FilePath) AS LeftCharIndex,
	REVERSE(FilePath) AS FilePathReversed,
	CHARINDEX('\', 
		REVERSE(FilePath)
	) AS RightCharIndex
FROM #tmpFilePath;








-- Like an array
--
-- C:\My Documents\FolderName\AnotherFolder\MyTextFile.txt
--   *                                     *
-- 1234567890123456789012345678901234567890123456789012345
--
-- txt.eliFtxeTyM\redloFrehtonA\emaNredloF\stnemucoD yM\:C
--               *








-- Do some math to get the right-most position
SELECT FilePath,
	CHARINDEX('\', FilePath) AS LeftCharIndex,
	REVERSE(FilePath) AS FilePathReversed,
	CHARINDEX('\', 
		REVERSE(FilePath)
	) AS RightCharIndex,
	LEN(FilePath) AS FilePathLength,
	LEN(FilePath) - CHARINDEX('\', REVERSE(FilePath)) AS RightMostDelimiter
FROM #tmpFilePath;








-- SUBSTRING()
SELECT FilePath,
	CHARINDEX('\', FilePath) AS LeftCharIndex,
	REVERSE(FilePath) AS FilePathReversed,
	CHARINDEX('\', 
		REVERSE(FilePath)
	) AS RightCharIndex,
	LEN(FilePath) AS FilePathLength,
	LEN(FilePath) - CHARINDEX('\', REVERSE(FilePath)) + 1 AS RightMostDelimiter,
	SUBSTRING(
		-- Original String
		FilePath,
		-- RightMostDelimiter plus another 1, as starting point
		LEN(FilePath) - CHARINDEX('\', REVERSE(FilePath)) + 2,
		-- Number of characters to the right, to take. Can just use LEN() here.
		LEN(FilePath)
	) AS MyFileName
FROM #tmpFilePath;


-- Note my methodology





---------------------------------------------
---------------------------------------------
---------------------------------------------
---------------------------------------------