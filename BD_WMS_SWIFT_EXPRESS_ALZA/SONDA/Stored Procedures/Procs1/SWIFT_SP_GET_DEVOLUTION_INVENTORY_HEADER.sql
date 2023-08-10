-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Nov-16 @ A-TEAM Sprint 4 
-- Description:			SP para obtener el encabezado de la devolucion de inventario, ya sea uno otodos

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_DEVOLUTION_INVENTORY_HEADER]
				--
				EXEC [SONDA].[SWIFT_SP_GET_DEVOLUTION_INVENTORY_HEADER]
					@DEVOLUTION_ID = 1005
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_DEVOLUTION_INVENTORY_HEADER](
	@DEVOLUTION_ID INT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[DIH].[DEVOLUTION_ID]
		,[DIH].[CODE_CUSTOMER]
		,[DIH].[DOC_SERIE]
		,[DIH].[DOC_NUM]
		,[DIH].[CODE_ROUTE]
		,[DIH].[GPS_URL]
		,[DIH].[POSTED_DATETIME]
		,[DIH].[POSTED_BY]
		,[DIH].[LAST_UPDATE]
		,[DIH].[LAST_UPDATE_BY]
		,[DIH].[TOTAL_AMOUNT]
		,[DIH].[IS_POSTED]
		,[DIH].[IMG_1]
		,CASE [DIH].[IMG_2] 
			WHEN 'undefined' THEN NULL
			ELSE [DIH].[IMG_2]
		END [IMG_2]
		,CASE [DIH].[IMG_3]
			WHEN 'undefined' THEN NULL
			ELSE [DIH].[IMG_3]
		END [IMG_3]
	FROM [SONDA].[SONDA_DEVOLUTION_INVENTORY_HEADER] [DIH]
	WHERE @DEVOLUTION_ID IS NULL
		OR [DIH].[DEVOLUTION_ID] = @DEVOLUTION_ID
END
