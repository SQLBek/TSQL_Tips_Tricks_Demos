/*-------------------------------------------------------------------
-- 4 - New in 2016/2017
-- 
-- Summary: New hotness in SQL Server 2016 & 2017
--
-- Written By: Andy Yun
-------------------------------------------------------------------*/
USE AutoDealershipDemo;
GO



SELECT @@VERSION;





-----
-- Example #1 - Does an object already exist?
ALTER PROCEDURE dbo.NewStoredProc
AS 
BEGIN
	SELECT 1;
END
GO








-- Brute force
DROP PROCEDURE dbo.NewStoredProc
GO
CREATE PROCEDURE dbo.NewStoredProc
AS 
BEGIN
	SELECT 1;
END
GO








-- More Brute force
IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.NewStoredProc'))
	DROP PROCEDURE dbo.NewStoredProc;
GO








-- A new way to DROP the DROP! (SS 2016)
DROP PROCEDURE IF EXISTS dbo.NewStoredProc
GO








-- Forget the Drop! (SS 2017)
CREATE OR ALTER PROCEDURE dbo.NewStoredProc
AS 
BEGIN
	SELECT 1;
END
GO




-- Reset
DROP PROCEDURE IF EXISTS dbo.NewStoredProc
GO








-----
-- Example #2 - Split those strings!
-- SETUP
IF OBJECT_ID('tempdb.dbo.#tmpVehicleList','U') IS NOT NULL
	DROP TABLE #tmpVehicleList;

IF OBJECT_ID('tempdb.dbo.#tmpVehicleColorList','U') IS NOT NULL
	DROP TABLE #tmpVehicleColorList;

CREATE TABLE #tmpVehicleList (
	RecID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
	ModelName VARCHAR(50),
	ColorName VARCHAR(50)
);

CREATE TABLE #tmpVehicleColorList (
	RecID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
	ModelName VARCHAR(50),
	ColorList VARCHAR(250)
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
ORDER BY Model.ModelName, Color.ColorName;

INSERT INTO #tmpVehicleColorList (
	ModelName, ColorList
)
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
	) AS ColorList 
FROM #tmpVehicleList AS ModelList
GROUP BY ModelList.ModelName;
-- STOP




-- Our starting data. How can we break these apart?
SELECT 
	RecID, 
	ModelName, 
	ColorList
FROM #tmpVehicleColorList;








-- STRING_SPLIT() to the rescue! (SS 2016)
SELECT 
	#tmpVehicleColorList.RecID, 
	#tmpVehicleColorList.ModelName, 
	Colors.Value AS Color
FROM #tmpVehicleColorList
	CROSS APPLY STRING_SPLIT(ColorList, ',') AS Colors;








-- Get Creative - report by Color Count?
SELECT 
	Colors.Value AS Color,
	COUNT(1) AS NumOfVehicles
FROM #tmpVehicleColorList
	CROSS APPLY STRING_SPLIT(ColorList, ',') AS Colors
GROUP BY Colors.Value;








-- Use STRING_SPLIT to search inside the CSV list too!
SELECT 
	#tmpVehicleColorList.RecID,
	#tmpVehicleColorList.ModelName,
	#tmpVehicleColorList.ColorList
FROM #tmpVehicleColorList
WHERE 'Classic Silver' IN (
	SELECT value 
	FROM STRING_SPLIT(ColorList, ',') AS Colors
);  








-----
-- Example #3 - Concat with a delimiter (SS 2017)
SELECT TOP 1000
	Vw_VehiclePackageDetail.MakeName,
	Vw_VehiclePackageDetail.ModelName,
	Vw_VehiclePackageDetail.PackageName,
	Inventory.DateReceived
FROM dbo.Inventory
INNER JOIN dbo.Vw_VehiclePackageDetail
	ON Inventory.BaseModelID = Vw_VehiclePackageDetail.BaseModelID
	AND Inventory.PackageID = Vw_VehiclePackageDetail.PackageID;


-- Pretend we must return it in CSV format:
-- Toyota,Rav4,Extra Luxury Edition,2014-03-14




-- Old way
SELECT TOP 1000
	Vw_VehiclePackageDetail.MakeName + ',' 
	+ Vw_VehiclePackageDetail.ModelName + ',' 
	+ Vw_VehiclePackageDetail.PackageName + ',' 
	+ CAST(Inventory.DateReceived AS VARCHAR(10))
FROM dbo.Inventory
INNER JOIN dbo.Vw_VehiclePackageDetail
	ON Inventory.BaseModelID = Vw_VehiclePackageDetail.BaseModelID
	AND Inventory.PackageID = Vw_VehiclePackageDetail.PackageID;








-- New Hotness: CONCAT_WS() (SS 2017)
SELECT TOP 1000
	CONCAT_WS(
		',',	-- Delimiter
		Vw_VehiclePackageDetail.MakeName,
		Vw_VehiclePackageDetail.ModelName,
		Vw_VehiclePackageDetail.PackageName,
		Inventory.DateReceived		-- No conversion needed either!
	)
FROM dbo.Inventory
INNER JOIN dbo.Vw_VehiclePackageDetail
	ON Inventory.BaseModelID = Vw_VehiclePackageDetail.BaseModelID
	AND Inventory.PackageID = Vw_VehiclePackageDetail.PackageID;
GO



---------------------------------------------
---------------------------------------------
---------------------------------------------
---------------------------------------------
