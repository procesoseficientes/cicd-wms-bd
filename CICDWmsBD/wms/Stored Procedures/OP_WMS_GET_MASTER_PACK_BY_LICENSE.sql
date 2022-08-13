-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-26 @ Team ERGON - Sprint ERGON II
-- Description:	        Obtiene el master pack por la licencia

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 Team ERGON - Sprint ERGON V
-- Description:	 Se agrega parámetro de material

-- Modificacion 6/12/2018 @ GFORCE-Team Sprint Dinosaurio
					-- rodrigo.gomez
					-- Se agrega batch y fecha de expiracion

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_GET_MASTER_PACK_BY_LICENSE] @LICENSE_ID = 177679 , @MATERIAL_ID = 'wms/SKUPRUEBA'
    SELECT * FROM [wms].OP_WMS_MASTER_PACK_HEADER [MPH]

  ARREGLAR MASTERPACK ANTERIORES 
  SELECT * FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [OWMPH]
--UPDATE [wms].[OP_WMS_MASTER_PACK_HEADER] SET [QTY] = 1 WHERE [EXPLODED] = 0 AND [QTY] IS NULL 
--UPDATE [wms].[OP_WMS_MASTER_PACK_HEADER] SET [QTY] = 0 WHERE [EXPLODED] = 1 AND [QTY] IS NULL  

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_MASTER_PACK_BY_LICENSE] (
		@LICENSE_ID NUMERIC
		,@MATERIAL_ID VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@CLIENT_CODE VARCHAR(50);

  ---Obtiene el cliente
	SELECT TOP 1
		@CLIENT_CODE = [L].[CLIENT_OWNER]
	FROM
		[wms].[OP_WMS_LICENSES] [L]
	WHERE
		[L].[LICENSE_ID] = @LICENSE_ID;

  ---Obtiene el id del material
	SELECT TOP 1
		@MATERIAL_ID = [M].[MATERIAL_ID]
	FROM
		[wms].[OP_WMS_MATERIALS] [M]
	WHERE
		(
			[M].[MATERIAL_ID] = @MATERIAL_ID
			OR [M].[BARCODE_ID] = @MATERIAL_ID
			OR [M].[ALTERNATE_BARCODE] = @MATERIAL_ID
		)
		AND [M].[CLIENT_OWNER] = @CLIENT_CODE;

  --
	SELECT
		[MPH].[MASTER_PACK_HEADER_ID]
		,[MPH].[LICENSE_ID]
		,[MPH].[MATERIAL_ID]
		,[M].[MATERIAL_NAME]
		,[MPH].[POLICY_HEADER_ID]
		,[MPH].[LAST_UPDATED]
		,[MPH].[LAST_UPDATE_BY]
		,[MPH].[EXPLODED]
		,[MPH].[EXPLODED_DATE]
		,[MPH].[RECEPTION_DATE]
		,[MPH].[QTY]
		,[IL].[BATCH]
		,[IL].[DATE_EXPIRATION]
	FROM
		[wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [MPH].[MATERIAL_ID])
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[MATERIAL_ID] = [M].[MATERIAL_ID]
											AND [IL].[LICENSE_ID] = [MPH].[LICENSE_ID]
	WHERE
		[MPH].[LICENSE_ID] = @LICENSE_ID
		AND [MPH].[EXPLODED] = 0
		AND [MPH].[MATERIAL_ID] = @MATERIAL_ID
		AND [MPH].[QTY] > 0;

END;