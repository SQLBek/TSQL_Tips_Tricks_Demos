/*-------------------------------------------------------------------
-- 2 - T-SQL Anti-Patterns
-- 
-- Written By: Andy Yun
-------------------------------------------------------------------*/
USE AutoDealershipDemo;
GO




-----
-- Example #1 - Sort it my way!
IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.SalesSummary'))
	DROP TABLE dbo.SalesSummary;

CREATE TABLE dbo.SalesSummary (
	VIN CHAR(17),
	InvoicePrice MONEY,
	SellPrice MONEY,
	TransactionDate DATETIME
);
CREATE CLUSTERED INDEX CK_SalesSummary_VIN ON dbo.SalesSummary (VIN);




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








-- What about a more complex query?
INSERT INTO dbo.SalesSummary (
	VIN,
	InvoicePrice,
	SellPrice,
	TransactionDate
)
SELECT 
	--TOP 50000
	vw_AllSoldInventory.VIN,
	vw_AllSoldInventory.InvoicePrice,
	vw_AllSoldInventory.SellPrice,
	vw_AllSoldInventory.TransactionDate
FROM dbo.vw_AllSoldInventory
ORDER BY vw_AllSoldInventory.TransactionDate DESC
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
	--TOP 50000
	vw_AllSoldInventory.VIN,
	vw_AllSoldInventory.InvoicePrice,
	vw_AllSoldInventory.SellPrice,
	vw_AllSoldInventory.TransactionDate
FROM dbo.vw_AllSoldInventory
OPTION(MAXDOP 1);
GO
TRUNCATE TABLE SalesSummary
GO
-- STOP








-- How about a heap?
IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.SalesSummaryHeap'))
	DROP TABLE dbo.SalesSummaryHeap;

CREATE TABLE dbo.SalesSummaryHeap (
	VIN CHAR(17),
	InvoicePrice MONEY,
	SellPrice MONEY,
	TransactionDate DATETIME
);




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




-- What about a more complex query?
INSERT INTO dbo.SalesSummaryHeap (
	VIN,
	InvoicePrice,
	SellPrice,
	TransactionDate
)
SELECT 
	TOP 50000
	vw_AllSoldInventory.VIN,
	vw_AllSoldInventory.InvoicePrice,
	vw_AllSoldInventory.SellPrice,
	vw_AllSoldInventory.TransactionDate
FROM dbo.vw_AllSoldInventory
ORDER BY vw_AllSoldInventory.TransactionDate DESC
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
	TOP 50000
	vw_AllSoldInventory.VIN,
	vw_AllSoldInventory.InvoicePrice,
	vw_AllSoldInventory.SellPrice,
	vw_AllSoldInventory.TransactionDate
FROM dbo.vw_AllSoldInventory
OPTION(MAXDOP 1);
GO
TRUNCATE TABLE SalesSummaryHeap
GO
-- STOP


-- Turn off Actual Execution Plan








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




-- What's the difference?
/*
SET STATISTICS TIME ON
*/

-- Run with & without ORDER BY
SELECT 
	Inventory.VIN,
	Inventory.InvoicePrice,
	SalesHistory.SellPrice,
	SalesHistory.TransactionDate
FROM dbo.Inventory
INNER JOIN dbo.SalesHistory
	ON SalesHistory.InventoryID = Inventory.InventoryID;
GO


-- Where's this data going?








-----
-- Example #3 - OR?
-- Turn on Actual Execution Plan
SET STATISTICS IO ON


SELECT Inventory.InventoryID, Inventory.InvoicePrice, Inventory.MSRP
FROM dbo.Inventory
WHERE VIN IN (
'JT200Q9009E364289', 'JT20ASE009E332507', 'JT21NMK119E368181', 'JT22IF0229E340358',
'JT22QVV229E350067', 'JT24HAC449E389959', 'JT24LCP449E345285', 'JT262MM669E352988',
'JT2865R889E324701', 'JT2BBT4BB9E309228', 'JT2DDBEDD9E330604', 'JT2DO0GDD9E338799',
'JT2EAFBEE9E384689', 'JT2FX60FF9E351314', 'JT2GATBGG9E349531', 'JT2L8P5LL9E385556',
'JT2LKAULL9E352465', 'JT2N821NN9E337472', 'JT2NGUMNN9E397565', 'JT2NP4RNN9E343842',
'JT2NSTNNN9E314503', 'JT2OD1OOO9E394021', 'JT2PIJ9PP9E313415', 'JT2R7TMRR9E359006',
'JT2VX55VV9E393015'
);








-- Cover it
IF EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_Inventory_VIN_Pricing')
	DROP INDEX dbo.Inventory.IX_Inventory_VIN_Pricing;
CREATE NONCLUSTERED INDEX IX_Inventory_VIN_Pricing 
	ON dbo.Inventory (VIN, InventoryID) INCLUDE (InvoicePrice, MSRP);




