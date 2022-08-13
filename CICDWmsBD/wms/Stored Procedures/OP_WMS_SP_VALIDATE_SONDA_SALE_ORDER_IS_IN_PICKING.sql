-- =============================================
-- Autor:                pablo.aguilar
-- Fecha de Creacion:     2017-09-28 @ NEXUS-Team Sprint@DuckHunt
-- Description:            
/*
-- Ejemplo de Ejecucion:
                EXEC [wms].[OP_WMS_SP_VALIDATE_SONDA_SALE_ORDER_IS_IN_PICKING] @SALE_ORDER_ID = 123123
				EXEC [wms].[OP_WMS_SP_VALIDATE_SONDA_SALE_ORDER_IS_IN_PICKING] @SALE_ORDER_ID = 14322
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_SONDA_SALE_ORDER_IS_IN_PICKING] (@SALE_ORDER_ID INT)
AS
BEGIN
	SET NOCOUNT ON;
    --
	DECLARE
		@RESULT INT = 0
		,@SOURCE_TYPE VARCHAR(50) = 'SO - SONDA';
	--
	SELECT @RESULT = 1
	FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
	WHERE [H].[DOC_NUM] = @SALE_ORDER_ID
		AND [H].[IS_FROM_SONDA] = 1
		AND [H].[SOURCE_TYPE] = @SOURCE_TYPE;
	--
	IF @RESULT = 1
	BEGIN
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(1 AS VARCHAR) [DbData];
	END; 
	ELSE
	BEGIN
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(0 AS VARCHAR) [DbData];
	END;
END;