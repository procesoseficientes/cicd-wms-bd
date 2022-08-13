-- =============================================
-- Autor:					kevin.guerra
-- Fecha de Creacion: 		07-04-2020 @ GForce@Paris Sprint B
-- Description:			    Obtiene las sub clases de la ubicacion enviada
/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_FN_GET_SUB_CLASSES_BY_LOCATION]('B01-R01-C01-NA')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_SUB_CLASSES_BY_LOCATION]
(	
	@LOCATION_SPOT VARCHAR(25)
)
RETURNS @SUB_CLASSES TABLE
    (
     [SUB_CLASS_ID] INT
    ,[SUB_CLASS_NAME] VARCHAR(50)
    ,[CREATED_BY] VARCHAR(50)
    ,[CREATED_DATETIME] DATETIME
    ,[LAST_UPDATED_BY] VARCHAR(50)
    ,[LAST_UPDATED] DATETIME
    )
AS
BEGIN
    DECLARE @SUB_CLASSES_ON_LOCATION TABLE ([SUB_CLASS_ID] INT);
	-- ------------------------------------------------------------------------------------
	-- Obtiene las clases de la ubicacion
	-- ------------------------------------------------------------------------------------
    INSERT  INTO @SUB_CLASSES_ON_LOCATION
    SELECT DISTINCT
		[C].[SUB_CLASS_ID]
	FROM [wms].[OP_WMS_INV_X_LICENSE] [IXL]
	INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[LICENSE_ID] = [IXL].[LICENSE_ID]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IXL].[MATERIAL_ID]
	INNER JOIN [wms].[OP_WMS_SUB_CLASS] [C] ON [M].[MATERIAL_SUB_CLASS] = [C].[SUB_CLASS_ID]
	WHERE [L].[CURRENT_LOCATION] = @LOCATION_SPOT
		AND [IXL].[QTY] > 0

	-- ------------------------------------------------------------------------------------
	-- Resultado Final
	-- ------------------------------------------------------------------------------------
	INSERT INTO @SUB_CLASSES
	SELECT [C].[SUB_CLASS_ID]
          ,[SUB_CLASS_NAME]
          ,[CREATED_BY]
          ,[CREATED_DATETIME]
          ,[LAST_UPDATED_BY]
          ,[LAST_UPDATED]
	FROM [wms].[OP_WMS_SUB_CLASS] [C]
	INNER JOIN @SUB_CLASSES_ON_LOCATION [CL] ON [CL].[SUB_CLASS_ID] = [C].[SUB_CLASS_ID]
	
	RETURN;
END;