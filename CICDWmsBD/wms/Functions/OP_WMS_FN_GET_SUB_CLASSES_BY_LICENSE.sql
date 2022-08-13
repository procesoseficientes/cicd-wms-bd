-- =============================================
-- Autor:					kevin.guerra
-- Fecha de Creacion: 		30-Jan-17 @ GForce@Paris Sprint B
-- Description:			    Obtiene las sub clases de la licencia enviada

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_FN_GET_SUB_CLASSES_BY_LICENSE](408468)
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_SUB_CLASSES_BY_LICENSE] (@LICENSE_ID INT)
RETURNS @CLASSES TABLE
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
    DECLARE @SUB_CLASSES_ON_LICENSE TABLE ([SUB_CLASS_ID] INT);
	-- ------------------------------------------------------------------------------------
	-- Obtiene las sub clases de la licencia
	-- ------------------------------------------------------------------------------------
    INSERT  INTO @SUB_CLASSES_ON_LICENSE
    SELECT DISTINCT
        [C].[SUB_CLASS_ID]
    FROM
        [wms].[OP_WMS_INV_X_LICENSE] [IXL]
    INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IXL].[MATERIAL_ID]
    INNER JOIN [wms].[OP_WMS_SUB_CLASS] [C] ON [M].[MATERIAL_SUB_CLASS] = [C].[SUB_CLASS_ID]
    WHERE
        [QTY] > 0
        AND [LICENSE_ID] = @LICENSE_ID;

	-- ------------------------------------------------------------------------------------
	-- Resultado Final
	-- ------------------------------------------------------------------------------------
	INSERT INTO @CLASSES
	SELECT [C].[SUB_CLASS_ID]
          ,[SUB_CLASS_NAME]
          ,[CREATED_BY]
          ,[CREATED_DATETIME]
          ,[LAST_UPDATED_BY]
          ,[LAST_UPDATED]
	FROM [wms].[OP_WMS_SUB_CLASS] [C]
	INNER JOIN @SUB_CLASSES_ON_LICENSE [CL] ON [CL].[SUB_CLASS_ID] = [C].[SUB_CLASS_ID]
	
	RETURN;
END;