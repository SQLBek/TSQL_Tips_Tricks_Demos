/*-------------------------------------------------------------------
-- 1 - SSMS Productivity Tips & Tricks
-- 
-- Summary: Neat SSMS tidbits to make your life easier!
--
-- Written By: Andy Yun
-------------------------------------------------------------------*/
USE AutoDealershipDemo;
GO








-----
-- Example #1 - Quick Reference
SELECT 
	Model.ModelName,
	Inventory.VIN,
	Inventory.InvoicePrice
FROM dbo.Inventory
INNER JOIN Vehicle.BaseModel
	ON Inventory.BaseModelID = BaseModel.BaseModelID
INNER JOIN Vehicle.Model
	ON BaseModel.ModelID = Model.ModelID


-- TASK: Add a LEFT OUTER JOIN to the SalesHistory table
-- & add what price a vehicle was sold for.  
--
-- Remember all columns in a given table?




-- Hardcore
SELECT 
	schemas.name AS SchemaName,
	objects.name AS TableName,
	columns.name AS ColumnName
FROM sys.objects
INNER JOIN sys.columns
	ON objects.object_id = columns.object_id
INNER JOIN sys.schemas
	ON objects.schema_id = schemas.schema_id 
WHERE objects.object_id = OBJECT_ID(N'dbo.SalesHistory')
ORDER BY columns.column_id;








-- OR?








-- GUI?








-- OR?








-- sp_help
EXEC sp_help 'dbo.SalesHistory';








-- OR?








-- Keyboard Shortcuts are Awesome!








-----
-- Example #2 - No SELECT *
IF OBJECT_ID('tempdb.dbo.#myTempTable') IS NOT NULL
	DROP TABLE #myTempTable;

SELECT TOP 1000 *
INTO #myTempTable
FROM dbo.vw_AllSoldInventory

-- SELECT * is bad, m'kay?
-- Let's refactor. Need a list of columns.


-- sp_help?




-- What was in that temp table?
EXEC sp_help '#myTempTable'








-- Adjusted
EXEC tempdb..sp_help '#myTempTable'


-- Must add commas to copied column list! :-(








-- GUI?




-- Clean up
IF OBJECT_ID('tempdb.dbo.#myTempTable') IS NOT NULL
	DROP TABLE #myTempTable;








-----
-- Example #3 - Repeat Yourself
-- Spin up sample workload
/*
EXEC msdb.dbo.sp_start_job 'AutoDealership - sp_GetAllInventory_ByRandModel_MethodA'
EXEC msdb.dbo.sp_start_job 'AutoDealership - sp_GetInventory_ByRandColor'
EXEC msdb.dbo.sp_start_job 'AutoDealership - sp_GetUnsoldMakeModel_GrpByMonth'
*/

EXEC sp_whoisactive


-- What if I have to run this repeatedly?








-- GO, GO, GO!
EXEC sp_whoisactive
GO 








-- Want to wait?
EXEC sp_whoisactive
WAITFOR DELAY '00:00:01' 
GO 3








-----
-- Example #4 - Vertical Horizons
SELECT InventoryID, VIN
FROM dbo.Inventory
WHERE VIN IN (
)


-- Given a list of VINs, query the InventoryIDs
/*
JT2IYMHII9E312423	JT2Q5ESQQ9E329620
JT2C3A4CC9E392134	JT2CVL2CC9E377644
JT28C2L889E379398	JT2SGHMSS9E303436
JT26TGK669E362102	JT24ZV7449E337649
JT2RVRHRR9E336356	JT2QND0QQ9E347542
JT2P8DPPP9E384310	JT2ORR0OO9E319499
JT2DEM6DD9E328242	JT2AUJGAA9E331227
JT25MJ3559E318997	JT26REZ669E365960
JT27PRP779E310165	JT2RP7QRR9E329182
JT2F6MUFF9E356441	JT2TXADTT9E303103
*/







-----
-- Example #5 - Give me all the things!

-- Script out a bunch of views for me
-- GUI?






---------------------------------------------
---------------------------------------------
---------------------------------------------
---------------------------------------------