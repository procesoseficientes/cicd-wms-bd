-- =============================================
-- Autor:					marvin.solares
-- Fecha de Creacion: 		20-AGO-2019 G-Force@FlorencioVarela
-- Description:			    Obtiene el lote y fecha de expiracion para un material en una licencia
/*
Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_SP_GET_INFO_BATCH] @LICENSE_ID = NULL, -- numeric
	@MATERIAL_ID = '' -- varchar(50)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INFO_BATCH] (
		@LICENSE_ID [NUMERIC](18, 0)
		,@MATERIAL_ID [VARCHAR](50)
	)
AS
BEGIN

	SELECT
		[BATCH]
		,[DATE_EXPIRATION]
	FROM
		[wms].[OP_WMS_INV_X_LICENSE]
	WHERE
		[LICENSE_ID] = @LICENSE_ID
		AND [MATERIAL_ID] = @MATERIAL_ID;	

END;