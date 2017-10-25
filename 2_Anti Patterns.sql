/*-------------------------------------------------------------------
-- 2 - T-SQL Anti-Patterns
-- 
-- Summary: When I see these in code, they make me pause and go
-- hmmm...
--
-- Written By: Andy Yun 
-------------------------------------------------------------------*/
USE AutoDealershipDemo;
GO




-----
-- Example #1 - Sort it my way!
-- SETUP
IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.SalesSummary'))
	DROP TABLE dbo.SalesSummary;

CREATE TABLE dbo.SalesSummary (
	VIN CHAR(17),
	InvoicePrice MONEY,
	SellPrice MONEY,
	TransactionDate DATETIME
);
CREATE CLUSTERED INDEX CK_SalesSummary_VIN ON dbo.SalesSummary (VIN);
-- STOP




-- Turn on Actual Execution Plan
INSERT INTO dbo.SalesSummary (
	VIN,
	InvoicePrice,
	SellPrice,
	TransactionDate
)
SELECT 
	Inventory.VIN,
	Inventory.InvoicePrice,
	SalesHistory.SellPrice,
	SalesHistory.TransactionDate
FROM dbo.Inventory
INNER JOIN dbo.SalesHistory
	ON SalesHistory.InventoryID = Inventory.InventoryID
ORDER BY SalesHistory.TransactionDate DESC
OPTION(MAXDOP 1);
GO
TRUNCATE TABLE SalesSummary
GO

INSERT INTO dbo.SalesSummary (
	VIN,
	InvoicePrice,
	SellPrice,
	TransactionDate
)
SELECT 
	Inventory.VIN,
	Inventory.InvoicePrice,
	SalesHistory.SellPrice,
	SalesHistory.TransactionDate
FROM dbo.Inventory
INNER JOIN dbo.SalesHistory
	ON SalesHistory.InventoryID = Inventory.InventoryID
OPTION(MAXDOP 1);
GO
TRUNCATE TABLE SalesSummary
GO
-- STOP




-- What version of SQL Server are you on?
-- Running an older version of SQL Server?
SELECT @@VERSION;




-----
-- 2017   - 140		-- 2016   - 130
-- 2014   - 120		-- 2012   - 110
-- 2008R2 - 100
SELECT name, compatibility_level
FROM sys.databases
WHERE name = 'AutoDealershipDemo';


-- Drop down to 2008R2 & repeat above
ALTER DATABASE AutoDealershipDemo
SET COMPATIBILITY_LEVEL = 100;




-- How about a heap?
-- SETUP
IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.SalesSummaryHeap'))
	DROP TABLE dbo.SalesSummaryHeap;

CREATE TABLE dbo.SalesSummaryHeap (
	VIN CHAR(17),
	InvoicePrice MONEY,
	SellPrice MONEY,
	TransactionDate DATETIME
);
-- STOP




-- Repeat INSERTs
INSERT INTO dbo.SalesSummaryHeap (
	VIN,
	InvoicePrice,
	SellPrice,
	TransactionDate
)
SELECT 
	Inventory.VIN,
	Inventory.InvoicePrice,
	SalesHistory.SellPrice,
	SalesHistory.TransactionDate
FROM dbo.Inventory
INNER JOIN dbo.SalesHistory
	ON SalesHistory.InventoryID = Inventory.InventoryID
ORDER BY SalesHistory.TransactionDate DESC
OPTION(MAXDOP 1);
GO
TRUNCATE TABLE SalesSummaryHeap
GO

INSERT INTO dbo.SalesSummaryHeap (
	VIN,
	InvoicePrice,
	SellPrice,
	TransactionDate
)
SELECT 
	Inventory.VIN,
	Inventory.InvoicePrice,
	SalesHistory.SellPrice,
	SalesHistory.TransactionDate
FROM dbo.Inventory
INNER JOIN dbo.SalesHistory
	ON SalesHistory.InventoryID = Inventory.InventoryID
OPTION(MAXDOP 1);
TRUNCATE TABLE SalesSummaryHeap
GO
-- STOP




-- RESET
-- Turn off Actual Execution Plan
ALTER DATABASE AutoDealershipDemo
SET COMPATIBILITY_LEVEL = 140;








-----
-- Example #2 - Sort and sort again!
SELECT 
	Inventory.VIN,
	Inventory.InvoicePrice,
	SalesHistory.SellPrice,
	SalesHistory.TransactionDate
FROM dbo.Inventory
INNER JOIN dbo.SalesHistory
	ON SalesHistory.InventoryID = Inventory.InventoryID
