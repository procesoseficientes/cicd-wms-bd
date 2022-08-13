-- =============================================
-- Author:		marvin.solares
-- Create date: 20180919 GForce@Kiwi
-- Description:	funcion que devuelve la descripcion de un material
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GETMATERIAL_DESC] (
		@pMaterial VARCHAR(25)
		,@pClientOwner VARCHAR(25)
	)
RETURNS TABLE
	AS
RETURN
	(SELECT
			ISNULL([MATERIAL_NAME], 'N/A') AS [MATERIAL_NAME]
		FROM
			[wms].[OP_WMS_MATERIALS]
		WHERE
			(
				[BARCODE_ID] = @pMaterial
				OR [ALTERNATE_BARCODE] = @pMaterial
			)
			AND [CLIENT_OWNER] = @pClientOwner);