-- Now what happens?
SELECT InventoryID, InvoicePrice, MSRP
FROM dbo.Inventory
WHERE VIN IN (
'JT200Q9009E364289', 'JT20ASE009E332507', 'JT21NMK119E368181', 'JT22IF0229E340358',
'JT22QVV229E350067', 'JT24HAC449E389959', 'JT24LCP449E345285', 'JT262MM669E352988',
'JT2865R889E324701', 'JT2BBT4BB9E309228', 'JT2DDBEDD9E330604', 'JT2DO0GDD9E338799',
'JT2EAFBEE9E384689', 'JT2FX60FF9E351314', 'JT2GATBGG9E349531', 'JT2L8P5LL9E385556',
'JT2LKAULL9E352465', 'JT2N821NN9E337472', 'JT2NGUMNN9E397565', 'JT2NP4RNN9E343842',
'JT2NSTNNN9E314503', 'JT2OD1OOO9E394021', 'JT2PIJ9PP9E313415', 'JT2R7TMRR9E359006',
'JT2VX55VV9E393015'
)




-- Alternative Solution?
IF OBJECT_ID('tempdb.dbo.#tmpVINs','U') IS NOT NULL
	DROP TABLE #tmpVINs;

CREATE TABLE #tmpVINs (
	VIN	CHAR(17) PRIMARY KEY CLUSTERED
);
INSERT INTO #tmpVINs
SELECT 'JT200Q9009E364289' UNION ALL SELECT 'JT20ASE009E332507' UNION ALL 
SELECT 'JT21NMK119E368181' UNION ALL SELECT 'JT22IF0229E340358' UNION ALL 
SELECT 'JT22QVV229E350067' UNION ALL SELECT 'JT24HAC449E389959' UNION ALL 
SELECT 'JT24LCP449E345285' UNION ALL SELECT 'JT262MM669E352988' UNION ALL 
SELECT 'JT2865R889E324701' UNION ALL SELECT 'JT2BBT4BB9E309228' UNION ALL 
SELECT 'JT2DDBEDD9E330604' UNION ALL SELECT 'JT2DO0GDD9E338799' UNION ALL 
SELECT 'JT2EAFBEE9E384689' UNION ALL SELECT 'JT2FX60FF9E351314' UNION ALL 
SELECT 'JT2GATBGG9E349531' UNION ALL SELECT 'JT2L8P5LL9E385556' UNION ALL 
SELECT 'JT2LKAULL9E352465' UNION ALL SELECT 'JT2N821NN9E337472' UNION ALL 
SELECT 'JT2NGUMNN9E397565' UNION ALL SELECT 'JT2NP4RNN9E343842' UNION ALL 
SELECT 'JT2NSTNNN9E314503' UNION ALL SELECT 'JT2OD1OOO9E394021' UNION ALL 
SELECT 'JT2PIJ9PP9E313415' UNION ALL SELECT 'JT2R7TMRR9E359006' UNION ALL 
SELECT 'JT2VX55VV9E393015' ;


SELECT InventoryID, InvoicePrice, MSRP
FROM dbo.Inventory
WHERE EXISTS (
	SELECT 1
	FROM #tmpVINs
	WHERE #tmpVINs.VIN = Inventory.VIN
);


-- Which is best?


-- Turn off Actual Execution Plan
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

IF EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_Inventory_VIN_Pricing')
	DROP INDEX dbo.Inventory.IX_Inventory_VIN_Pricing;








-----
-- Example #4 - Where'd my day go?
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
		AND '2014-12-31 23:59:59.999'








-- One correct way
SELECT COUNT(SalesHistoryID)
FROM SalesHistory
WHERE (
	TransactionDate    >= '2014-12-01 00:00:000' 
	AND TransactionDate < '2015-01-01 00:00:000' 
);
/*
WHERE TransactionDate 
	BETWEEN '2014-12-01 00:00:00.000' 
		AND '2014-12-31 23:59:59.999'
*/








-----
-- Example #5 - A step back
IF EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_Inventory_TransactionDate')
	DROP INDEX dbo.SalesHistory.IX_Inventory_TransactionDate;
CREATE NONCLUSTERED INDEX IX_Inventory_TransactionDate 
	ON dbo.SalesHistory (TransactionDate);
GO




-- Let use a date function!
DECLARE 
	@StartDate DATE = '2014-12-01',
	@EndDate DATE = '2014-12-31';

SELECT COUNT(SalesHistoryID)
FROM SalesHistory
WHERE CAST(TransactionDate AS DATE) 
	BETWEEN @StartDate AND @EndDate;


-- Turn on Actual Execution Plan


-- Turn off Actual Execution Plan






-----
-- Example #6 - How long? Who cares?
DECLARE 
	@myValue VARCHAR = 'Andy',
	@aLongerString VARCHAR = 'This is a much longer string which has of 57 characters.';

SELECT 
	@MyValue, 
	@aLongerString;








-- CAST & CONVERT
SELECT 
	CAST('This is a much longer string which has of 57 characters.' AS VARCHAR) AS Casted,
	LEN(CAST('This is a much longer string which has of 57 characters.' AS VARCHAR)) AS CastedLength,
	CONVERT(VARCHAR, 'This is a much longer string which has of 57 characters.') AS Converted,
	LEN(CONVERT(VARCHAR, 'This is a much longer string which has of 57 characters.')) AS ConvertedLength;








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

-- sp_help








-----
-- Example #7 - SELECT that SELECT!
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


--
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
-- 

