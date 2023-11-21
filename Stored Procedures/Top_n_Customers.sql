CREATE PROCEDURE Top_n_Customers 
    @Country NVARCHAR(50) = 'Australia', 
    @n INT = 10
AS 
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = '
        WITH cte1 AS (
            SELECT 
                C1.CustomerKey, 
                CAST(ROUND(SUM(F.Profit_Tax_Freigth_StandardCost), 1) AS FLOAT) AS CustomerProfit
            FROM 
                SalesOrderFact F
                JOIN CustomerDim C1 ON F.CustomerKey = C1.CustomerKey
            WHERE 
                C1.CountryRegionName = ''' + @Country + '''
            GROUP BY 
                C1.CustomerKey
        )
        SELECT 
            TOP ' + CAST(@n AS NVARCHAR(10)) + ' 
            cte1.CustomerKey, 
            C2.CustomerID, 
            cte1.CustomerProfit, 
            C2.FirstName + '' '' + C2.LastName AS FullName, 
            C2.City, 
            C2.StateProvinceName AS State
        FROM 
            cte1 
            JOIN CustomerDim C2 ON cte1.CustomerKey = C2.CustomerKey
        ORDER BY 
            cte1.CustomerProfit DESC';

    EXEC sp_executesql @sql;
END;


