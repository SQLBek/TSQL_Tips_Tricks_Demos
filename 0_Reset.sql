/*-------------------------------------------------------------------
-- 0 - Reset Demo Tables
-- 
-- Written By: Andy Yun
-------------------------------------------------------------------*/
USE AutoDealershipDemo;
GO

-----
-- 
-- SELECT * FROM sys.configurations ORDER BY name
-- EXEC sp_configure 'show advanced options', 1
-- EXEC sp_configure 'xp_cmdshell', 1
-- RECONFIGURE


IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.SalesSummary'))
	DROP TABLE dbo.SalesSummary;
GO

IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.SalesSummaryHeap'))
	DROP TABLE dbo.SalesSummaryHeap;
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_Inventory_VIN_Pricing')
	DROP INDEX dbo.Inventory.IX_Inventory_VIN_Pricing;
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_Inventory_TransactionDate')
	DROP INDEX dbo.SalesHistory.IX_Inventory_TransactionDate;
GO

-- Note - may have a few rows leftover/unaffected
UPDATE dbo.SalesHistory
SET TransactionDate = DATEADD(second, (SalesHistoryID + CustomerID + SalesPersonID + InventoryID) % 86400, TransactionDate)
FROM dbo.SalesHistory
WHERE CAST(TransactionDate AS TIME) = '00:00:00.0000000';
GO

SELECT name, compatibility_level
FROM sys.databases
WHERE name = 'AutoDealershipDemo'

ALTER DATABASE AutoDealershipDemo
SET COMPATIBILITY_LEVEL = 140;
GO

-- Reset
DROP PROCEDURE dbo.NewStoredProc
GO
