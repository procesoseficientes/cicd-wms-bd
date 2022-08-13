
CREATE VIEW [SONDA].[ERP_SKU_BASE_PRICE_BY_PACK] 
AS
	SELECT
			 NULL CODE_PRICE_LIST 
			,NULL CODE_SKU
			,NULL CODE_PACK_UNIT
			,NULL  COST
		
-- SELECT *
--	FROM OPENQUERY([ERP_SERVER], '
--		SELECT
--			CAST(IT.PriceList AS VARCHAR) AS CODE_PRICE_LIST 
--			,IT.ItemCode AS CODE_SKU
--			,OU.UomCode AS CODE_PACK_UNIT
--			,CAST(IT.Price AS NUMERIC(18,6)) AS COST
--		FROM me_llega_db.dbo.ITM9 IT
--		INNER JOIN me_llega_db.dbo.OUOM OU ON (
--			OU.UomEntry = IT.UomEntry
--		)
--		ORDER BY IT.PriceList
--			,IT.ItemCode
--			,OU.UomCode
--	')

