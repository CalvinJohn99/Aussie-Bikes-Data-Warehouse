CREATE PROCEDURE Top_n_Territories
    @Year INT = 2014, 
	@Month INT = 12,
    @n INT = 5
AS 
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = '
		WITH cte1 AS (SELECT T1.TerritoryKey, CAST(ROUND(SUM(Profit_Tax_Freigth_StandardCost),1) AS FLOAT) AS TerritoryProfit, SUM(F.OrderQty) AS UnitSales, CAST(ROUND(SUM(F.LineTotal),1) AS FLOAT) AS DollarSales
			FROM SalesOrderFact F
			JOIN SalesTerritoryDim T1
			ON F.TerritoryKey=T1.TerritoryKey
			JOIN DateDim D
			ON F.OrderDateKey=D.DateKey
			WHERE D.Year=' + CAST(@Year AS NVARCHAR(10)) + ' AND D.Month=' + CAST(@Month AS NVARCHAR(10)) + '
			GROUP BY T1.TerritoryKey
		)
		SELECT TOP ' + CAST(@n AS NVARCHAR(10)) + ' cte1.*, T2.TerritoryName, T2.TerritoryGroup
		FROM cte1
		JOIN SalesTerritoryDim T2
		ON cte1.TerritoryKey=T2.TerritoryKey
		ORDER BY cte1.TerritoryProfit DESC';

    EXEC sp_executesql @sql;
END;