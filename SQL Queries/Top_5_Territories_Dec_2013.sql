USE [OZZB_SalesDataWarehouse]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[Top_n_Territories]
		@Year = 2013,
		@Month = 12,
		@n = 5

SELECT	'Return Value' = @return_value

GO
