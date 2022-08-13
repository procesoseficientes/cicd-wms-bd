-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-25 @ Team ERGON - Sprint ERGON II
-- Description:	 PROCEDIMIENTO QUE OBTIENE TODOS LOS COMPONENTES DE UN MASTERPACK


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 Team ERGON - Sprint ERGON V
-- Description:	 Se elimina las variables de unidades de medida porque ya no se utilizaran en los masterpacks





/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_MATERIALS_COMPONENTS_MASTER_PACK] @MATERIAL_ID = 'wms/PT0001'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MATERIALS_COMPONENTS_MASTER_PACK] (@MATERIAL_ID VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [MP].[MASTER_PACK_COMPONENT_ID]
   ,[MP].[MASTER_PACK_CODE]
   ,[MP].[COMPONENT_MATERIAL]
   ,[C].[MATERIAL_NAME] [COMPONENT_NAME]
   ,[C].[BARCODE_ID] [COMPONENT_BARCODE]
   ,[MP].[QTY]
     ,CASE [C].[IS_MASTER_PACK]
     	WHEN 1 THEN 'Si'
     	WHEN 0 THEN 'No'
     END AS [IS_MASTER_PACK]
  FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [MP]
  INNER JOIN [wms].[OP_WMS_MATERIALS] [C]
    ON [C].[MATERIAL_ID] = [MP].[COMPONENT_MATERIAL]
  WHERE [MP].[MASTER_PACK_CODE] = @MATERIAL_ID

END