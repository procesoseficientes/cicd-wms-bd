-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	27-Jun-18 @ Nexus Team Sprint  
-- Description:			SP que actualiza 

/*
-- Ejemplo de Ejecucion:
				[wms].[OP_WMS_SP_GET_SERIAL_NUMBER_X_MATERIAL_INFO]
					@
				-- 
				SELECT * FROM 
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_SERIAL_NUMBER_X_MATERIAL_INFO_BY_LOCATION (
		@LOCATION VARCHAR(100)
		,@LOGIN VARCHAR(25) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[SN].[CORRELATIVE]
		,[SN].[LICENSE_ID]
		,[SN].[MATERIAL_ID]
		,[SN].[SERIAL]
		,[SN].[BATCH]
		,[SN].[DATE_EXPIRATION]
	FROM
		[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [SN]
	INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [SN].[LICENSE_ID] = [L].[LICENSE_ID]
	WHERE
		[L].[CURRENT_LOCATION] = @LOCATION; 
END;