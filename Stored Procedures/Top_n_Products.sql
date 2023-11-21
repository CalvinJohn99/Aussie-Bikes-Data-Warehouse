CREATE PROCEDURE Top_n_Products 
    @Year INT = 2014, 
    @n INT = 10
AS 
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = '
		WITH cte1 AS (SELECT P.ProductKey, CAST(ROUND(SUM(F.Profit_Tax_Freigth_StandardCost),1) AS FLOAT) AS ProductProfit
			FROM SalesOrderFact F
			JOIN ProductDim P
			ON F.ProductKey=P.ProductKey
			JOIN DateDim D
			ON F.OrderDateKey=D.DateKey
			WHERE D.Year=' + CAST(@Year AS NVARCHAR(10)) + '
			GROUP BY P.ProductKey
		)
		SELECT TOP ' + CAST(@n AS NVARCHAR(10)) + ' cte1.ProductKey, cte1.ProductProfit, P.ProductName, P.ProductCategoryName AS Category, P.ProductSubCategoryName AS SubCategory, P.ProductModelName AS Model
		FROM cte1 
		JOIN ProductDim P
		ON cte1.ProductKey=P.ProductKey
		ORDER BY cte1.ProductProfit DESC';

    EXEC sp_executesql @sql;
END;