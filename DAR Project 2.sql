
IF OBJECT_ID(N'QOL_Master') IS NOT NULL
BEGIN
	PRINT N'Existing QOL_Master table found. Refreshing data'
	DROP TABLE QOL_Master
END
ELSE
BEGIN
CREATE DATABASE QOLTemp
END
CREATE TABLE QOL_Master (
	Country varchar(50) NOT NULL PRIMARY KEY,
	PurchasingPower_Value decimal(10,2) NOT NULL,
	PurchasingPower_Category varchar(50) NOT NULL,
	Safety_Value decimal(10,2) NOT NULL,
	Safety_Category varchar(50) NOT NULL,
	HealthCare_Value decimal(10,2) NOT NULL,
	HealthCare_Category varchar(50) NOT NULL,
	Climate_Value decimal(10,2) NOT NULL,
	Climate_Category varchar(50) NOT NULL,
	CostofLiving_Value decimal(10,2) NOT NULL,
	CostofLiving_Category varchar(50) NOT NULL,
	PropertyPricetoIncome_Value decimal(10,2) NOT NULL,
	PropertyPricetoIncome_Category varchar(50) NOT NULL,
	TrafficCommuteTime_Value decimal(10,2) NOT NULL,
	TrafficCommuteTime_Category varchar(50) NOT NULL,
	Pollution_Value decimal(10,2) NOT NULL,
	Pollution_Category varchar(50) NOT NULL,
	QualityofLife_Value decimal(10,2) NOT NULL,
	QualityofLife_Category varchar(50) NOT NULL
	);

BULK INSERT QOL_Master
	FROM '~\Quality_of_Life.csv'
	WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK 
	);

--This is just something I was messing around with to make bar charts in SQL. Not really practical, though
--SELECT Country, PropertyPricetoIncome_Value, REPLICATE('-', PropertyPricetoIncome_Value) AS Graph
--FROM QOL_Master
--WHERE PropertyPricetoIncome_Value > 0
--ORDER BY PropertyPricetoIncome_Value;

--The general value table. We'll leave the categories out of this
SELECT Country, PurchasingPower_Value, Safety_Value, HealthCare_Value, Climate_Value, CostofLiving_Value, 
	PropertyPricetoIncome_Value, TrafficCommuteTime_Value, Pollution_Value, QualityofLife_Value
FROM QOL_Master
WHERE QualityofLife_Value > 0
ORDER BY QualityofLife_Value DESC, Pollution_Value;


--The correlations with QOL I picked out while eyeballing the data
SELECT Country, QualityofLife_Value, PropertyPricetoIncome_Value, TrafficCommuteTime_Value, Pollution_Value, PurchasingPower_Value
FROM QOL_Master
WHERE QualityofLife_Value > 0
ORDER BY QualityofLife_Value DESC, Pollution_Value;

--Linear regression to explore correlations
SELECT
	slope, 
	y_bar_max-(x_bar_max*slope) as intercept,
	SQUARE(((n*exy)-(ex*ey))/(SQRT((n*ex2)-SQUARE(ex))*SQRT((n*ey2)-SQUARE(ey)))) as r2,
	ABS(((n*exy)-(ex*ey))/(SQRT((n*ex2)-SQUARE(ex))*SQRT((n*ey2)-SQUARE(ey)))) as r
FROM(
	SELECT 
		SUM((x-x_bar)*(y-y_bar))/SUM((x-x_bar)*(x-x_bar)) as slope,
		MAX(x_bar) as x_bar_max,
		MAX(y_bar) as y_bar_max,
		SUM(x2) as ex2,
		SUM(y2) as ey2,
		SUM(xy) as exy,
		SUM(x) as ex,
		SUM(y) as ey,
		MAX(n) as n
	FROM(
		SELECT 
			AVG(x) OVER() as x_bar,
			AVG(y) OVER() as y_bar,
			x,
			y,
			x*x as x2,
			y*y as y2,
			x*y as xy,
			n
		FROM (
			SELECT QualityofLife_Value as x, CostofLiving_Value as y, COUNT(*) OVER() as n
			FROM QOL_Master
			WHERE QualityofLife_Value > 0
			)a
		)b
	)c;
--r2:
--PPV = 0.750
--PV = 0.662
--TCTV = 0.347
--PPTIV = 0.358

--SV = 0.328
--HCV = 0.346
--CV = 0.002
--COLV = 0.447

--and this is why we use statistics