-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	05-09-2016
-- Description:			Valida si hay inventario disponible para un SKU

/*
-- DROP FUNCTION [SONDA].[SWIFT_FN_VALIDATE_STOCK_INVENTORY_BY_WS_AND_SKU]
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        --
        EXEC [SONDA].[SWIFT_SP_VALIDATE_STOCK_INVENTORY_BY_WS_AND_SKU]			@CODE_WAREHOUSE = 'BODEGA_CENTRAL' ,@CODE_SKU = '100003' ,@QTY = '4'
		SELECT [SONDA].[SWIFT_FN_VALIDATE_STOCK_INVENTORY_BY_WS_AND_SKU]('BODEGA_CENTRAL','100003','4')
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_VALIDATE_STOCK_INVENTORY_BY_WS_AND_SKU](
		@CODE_WAREHOUSE VARCHAR(50)
		,@CODE_SKU VARCHAR(50)
		,@QTY INT)
		
RETURNS INT
AS BEGIN
	DECLARE @RESULT INT = 0
	-- ------------------------------------------------------------------------------------
	-- Obtiene el invetario disponible
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1 @RESULT =
		CASE
			WHEN (SUM(I.ON_HAND) - COALESCE(MAX(IR.QYT_RESERVED), 0)) >= @QTY THEN 1
			ELSE 0
		END
	FROM [SONDA].SWIFT_INVENTORY I
	LEFT JOIN [SONDA].[SWIFT_FN_GET_INVENTORY_RESERVED](@CODE_WAREHOUSE) IR
	 ON (I.SKU = IR.CODE_SKU )
	WHERE 		
		I.ON_HAND > 0
		AND I.LAST_UPDATE_BY != 'BULK_DATA'
		AND I.WAREHOUSE = @CODE_WAREHOUSE
		AND I.SKU = @CODE_SKU

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	RETURN @RESULT 
END
