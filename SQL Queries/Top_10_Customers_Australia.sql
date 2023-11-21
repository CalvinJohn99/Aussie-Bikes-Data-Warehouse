USE [OZZB_SalesDataWarehouse]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[Top_n_Customers]
		@Country = N'Australia',
		@n = 10

SELECT	'Return Value' = @return_value

GO
