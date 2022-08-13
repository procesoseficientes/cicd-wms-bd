-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		30-Jan-17 @ Reborn Team Sprint Trotzdem
-- Description:			    Obtiene las clases de la ubicacion enviada
/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_FN_GET_CLASSES_BY_LOCATION]('B01-R01-C01-NA')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_CLASSES_BY_LOCATION]
(	
	@LOCATION_SPOT VARCHAR(25)
)
RETURNS @CLASSES TABLE
    (
     [CLASS_ID] INT
    ,[CLASS_NAME] VARCHAR(50)
    ,[CLASS_DESCRIPTION] VARCHAR(250)
    ,[CLASS_TYPE] VARCHAR(50)
    ,[CREATED_BY] VARCHAR(50)
    ,[CREATED_DATETIME] DATETIME
    ,[LAST_UPDATED_BY] VARCHAR(50)
    ,[LAST_UPDATED] DATETIME
    ,[PRIORITY] INT
    )
AS
BEGIN
    DECLARE @CLASSES_ON_LOCATION TABLE ([CLASS_ID] INT);
	-- ------------------------------------------------------------------------------------
	-- Obtiene las clases de la ubicacion
	-- ------------------------------------------------------------------------------------
    INSERT  INTO @CLASSES_ON_LOCATION
    SELECT DISTINCT
		[C].[CLASS_ID]
	FROM [wms].[OP_WMS_INV_X_LICENSE] [IXL]
	INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[LICENSE_ID] = [IXL].[LICENSE_ID]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IXL].[MATERIAL_ID]
	INNER JOIN [wms].[OP_WMS_CLASS] [C] ON [M].[MATERIAL_CLASS] = [C].[CLASS_ID]
	WHERE [L].[CURRENT_LOCATION] = @LOCATION_SPOT
		AND [IXL].[QTY] > 0

	-- ------------------------------------------------------------------------------------
	-- Resultado Final
	-- ------------------------------------------------------------------------------------
	INSERT INTO @CLASSES
	SELECT [C].[CLASS_ID]
          ,[CLASS_NAME]
          ,[CLASS_DESCRIPTION]
          ,[CLASS_TYPE]
          ,[CREATED_BY]
          ,[CREATED_DATETIME]
          ,[LAST_UPDATED_BY]
          ,[LAST_UPDATED]
          ,[PRIORITY] 
	FROM [wms].[OP_WMS_CLASS] [C]
	INNER JOIN @CLASSES_ON_LOCATION [CL] ON [CL].[CLASS_ID] = [C].[CLASS_ID]
	
	RETURN;
END;