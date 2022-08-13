-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-04-19 @ Team ERGON - Sprint ERGON 1
-- Description:	 




/*
-- Ejemplo de Ejecucion:
			SELECT  [wms].[OP_WMS_GET_TOP_MASTER_PACK_PARENT]( 'C00030/SUE-DU-CRINO')
    SELECT * FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [OWCBMP]
*/
CREATE FUNCTION [wms].[OP_WMS_GET_TOP_MASTER_PACK_PARENT] (@MATERIAL_ID VARCHAR(50))
RETURNS VARCHAR(50)
AS
BEGIN
  DECLARE @result VARCHAR(50);
  DECLARE @ParentID VARCHAR(50);

  SET @ParentID = (SELECT TOP 1
      [C].[MASTER_PACK_CODE]
    FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
    WHERE [C].[COMPONENT_MATERIAL] = @MATERIAL_ID)

 

    IF (@ParentID IS NULL)
      SET @result = @MATERIAL_ID
    ELSE
      SET @result = [wms].[OP_WMS_GET_TOP_MASTER_PACK_PARENT](@ParentID)

  RETURN @result
END