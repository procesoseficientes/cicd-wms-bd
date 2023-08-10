-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/26/2016 @ A-TEAM Sprint Balder
-- Description:			Obtiene la lista de precios asociada al cliente

-- Modificacion 04-May-17 @ A-Team Sprint Hondo
					-- alberto.ruiz
					-- Se cambia para que obtenga la lista de precios de la tabla SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE_FOR_ROUTE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_PRICE_LIST_BY_SKU_USING_CUSTOMER_ID]  
					@CODE_ROUTE = 'ES000035'
					,@CODE_CUSTOMER = 'CS006519'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_PRICE_LIST_BY_SKU_USING_CUSTOMER_ID](
	@CODE_ROUTE VARCHAR(50)
	,@CODE_CUSTOMER VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	-- ------------------------------------------------------------------------------------
	-- Muestra el listado de skus a de la lista de precios asociada
	-- ------------------------------------------------------------------------------------
	SELECT 
		[SPS].[CODE_PRICE_LIST]
		,[SPS].[CODE_SKU]
		,[SPS].[CODE_PACK_UNIT]
		,[SPS].[PRIORITY]
		,[SPS].[LOW_LIMIT]
		,[SPS].[HIGH_LIMIT]
		,[SPS].[PRICE]
	FROM [SONDA].[SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE] [PLC]
	INNER JOIN [SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE_FOR_ROUTE] [SPS] ON (
		[SPS].[CODE_ROUTE] = [PLC].[CODE_ROUTE]
		AND [SPS].[CODE_PRICE_LIST] = [PLC].[CODE_PRICE_LIST]
	)
	WHERE [PLC].[CODE_ROUTE] = @CODE_ROUTE
		AND [PLC].[CODE_CUSTOMER] = @CODE_CUSTOMER
END
