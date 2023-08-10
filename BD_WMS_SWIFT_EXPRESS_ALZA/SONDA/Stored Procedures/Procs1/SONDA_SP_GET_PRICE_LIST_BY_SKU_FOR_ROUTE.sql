
-- =====================================================
-- Author:         diego.as
-- Create date:    06-04-2016
-- Description:    Trae las listas de precios por SKU de los clientes  
--				   de las tareas asignadas al dia de trabajo
--				   

--Modificacion 15-04-2016
      -- alberto.ruiz
      -- Se modifico para que envie tambien la lista de precios por defecto

-- Modificacion 19-05-2016
					-- alberto.ruiz
					-- Se agrego el envio de la columna CODE_PACK_UNIT

-- Modificacion 26-08-2016
					-- alberto.ruiz
					-- Se agrego configuracion por si tiene que generar la lista de precios por defecto
/*
-- EJEMPLO DE EJECUCION: 
		
		EXEC [SONDA].[SONDA_SP_GET_PRICE_LIST_BY_SKU_FOR_ROUTE]
			@CODE_ROUTE = '011202'

*/
-- =====================================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_PRICE_LIST_BY_SKU_FOR_ROUTE] (@CODE_ROUTE VARCHAR(50))
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@DEFAULT_CODE_PRICE_LIST VARCHAR(250)
		,@GENERATE_DEFAULT_PRICE_LIST VARCHAR(50)
	--
	SELECT 
		@DEFAULT_CODE_PRICE_LIST = [SONDA].SWIFT_FN_GET_PARAMETER('ERP_HARDCODE_VALUES','PRICE_LIST')
		,@GENERATE_DEFAULT_PRICE_LIST = [SONDA].SWIFT_FN_GET_PARAMETER('ERP_HARDCODE_VALUES','GENERATE_DEFAULT_PRICE_LIST')
	--
	SELECT DISTINCT
		splbc.CODE_PRICE_LIST
	INTO #PRICE_LIST
	FROM [SONDA].SONDA_ROUTE_PLAN srp
	INNER JOIN [SONDA].SWIFT_PRICE_LIST_BY_CUSTOMER splbc ON (srp.RELATED_CLIENT_CODE = splbc.CODE_CUSTOMER)
	WHERE srp.CODE_ROUTE = @CODE_ROUTE
	--
	INSERT INTO #PRICE_LIST (CODE_PRICE_LIST)
	SELECT
		CASE @GENERATE_DEFAULT_PRICE_LIST
			WHEN '1' THEN (@CODE_ROUTE + '|' + @CODE_ROUTE)
			ELSE @DEFAULT_CODE_PRICE_LIST
		END
	--
	SELECT DISTINCT
		CASE PL.CODE_PRICE_LIST
			WHEN (@CODE_ROUTE + '|' + @CODE_ROUTE) THEN @DEFAULT_CODE_PRICE_LIST
			ELSE PL.CODE_PRICE_LIST
		END CODE_PRICE_LIST
		,RTRIM(LTRIM(PL.CODE_SKU)) AS CODE_SKU
		,PL.COST
		,[PL].[CODE_PACK_UNIT]
		,[PL].[UM_ENTRY]
	FROM [SONDA].[SWIFT_PRICE_LIST_BY_SKU] AS PL
	INNER JOIN #PRICE_LIST l ON (l.CODE_PRICE_LIST = PL.CODE_PRICE_LIST)  

END