ORDER BY Inventory.VIN;
GO




-- What's the cost difference?
/*
SET STATISTICS TIME ON
*/

-- Re-run above with ORDER BY & below without ORDER BY
SELECT 
	Inventory.VIN,
	Inventory.InvoicePrice,
	SalesHistory.SellPrice,
	SalesHistory.TransactionDate
FROM dbo.Inventory
INNER JOIN dbo.SalesHistory
	ON SalesHistory.InventoryID = Inventory.InventoryID;
GO


-- Ever ask where is this data going?








-----
-- Example #3 - Where'd my day go?
SELECT COUNT(SalesHistoryID)
FROM dbo.SalesHistory
WHERE TransactionDate 
	BETWEEN '2014-12-01' 
		AND '2014-12-31';


-- Give me all Sales records from December 2014








-- But this is WRONG!  Why?
-- Look at SalesHistory.TransactionDate datatype




-- As DATETIME, what are the real values?
SELECT 
	CAST('2014-12-01' AS DATETIME),
	CAST('2014-12-31' AS DATETIME);








-- Query Extrapolated
SELECT COUNT(SalesHistoryID)
FROM dbo.SalesHistory
WHERE TransactionDate 
	BETWEEN '2014-12-01 00:00:00.000' 
		AND '2014-12-31 00:00:00.000'








-- What am I missing?!
SELECT COUNT(SalesHistoryID)
FROM dbo.SalesHistory
WHERE TransactionDate 
	BETWEEN '2014-12-31 00:00:00.000' 
		AND '2014-12-31 23:59:59.997'








-- One correct way
SELECT COUNT(SalesHistoryID)
FROM SalesHistory
WHERE (
	TransactionDate    >= '2014-12-01 00:00:000' 
	AND TransactionDate < '2015-01-01 00:00:000' 
);
/* 
-- Also correct
WHERE TransactionDate 
	BETWEEN '2014-12-01 00:00:00.000' 
		AND '2014-12-31 23:59:59.997'
*/








-----
-- Example #4 - How long? Who cares?
DECLARE 
	@myValue VARCHAR = 'Andy',
	@aLongerString VARCHAR = 'This is a much longer string which has of 57 characters.';

SELECT 
	@MyValue, 
	@aLongerString;








-- CAST & CONVERT
SELECT 
	CAST('This is a much longer string which has of 57 characters.' 
		AS VARCHAR) 
	AS Casted,
	LEN(CAST('This is a much longer string which has of 57 characters.' 
			AS VARCHAR)
		) 
	AS CastedLength,
	CONVERT(
		VARCHAR, 
		'This is a much longer string which has of 57 characters.'
	) AS Converted,
	LEN(CONVERT(
			VARCHAR, 
			'This is a much longer string which has of 57 characters.'
		)
	) AS ConvertedLength;








-- What about a table?
IF OBJECT_ID('tempdb.dbo.#tmpDeclarationsMatter','U') IS NOT NULL
	DROP TABLE #tmpDeclarationsMatter;

CREATE TABLE #tmpDeclarationsMatter (
	ColOne VARCHAR,
	ColTwo VARCHAR DEFAULT('A Longer string')
);








-- Insert a value?
INSERT INTO #tmpDeclarationsMatter (ColOne) VALUES ('Sadie');




-- Insert with DEFAULT?
INSERT INTO #tmpDeclarationsMatter (ColTwo) VALUES (DEFAULT);




SELECT * 
FROM #tmpDeclarationsMatter;

-- Reference sp_help








-----
-- Example #5 - SELECT that SELECT!
SET STATISTICS TIME ON;

SELECT 
	Inventory.InventoryID,
	Inventory.VIN,
	Inventory.InvoicePrice,
	ISNULL(
		(
			SELECT SalesHistory.SellPrice - Inventory.InvoicePrice
			FROM dbo.SalesHistory
			WHERE Inventory.InventoryID = SalesHistory.InventoryID
		)
	, 0) AS NetProfit
FROM dbo.Inventory;


-- Add & re-run
SET STATISTICS IO ON;








SELECT 
	Inventory.InventoryID,
	Inventory.VIN,
	Inventory.InvoicePrice,
	SalesHistory.SellPrice - Inventory.InvoicePrice AS NetProfit
FROM dbo.Inventory
INNER JOIN dbo.SalesHistory
	ON Inventory.InventoryID = SalesHistory.InventoryID;


--
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;








---------------------------------------------
---------------------------------------------
---------------------------------------------
---------------------------------------------
